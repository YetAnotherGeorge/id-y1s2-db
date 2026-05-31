import oracledb from 'oracledb';
import { OracleDBConfig, Config } from './config';

export class DBConnection {
   public config: OracleDBConfig;
   public oracleDbConfig: oracledb.ConnectionAttributes;
   public connection: oracledb.Connection | null = null;

   constructor(config: OracleDBConfig) {
      this.config = config;
      this.oracleDbConfig = {
         user: config.user,
         password: config.password,
         connectString: `${config.hostname}:${config.port}/${config.serviceName ?? config.sid}`,
         privilege: config.role === 'SYSDBA' ? oracledb.SYSDBA : undefined,
      };
   }

   public async connect(): Promise<void> {
      console.log(`Connecting to Oracle database: "${this.oracleDbConfig.connectString}" - user: "${this.oracleDbConfig.user}"...`);
      try {
         this.connection = await oracledb.getConnection(this.oracleDbConfig);
         console.log('Successfully connected to Oracle database.');
      } catch (error) {
         console.error('Oracle connection failed:', error);
         this.connection = null;
         throw error;
      }
   }

   public async disconnect(): Promise<void> {
      console.log('Disconnecting from Oracle database...');
      if (this.connection) {
         await this.connection.close();
         this.connection = null;
      }
      console.log('Disconnected from Oracle database.');
   }
}