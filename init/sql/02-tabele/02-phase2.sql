/*
Tablele intermediare (care depind de faza 1)

Cerinta 11: Crearea tabelelor în SQL și inserarea de date coerente în fiecare dintre acestea: 
   - minimum 5 înregistrări în fiecare tabel neasociativ; 
   - minimum 10 înregistrări în tabelele asociative; 
   - maxim 30 de înregistrări în fiecare tabel 

Tabel: simbol_bursier
   - ticker: # 
   - id_companie: companie.id_companie
   - cod_moneda: moneda.cod_moneda
   - denumire_simbol: String
   - sector: String

Tabel: istoric_pret

Tabel: portofoliu
*/

-- DROP TABLE simbol_bursier CASCADE CONSTRAINTS;
-- DROP TABLE istoric_pret CASCADE CONSTRAINTS;
-- DROP TABLE portofoliu CASCADE CONSTRAINTS;

-- Tabel '04: Simbol Bursier'
CREATE TABLE simbol_bursier (
   ticker VARCHAR2(10) PRIMARY KEY,
   id_companie NUMBER NOT NULL,
   cod_moneda VARCHAR2(10) NOT NULL,
   denumire_simbol VARCHAR2(100) NOT NULL,
   sector VARCHAR2(60) NOT NULL,

   CONSTRAINT fk_simbol_companie
      FOREIGN KEY (id_companie)
      REFERENCES companie(id_companie),

   CONSTRAINT fk_simbol_moneda
      FOREIGN KEY (cod_moneda)
      REFERENCES moneda(cod_moneda)
);
DELETE FROM simbol_bursier;

INSERT INTO simbol_bursier (ticker, id_companie, cod_moneda, denumire_simbol, sector) VALUES ('TLV', 1, 'RON', 'Banca Transilvania', 'Financiar');
INSERT INTO simbol_bursier (ticker, id_companie, cod_moneda, denumire_simbol, sector) VALUES ('NVDA', 2, 'USD', 'NVIDIA', 'Tehnologie');
INSERT INTO simbol_bursier (ticker, id_companie, cod_moneda, denumire_simbol, sector) VALUES ('ALV', 3, 'EUR', 'Allianz Group', 'Asigurari');
INSERT INTO simbol_bursier (ticker, id_companie, cod_moneda, denumire_simbol, sector) VALUES ('NVO', 4, 'USD', 'Novo Nordisk', 'Sanatate');
INSERT INTO simbol_bursier (ticker, id_companie, cod_moneda, denumire_simbol, sector) VALUES ('AAPL', 5, 'USD', 'Apple', 'Tehnologie');
COMMIT;

