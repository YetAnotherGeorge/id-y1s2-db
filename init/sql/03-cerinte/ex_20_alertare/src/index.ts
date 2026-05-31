import oracledb from 'oracledb';
import { OracleDBConfig, Config } from './config';
import { DBConnection } from './dbConnection';

async function main(): Promise<void> {
   console.log(`Loading config from './config.jsonc'...`);
   const config: Config = Config.fromJSON('./config.jsonc');
   
   const dbConnection = new DBConnection(config.dbConnection);
   await dbConnection.connect();

   var result = await dbConnection.connection!.execute(`SELECT * FROM BURSA`);
   console.log(`Rows from BURSA:`);
   console.table(result.rows ?? []);

   await dbConnection.disconnect();
}

void main();
