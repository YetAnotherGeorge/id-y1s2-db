/*
17. 2 Task-uri: 
   - a. Realizarea normalizării BCNF, FN4, FN5.
   - b. Aplicarea denormalizării, justificând necesitatea acesteia.
*/

-- tabelul test_01 va fi ignorat

-- Selecteaza toate tabelele
SELECT table_name FROM user_tables ORDER BY table_name;

SELECT * FROM BURSA FETCH FIRST 5 ROWS ONLY;
SELECT * FROM COMPANIE FETCH FIRST 5 ROWS ONLY;
SELECT * FROM CURS_VALUTAR FETCH FIRST 5 ROWS ONLY;
SELECT * FROM DETINERE_PORTOFOLIU FETCH FIRST 5 ROWS ONLY;
SELECT * FROM EXECUTIE_ORDIN FETCH FIRST 5 ROWS ONLY;
SELECT * FROM INVESTITOR FETCH FIRST 5 ROWS ONLY;
SELECT * FROM ISTORIC_PRET FETCH FIRST 5 ROWS ONLY;
SELECT * FROM MONEDA FETCH FIRST 5 ROWS ONLY;
SELECT * FROM ORDIN FETCH FIRST 5 ROWS ONLY;
SELECT * FROM PORTOFOLIU FETCH FIRST 5 ROWS ONLY;
SELECT * FROM SIMBOL_BURSIER FETCH FIRST 5 ROWS ONLY;
SELECT * FROM TRANZACTIE_NUMERAR FETCH FIRST 5 ROWS ONLY;

-- structura este deja FN1, FN2, FN3 (cerinta 3)
-- structura este deja BCNF, fiecare dependenta non triviala X -> Y are X ca super cheie
-- structura este deja FN4, nu exista multi dependente 
-- structura este deja FN5
-- => punctul a) este indeplinit: FN5 este satisfacut

/*
Analiza BCNF, FN4, FN5:

Chei candidate / determinanti (conform PK/UK din model):
- BURSA: id_bursa -> (cod_bursa, denumire, tara), iar cod_bursa este unic
- MONEDA: cod_moneda -> denumire
- COMPANIE: id_companie -> (denumire, cod_fiscal, tara_origine, data_listare), iar cod_fiscal este unic
- SIMBOL_BURSIER: ticker -> (id_companie, id_bursa, denumire_simbol, sector)
- INVESTITOR: id_investitor -> (nume, prenume, email, data_inregistrare), iar email este unic
- PORTOFOLIU: id_portofoliu -> (id_investitor, nume_portofoliu, data_creare, activ)
- DETINERE_PORTOFOLIU: (id_portofoliu, ticker) -> (cantitate, pret_mediu, data_actualizare)
- ORDIN: id_ordin -> (id_portofoliu, ticker, tip_sens, tip_ordin, cantitate, pret_limita, data_ordin, status_ordin)
- EXECUTIE_ORDIN: id_executie -> (id_ordin, cantitate_executata, pret_executie, moment_executie)
- TRANZACTIE_NUMERAR: id_tranzactie -> (id_portofoliu, cod_moneda, tip_miscare, suma, data_tranzactie)
- CURS_VALUTAR: (cod_moneda_baza, cod_moneda_cotata, data_curs) -> rata
- ISTORIC_PRET: (ticker, data_pret) -> (pret_deschidere, pret_inchidere, volum)

Concluzie:
- BCNF: determinantii nenetriviali sunt superchei/candidate.
- FN4: nu exista dependente multivaluate independente in aceeasi relatie.
- FN5: nu exista dependente de join nenetriviale care sa impuna descompuneri suplimentare.
*/


-- punctul b) denormalizare:

-- 1. INVESTITOR + 2. PORTOFOLIU -> id_investitor dispare
CREATE OR REPLACE VIEW v_glob_1 AS
SELECT 
   i.nume || ' ' || i.prenume AS nume_complet,
   i.email,
   i.data_inregistrare AS i_data_inregistrare,
   p.id_portofoliu,
   p.NUME_PORTOFOLIU as p_nume, 
   p.data_creare as p_data_creare,
   p.activ as p_activ
FROM investitor i
JOIN portofoliu p ON i.id_investitor = p.id_investitor;
-- SELECT * FROM v_glob_1 FETCH FIRST 5 ROWS ONLY;

-- 3. DETINERE_PORTOFOLIU + 4. ORDIN + 5. TRANZACTIE_NUMERAR -> id_portofoliu dispare
CREATE OR REPLACE VIEW v_glob_2 AS
SELECT ip.nume_complet, ip.email, ip.i_data_inregistrare, ip.p_nume, ip.p_data_creare, ip.p_activ,
   dp.ticker, dp.cantitate, dp.pret_mediu, dp.data_actualizare AS dp_data_actualizare,
   o.id_ordin AS o_id, o.tip_sens AS o_tip_sens, o.tip_ordin AS o_tip_ordin, o.cantitate AS o_cantitate, o.pret_limita AS o_pret_limita, o.data_ordin, o.status_ordin,
   tn.cod_moneda, tn.tip_miscare, tn.suma AS tn_suma, tn.data_tranzactie AS tn_data_tranzactie
FROM v_glob_1 ip
JOIN detinere_portofoliu dp ON ip.id_portofoliu = dp.id_portofoliu
JOIN ordin o ON ip.id_portofoliu = o.id_portofoliu
JOIN tranzactie_numerar tn ON ip.id_portofoliu = tn.id_portofoliu;
SELECT * FROM v_glob_2 FETCH FIRST 5 ROWS ONLY;

-- 6. MONEDA + 7. SIMBOL_BURSIER + 8. BURSA + 9. COMPANIE + 10. Executie ordin
CREATE OR REPLACE VIEW v_glob_3 AS
SELECT 
   g2.*, 
   m.denumire AS moneda_denumire,
   sb.id_companie, sb.denumire_simbol, sb.sector,
   b.cod_bursa, b.denumire AS bursa_denumire, b.tara AS bursa_tara,
   c.denumire AS companie_denumire, c.cod_fiscal AS companie_cod_fiscal, c.tara_origine AS companie_tara_origine, c.data_listare AS companie_data_listare
FROM v_glob_2 g2
JOIN moneda m ON g2.cod_moneda = m.cod_moneda
JOIN simbol_bursier sb ON g2.ticker = sb.ticker
JOIN bursa b ON sb.id_bursa = b.id_bursa
JOIN companie c ON sb.id_companie = c.id_companie
JOIN executie_ordin eo ON g2.o_id = eo.id_ordin;

-- SELECT COUNT(*) AS total_inregistrari FROM v_glob_3;
SELECT * FROM v_glob_3 FETCH FIRST 5 ROWS ONLY;
-- DROP VIEW v_glob_1;

-- In prezent: v_glob_3 contine toate detinerile unui investitor + date companie + date bursa
-- impreuna cu tabelele CURS_VALUTAR, ISTORIC_PRET -> se regasesc toate datele 

/*
b) Justificare denormalizare: daca ar fi nevoie sa antrenam un model neuronal care sa prezica urmatorul ordin al unui 
investitor folosind spre ex. CatBoost, am avea nevoie de toate aceste date intr-un singur tabel pentru a putea antrena modelul
*/

-- Cleanup
DROP VIEW v_glob_3;
DROP VIEW v_glob_2;
DROP VIEW v_glob_1;