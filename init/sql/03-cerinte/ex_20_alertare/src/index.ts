import oracledb from 'oracledb';
import { EventEmitter } from 'events';
import { OracleDBConfig, Config } from './config';
import { DBConnection } from './dbConnection';

const ALERT_NAME = 'ISTORIC_PRET_INS';

/**
 * Porneste o conexiune, asculta -> incheie dupa un timp total
 * @param dbConfig 
 * @param eventEmitter 
 * @param timpAscultareIter 
 * @param timpTotalSec 
 */
async function listenForInsertLoop(dbConfig: OracleDBConfig, eventEmitter: EventEmitter, timpAscultareIter = 60, timpTotalSec = 240): Promise<void> {
   const connection = await oracledb.getConnection({
      user: dbConfig.user,
      password: dbConfig.password,
      connectString: `${dbConfig.hostname}:${dbConfig.port}/${dbConfig.serviceName ?? dbConfig.sid}`,
      privilege: dbConfig.role === 'SYSDBA' ? oracledb.SYSDBA : undefined,
   });

   console.log(`Inregistrare alerta pentru ${ALERT_NAME}...`);
   await connection.execute(
      `BEGIN
         DBMS_ALERT.REGISTER(:alert_name);
      END;`,
      { alert_name: ALERT_NAME },
      { autoCommit: true }
   );

   console.log(`Ascultare alerta pentru ${ALERT_NAME} pe o conexiune Oracle separata...`);
   let timpAscultatSec = 0;
   while (timpAscultatSec < timpTotalSec) {
      const result: oracledb.Result<any> = await connection.execute(
         `BEGIN
            DBMS_ALERT.WAITONE(:alert_name, :message, :status, :timeout);
         END;`,
         {
            alert_name: ALERT_NAME,
            message: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 4000 },
            status: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
            timeout: timpAscultareIter,
         }
      );

      const { message, status }: { message?: string; status?: number } = result.outBinds as { message?: string; status?: number } || {};
      timpAscultatSec += timpAscultareIter;

      if (status === 0) {
         console.log(`Primit alerta de la DB: '${message}'`);
         eventEmitter.emit('insert', {
            alertName: ALERT_NAME,
            message: message, 
         });
         continue;
      }
   
      console.log(`Iter ascultare incheiat; status: ${status}, timp ascultat sec: ${timpAscultatSec}`);
   }

   // dezregistreaza alerta
   await connection.execute(
      `BEGIN
         DBMS_ALERT.REMOVE(:alert_name);
      END;`,
      { alert_name: ALERT_NAME },
      { autoCommit: true }
   );

   await connection.close();
   console.log(`Ascultare alerta pentru ${ALERT_NAME} incheiata dupa ${timpAscultatSec} secunde.`);
}

/**
 * 
 * @param connection 
 * @returns map de forma { ticker: average_price_change_percent }
 */
async function calculeazaAvgPriceChangePercent(connection: oracledb.Connection): Promise<Map<string, number>> {
   // 1. Calculeaza average price change % pentru fiecare ticker
   let tickers_unique: oracledb.Result<any> = await connection.execute(`
      SELECT UNIQUE ticker FROM istoric_pret ORDER BY ticker
   `);
   console.log('Tickers (unice):');
   if (tickers_unique.rows?.length === 0) 
      throw new Error('Nu s-au gasit tickere in baza de date.');
   console.table(tickers_unique.rows);

   // average ticker change %
   let t_change_percent: Map<string, number> = new Map();
   for (let i = 0; i < tickers_unique.rows!.length; i++) {
      const ticker = tickers_unique.rows![i][0];
      // console.log(`Calculating average price change % for ticker "${ticker}"...`);

      const preturi_inchidere: oracledb.Result<any> = await connection.execute(`
         SELECT pret_inchidere
         FROM istoric_pret
         WHERE ticker = :ticker   
      `, { ticker });
     
      let p_last: number | null = null;
      let p_changes: number[] = [];
      for (let j = 0; j < preturi_inchidere.rows!.length; j++) {
         const pret_inchidere: number = preturi_inchidere.rows![j][0];
         if (p_last !== null) {
            const change_percent = ((pret_inchidere - p_last) / p_last) * 100;
            p_changes.push(change_percent);
            // console.log(change_percent);
         }
         p_last = pret_inchidere;
      }
      
      // average change %
      const avg_change_percent = p_changes.reduce((sum, c) => sum + c, 0) / p_changes.length;
      t_change_percent.set(ticker, avg_change_percent);
      // console.log(`Average price change % for ticker "${ticker}": ${avg_change_percent.toFixed(2)}%`);
   }
   console.log('Average price change % for each ticker:', t_change_percent);
   return t_change_percent;
}

async function main(): Promise<void> {
   console.log(`Loading config from './config.jsonc'...`);
   const config: Config = Config.fromJSON('./config.jsonc');
   
   const queryConnection = new DBConnection(config.oracleDBConfig);
   await queryConnection.connect();

   const changeAvgPercentMap: Map<string, number> = await calculeazaAvgPriceChangePercent(queryConnection.connection!);
   // Consideram threshold de alertare de average percent pentru ticker + 5%

   const insertEvents = new EventEmitter();
   insertEvents.on('insert', async payload => {
      if (payload.alertName === ALERT_NAME) { 
         // va fi de forma:  {
         //   alertName: 'ISTORIC_PRET_INS',
         //   message: 'ticker=AAPL, data=2026-05-12 00:00:00'
         // }
         const { message }: { message: string } = payload;
         const [tickerPart, data] = message.split(',').map((part: string) => part.trim().split('=')[1]);
         console.log(`Insert detectat pentru ticker "${tickerPart}" la data "${data}"`);

         // Acum tb calculat change % folosind ultimele 2 intrari pentru ticker
         
         const preturi_inchidere: oracledb.Result<any> = await queryConnection.connection!.execute(`
            SELECT pret_inchidere
            FROM istoric_pret
            WHERE ticker = :ticker
            ORDER BY data_cotatie DESC
            FETCH FIRST 2 ROWS ONLY
         `, { ticker: tickerPart });
         if (preturi_inchidere.rows!.length < 2) {
            console.warn(`Nu sunt suficiente date pentru a calcula price change % pentru ticker "${tickerPart}". Se asteapta urmatorul insert...`);
            return;
         }

         const p_a: number = preturi_inchidere.rows![1][0]; // penultima intrare (inainte de insertul curent)
         const p_b: number = preturi_inchidere.rows![0][0]; // ultima intrare (insertul curent)

         const p_chg: number = ((p_b - p_a) / p_a) * 100;
         console.log(`Price change % pentru ticker "${tickerPart}": ${p_chg.toFixed(2)}%`);
         if (p_chg > (changeAvgPercentMap.get(tickerPart) ?? 0) + 5) {
            console.log(`ALERTA: Price change % pentru ticker "${tickerPart}" a depasit threshold-ul de alertare! (${p_chg.toFixed(2)}% > ${((changeAvgPercentMap.get(tickerPart) ?? 0) + 5).toFixed(2)}%)`);
         }
      }
   });
   const pListenInsert: Promise<void> = listenForInsertLoop(config.oracleDBConfig, insertEvents);

   
   await pListenInsert; // asteaptea pana se termina 
   await queryConnection.disconnect();
}

void main();
