import oracledb from 'oracledb';
import { OracleDBConfig, Config } from './config';

async function main(): Promise<void> {
   console.log(`Loading config from './config.jsonc'...`);
   const config: Config = Config.fromJSON('./config.jsonc');
   
   const dbConfig: oracledb.ConnectionAttributes = {
      user: config.dbConnection.user,
      password: config.dbConnection.password,
      connectString: `${config.dbConnection.hostname}:${config.dbConnection.port}/${config.dbConnection.serviceName ?? config.dbConnection.sid}`,
      privilege: config.dbConnection.role === 'SYSDBA' ? oracledb.SYSDBA : undefined,
   };
   let connection: oracledb.Connection | null = null;
   
   try {
      connection = await oracledb.getConnection(dbConfig);
      console.log('Successfully connected to Oracle database.');
   } catch (error) {
      console.error('Oracle connection failed:', error);
      process.exitCode = 1;
   }

   // try {
   //    connection = await oracledb.getConnection(dbConfig);

   //    // Keep the query text as requested while targeting the expected schema.
   //    if (dbSchema.trim().length > 0) {
   //       const safeSchema = dbSchema.replace(/[^A-Za-z0-9_]/g, '').toUpperCase();
   //       await connection.execute(`ALTER SESSION SET CURRENT_SCHEMA = ${safeSchema}`);
   //    }

   //    const result = await connection.execute(
   //       'SELECT * FROM BURSA',
   //       [],
   //       {
   //          outFormat: oracledb.OUT_FORMAT_OBJECT
   //       }
   //    );

   //    console.log('Rows from BURSA:');
   //    console.table(result.rows ?? []);
   // } catch (error) {
   //    console.error('Oracle query failed:', error);
   //    process.exitCode = 1;
   // } finally {
   //    if (connection) {
   //       await connection.close();
   //    }
   // }
}

void main();