-- Tabel '09: Istoric Pret' -- 30 de valori vor fi inserate in total, intr-o ordine aleatoare
CREATE TABLE istoric_pret (
   ticker VARCHAR2(10) NOT NULL,
   data_cotatie TIMESTAMP NOT NULL, -- data de forma 'YYYY-MM-DD HH24:MI:SS'
   pret_deschidere NUMBER(14,4) CHECK (pret_deschidere > 0),
   pret_inchidere NUMBER(14,4) CHECK (pret_inchidere > 0),
   pret_maxim NUMBER(14,4) CHECK (pret_maxim > 0),
   pret_minim NUMBER(14,4) CHECK (pret_minim > 0),
   volum NUMBER CHECK (volum >= 0),

   CONSTRAINT pk_istoric_pret
      PRIMARY KEY (ticker, data_cotatie),
   
   CONSTRAINT fk_istoric_pret_ticker
      FOREIGN KEY (ticker)
      REFERENCES simbol_bursier(ticker)

);
DELETE FROM istoric_pret;
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-05-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 39.000, 38.780, 39.200, 38.720, 643946.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-04-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 202.460, 199.640, 203.830, 197.220, 113561800.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-04-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 36.680, 36.280, 36.880, 36.040, 826925.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-04-09 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 258.762, 260.250, 260.880, 255.834, 28121600.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-05-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 276.675, 283.918, 284.308, 276.246, 49311700.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-04-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 259.741, 260.240, 261.949, 258.782, 31291500.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('ALV', TO_TIMESTAMP('2026-04-27 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 370.931, 371.122, 373.321, 368.541, 465879.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-04-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 175.730, 178.100, 178.230, 173.660, 132534900.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-04-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 36.100, 36.100, 36.400, 36.100, 452372.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-04-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 177.160, 177.640, 177.790, 175.760, 107564300.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('ALV', TO_TIMESTAMP('2026-05-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 369.688, 375.233, 378.770, 368.732, 901343.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-04-28 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 209.490, 213.170, 214.730, 208.200, 180275400.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-04-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 272.509, 270.810, 272.809, 269.402, 38157100.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-04-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 37.000, 36.700, 37.000, 36.260, 801148.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-04-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 36.840, 37.840, 37.860, 36.840, 529882.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVO', TO_TIMESTAMP('2026-05-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 44.220, 44.390, 44.590, 43.740, 11628000.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-04-02 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 36.100, 36.160, 36.300, 36.020, 138335.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-04-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 202.130, 199.880, 202.750, 199.000, 107945300.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('ALV', TO_TIMESTAMP('2026-04-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 375.042, 377.432, 379.535, 373.894, 623481.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-05-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 208.340, 211.500, 214.200, 206.500, 168307900.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-04-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 270.081, 272.799, 274.028, 270.041, 36590200.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-05-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 291.980, 292.680, 293.880, 290.230, 42247300.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 278.603, 279.882, 286.956, 278.114, 79915400.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVO', TO_TIMESTAMP('2026-04-27 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 40.760, 41.200, 41.670, 40.550, 19367700.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('AAPL', TO_TIMESTAMP('2026-05-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 289.743, 293.050, 294.489, 289.733, 52692800.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('ALV', TO_TIMESTAMP('2026-04-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 352.767, 351.046, 356.973, 350.377, 645247.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVO', TO_TIMESTAMP('2026-05-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 46.310, 45.760, 47.550, 45.530, 30895000.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-05-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 37.400, 38.100, 38.100, 37.400, 564670.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('TLV', TO_TIMESTAMP('2026-04-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 37.800, 38.100, 38.340, 37.800, 1076986.0);
INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum) VALUES ('NVDA', TO_TIMESTAMP('2026-04-14 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 190.840, 196.510, 196.510, 190.770, 161307000.0);
COMMIT;

-- Tabel '07: portofoliu' - 5 inregistrari (minimul pentru tabel neasociativ)
CREATE TABLE portofoliu (
   id_portofoliu NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
   id_investitor NUMBER NOT NULL,
   nume_portofoliu VARCHAR2(100) NOT NULL,
   data_creare DATE DEFAULT SYSDATE,
   activ CHAR(1) DEFAULT 'Y' CHECK (activ IN ('Y', 'N')),

   CONSTRAINT fk_portofoliu_investitor
      FOREIGN KEY (id_investitor)
      REFERENCES investitor(id_investitor)
);
DELETE FROM portofoliu;
INSERT INTO portofoliu (id_investitor, nume_portofoliu, data_creare, activ) VALUES (1, 'Portofoliu Nicolescu 1', TO_DATE('2025-10-01', 'YYYY-MM-DD'), 'N');
INSERT INTO portofoliu (id_investitor, nume_portofoliu, data_creare, activ) VALUES (1, 'Portofoliu Nicolescu 2', TO_DATE('2026-05-10', 'YYYY-MM-DD'), 'Y');
INSERT INTO portofoliu (id_investitor, nume_portofoliu, data_creare, activ) VALUES (1, 'Portofoliu Nicolescu 3', TO_DATE('2026-05-10', 'YYYY-MM-DD'), 'Y');

INSERT INTO portofoliu (id_investitor, nume_portofoliu, data_creare, activ) VALUES (4, 'Portofoliu Iordache', TO_DATE('2026-04-15', 'YYYY-MM-DD'), 'Y');
INSERT INTO portofoliu (id_investitor, nume_portofoliu, data_creare, activ) VALUES (10, 'Portofoliu Adina', TO_DATE('2026-04-16', 'YYYY-MM-DD'), 'Y');
COMMIT;