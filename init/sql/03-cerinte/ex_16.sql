/*
16. Prezentarea planului de execuție a unei cereri complexe, optimizare/compare plan alternativ folosind hint-uri și obiecte specifice optimizării cererilor (spre exemplu indexi).
*/


-- Varianta 1: Neoptimizata
-- Afiseaza bursele la care numarul de executii (volum total) este peste media globala a numarului de executii pe bursa.
EXPLAIN PLAN SET STATEMENT_ID = 'EX16_BEFORE' FOR
SELECT x.id_bursa, x.volum_bursa, b.denumire
FROM (
   SELECT sb.id_bursa, SUM(ip.volum) AS volum_bursa
   FROM istoric_pret ip
   JOIN simbol_bursier sb ON ip.ticker = sb.ticker
   GROUP BY sb.id_bursa
) x
JOIN bursa b ON x.id_bursa = b.id_bursa
WHERE x.volum_bursa > (
   SELECT AVG(y.volum_bursa) AS medie_volum_bursa
   FROM (
      SELECT sb2.id_bursa, SUM(ip2.volum) AS volum_bursa
      FROM istoric_pret ip2
      JOIN simbol_bursier sb2 ON ip2.ticker = sb2.ticker
      GROUP BY sb2.id_bursa
   ) y
);

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'EX16_BEFORE', 'BASIC +COST +ROWS +BYTES +PREDICATE'));


/*
Varianta 2: Optimizata
Afiseaza bursele la care numarul de executii (volum total) este peste media globala a numarului de executii pe bursa.
Optimizari: 
1. Index pe istoric_pret(ticker) pentru a accelera join-ul
2. Index pe simbol_bursier(id_bursa) pentru a accelera gruparea
3. WITH pentru a calcula o singura data volumul pe bursa, evitand dublarea calculului in subinterogare
*/

-- Sterge indexii existenti 
BEGIN 
   EXECUTE IMMEDIATE 'DROP INDEX idx_ip_ticker';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN -- ORA-01418: specified index does not exist
         RAISE;
      END IF;
END;
/

BEGIN 
   EXECUTE IMMEDIATE 'DROP INDEX idx_sb_id_bursa';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -1418 THEN -- ORA-01418: specified index does not exist
         RAISE;
      END IF;
END;
/

-- Creaza index
BEGIN
   EXECUTE IMMEDIATE 'CREATE INDEX idx_ip_ticker ON istoric_pret(ticker)';
   EXECUTE IMMEDIATE 'CREATE INDEX idx_sb_id_bursa ON simbol_bursier(id_bursa)';
END;
/


EXPLAIN PLAN SET STATEMENT_ID = 'EX16_AFTER' FOR
WITH volum_pe_bursa AS (
   SELECT sb.id_bursa, SUM(ip.volum) AS volum_bursa
   FROM istoric_pret ip
   JOIN simbol_bursier sb ON ip.ticker = sb.ticker
   GROUP BY sb.id_bursa
)
SELECT v.id_bursa, v.volum_bursa, b.denumire
FROM volum_pe_bursa v
JOIN bursa b ON v.id_bursa = b.id_bursa
WHERE v.volum_bursa > (
   SELECT AVG(volum_bursa) AS medie_volum_bursa
   FROM volum_pe_bursa
);

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'EX16_AFTER', 'BASIC +COST +ROWS +BYTES +PREDICATE'));