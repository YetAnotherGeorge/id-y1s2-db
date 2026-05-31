import * as fs from 'fs';
import * as path from 'path';
import JSON5 from 'json5';

export class OracleDBConfig {
   role: "Default" | "SYSDBA";
   user: string;
   password: string;
   hostname: string;
   port: number;
   type: "Service Name" | "SID";
   serviceName?: string;
   sid?: string;

   /** Va verifica configuratia */
   constructor(config: {
      role: "Default" | "SYSDBA", user: string, password: string, hostname: string,
      port: number, type: "Service Name" | "SID", serviceName?: string, sid?: string
   }) {
      // 1. role:
      if (config.role !== "Default" && config.role !== "SYSDBA")
         throw new Error(`Invalid role: ${config.role}. Must be "Default" or "SYSDBA".`);
      this.role = config.role;
      // 2. user
      if (typeof config.user !== 'string' || config.user.trim() === '')
         throw new Error('User must be a non-empty string.');
      this.user = config.user;
      // 3. password
      this.password = config.password;
      // 4. hostname
      if (typeof config.hostname !== 'string' || config.hostname.trim() === '')
         throw new Error('Hostname must be a non-empty string.');
      this.hostname = config.hostname;
      // 5. port
      if (typeof config.port !== 'number' || config.port <= 0 || config.port > 65535)
         throw new Error('Port must be a number between 1 and 65535.');
      this.port = config.port;
      // 6. type -> service name / SID
      if (config.type !== "Service Name" && config.type !== "SID")
         throw new Error(`Invalid type: ${config.type}. Must be "Service Name" or "SID".`);
      this.type = config.type;
      if (this.type === "Service Name") {
         if (typeof config.serviceName !== 'string' || config.serviceName.trim() === '')
            throw new Error('Service Name must be a non-empty string when type is "Service Name".');
         this.serviceName = config.serviceName;
      } else {
         if (typeof config.sid !== 'string' || config.sid.trim() === '')
            throw new Error('SID must be a non-empty string when type is "SID".');
         this.sid = config.sid;
      }
   }
}

export class Config {
   oracleDBConfig: OracleDBConfig;

   constructor(rawConfig: object | any) {
      if (!rawConfig || typeof rawConfig !== 'object')
         throw new Error('Configuration must be a valid object.');
      if (!rawConfig.dbConnection)
         throw new Error('Configuration must contain a valid dbConnection object.');
      this.oracleDBConfig = new OracleDBConfig(rawConfig['dbConnection']);
   }

   public static fromJSON(jsonPath: string): Config {
      const absolutePath = path.resolve(jsonPath);
      if (!fs.existsSync(absolutePath)) {
         throw new Error(`Configuration file not found at path: ${absolutePath}`);
      }
      const configObj = JSON5.parse(fs.readFileSync(absolutePath, 'utf-8'));
      // console.log(`Raw configuration loaded from '${absolutePath}':`, configObj);
      const c = new Config(configObj);
      console.log(`Configuration loaded successfully from '${absolutePath}':\n`, c);
      return c;
   }
      
}
