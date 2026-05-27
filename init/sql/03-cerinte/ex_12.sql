/*
12. [_] Formulați în limbaj natural și implementați 5 cereri SQL complexe ce vor utiliza, în ansamblul lor, următoarele elemente: 
    - [_] a\) subcereri sincronizate în care intervin cel puțin 3 tabele
    - [_] b\) subcereri nesincronizate în clauza FROM
    - [_] c\) grupări de date, funcții grup, filtrare la nivel de grupuri cu subcereri nesincronizate (în clauza de HAVING)
    - [_] d\) ordonări și utilizarea funcțiilor NVL și DECODE (în cadrul aceleiași cereri)
    - [_] e\) utilizarea a cel puțin 2 funcții pe șiruri de caractere, 2 funcții pe date calendaristice,  a cel puțin unei expresii CASE
    - [_] f\) utilizarea a cel puțin 1 bloc de cerere (clauza WITH)
    - Observație: Într-o cerere se vor regăsi mai multe elemente dintre cele enumerate mai sus, astfel încât cele 5 cereri să le cuprindă pe toate. 
*/

/*
12. a) Arata portofoliile ale caror valoare este peste valoare medie a tuturor portofoliilor
*/
-- SELECT * 
-- FROM portofoliu p JOIN detinere_portofoliu dp ON p.id_portofoliu = dp.id_portofoliu

-- SELECT p.id_portofoliu, p.nume_portofoliu, dp.cantitate, dp.pret_mediu, (dp.cantitate * dp.pret_mediu) AS valoare_linie
-- FROM portofoliu p 
-- JOIN detinere_portofoliu dp ON p.id_portofoliu = dp.id_portofoliu;

-- Suma per portofoliu (DEBUG QUERY)
SELECT dp.id_portofoliu, SUM(dp.cantitate * dp.pret_mediu) AS valoare_portofoliu
FROM detinere_portofoliu dp
GROUP BY dp.id_portofoliu;

-- Cerinta
SELECT p.id_portofoliu, p.nume_portofoliu, x.valoare_portofoliu
FROM portofoliu p
JOIN (
   SELECT dp.id_portofoliu, SUM(dp.cantitate * dp.pret_mediu) AS valoare_portofoliu
   FROM detinere_portofoliu dp
   GROUP BY dp.id_portofoliu
) x 
ON x.id_portofoliu = p.id_portofoliu
WHERE x.valoare_portofoliu > (
   SELECT AVG(y.valoare_portofoliu)
   FROM (
      SELECT dp2.id_portofoliu, SUM(dp2.cantitate * dp2.pret_mediu) AS valoare_portofoliu
      FROM detinere_portofoliu dp2
      GROUP BY dp2.id_portofoliu
   ) y
)
ORDER BY x.valoare_portofoliu DESC;

/*
12. b) Pentru fiecare ticker, afiseaza media lunara a volumului tranzactionat.
   Cerinta tehnica: subcerere NESINCRONIZATA in clauza FROM.
*/
-- Join -> tabel de volum avg per ticker + luna (YYYY-MM) -> grupare si sortare descending dupa volum
SELECT sb.ticker, TO_CHAR(ip.data_cotatie, 'YYYY-MM') AS luna, AVG(ip.volum) AS volum_mediu
FROM simbol_bursier sb
JOIN istoric_pret ip ON sb.ticker = ip.ticker
GROUP BY sb.ticker, TO_CHAR(ip.data_cotatie, 'YYYY-MM')
ORDER BY sb.ticker, luna;

-- Cerinta
SELECT s.ticker, s.denumire_simbol, m.luna, m.volum_mediu
FROM simbol_bursier s
JOIN (
   SELECT ticker, TRUNC(data_cotatie, 'MM') AS luna, AVG(volum) AS volum_mediu
   FROM istoric_pret
   GROUP BY ticker, TRUNC(data_cotatie, 'MM')
) m ON m.ticker = s.ticker
ORDER BY s.ticker, m.luna;

/*
12. c) Afiseaza bursele la care numarul de executii este peste media globala a numarului de executii pe bursa.
   Cerinte tehnice: GROUP BY, functii de grup, filtrare in HAVING cu subcerere nesincronizata.
*/
-- Genereaza numar executii per bursa din istoric_pret
SELECT sb.id_bursa, SUM(ip.volum) AS volum_bursa
FROM istoric_pret ip
JOIN simbol_bursier sb ON ip.ticker = sb.ticker
GROUP BY sb.id_bursa;

-- Genereaza media globala a volumului de executii per bursa
SELECT AVG(x.volum_bursa) AS medie_volum_bursa
FROM (
  SELECT sb.id_bursa, SUM(ip.volum) AS volum_bursa
  FROM istoric_pret ip
  JOIN simbol_bursier sb ON ip.ticker = sb.ticker
  GROUP BY sb.id_bursa
) x;

-- Cerinta
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

/*
12. d) Afiseaza ordinele ordonate dupa prioritate de business.
   Cerinte tehnice: ORDER BY + NVL + DECODE in aceeasi cerere.
*/

-- Cerinta
SELECT o.id_ordin, o.id_portofoliu, o.ticker, o.tip_sens,
   o.tip_ordin, o.status_ordin, o.cantitate,
   NVL(o.pret_limita, 0) AS pret_limita_afisat,
   o.data_ordin,
   DECODE(o.status_ordin,
      'NOU', 1,
      'PARTIAL', 2,
      'EXECUTAT', 3,
      'ANULAT', 4,
      9
   ) AS prioritate_status,
   DECODE(o.tip_ordin,
      'PIATA', 1,
      'LIMITA', 2,
      9
   ) AS prioritate_tip
FROM ordin o
ORDER BY
   DECODE(o.status_ordin,
      'NOU', 1,
      'PARTIAL', 2,
      'EXECUTAT', 3,
      'ANULAT', 4,
      9
   ),
   DECODE(o.tip_ordin,
      'PIATA', 1,
      'LIMITA', 2,
      9
   ),
   NVL(o.pret_limita, 999999),
   o.data_ordin DESC;

/*
12. e) + 12. f) Afiseaza evolutia trimestriala pe simbol bursier.
   Cerinte tehnice:
   - cel putin 2 functii pe siruri de caractere (ex: UPPER, SUBSTR);
   - cel putin 2 functii pe date calendaristice (ex: TRUNC, EXTRACT, ADD_MONTHS, TO_CHAR);
   - cel putin o expresie CASE;
   - cel putin un bloc WITH (CTE).
*/

-- Cerinta
WITH trimestrial AS (
   SELECT
      ip.ticker,
      TRUNC(ip.data_cotatie, 'Q') AS trimestru_start, -- functie pe data #1
      AVG(ip.pret_deschidere) AS avg_open,
      AVG(ip.pret_inchidere) AS avg_close
   FROM istoric_pret ip
   GROUP BY ip.ticker, TRUNC(ip.data_cotatie, 'Q')
)
SELECT
   t.ticker,
   UPPER(SUBSTR(sb.denumire_simbol, 1, 12)) AS simbol_scurt, -- functii pe siruri #1 #2
   TO_CHAR(t.trimestru_start, 'YYYY-"Q"Q') AS trimestru_txt,  -- functie pe data #2
   EXTRACT(YEAR FROM t.trimestru_start) AS an_trimestru,      -- functie pe data #3
   TO_CHAR(ADD_MONTHS(t.trimestru_start, 2), 'Mon YYYY') AS luna_final_trimestru, -- functie pe data #4
   ROUND(t.avg_open, 4) AS pret_mediu_deschidere,
   ROUND(t.avg_close, 4) AS pret_mediu_inchidere,
   ROUND((t.avg_close - t.avg_open) / NULLIF(t.avg_open, 0) * 100, 2) AS variatie_pct,
   CASE
      WHEN t.avg_close > t.avg_open THEN 'CRESTERE'
      WHEN t.avg_close < t.avg_open THEN 'SCADERE'
      ELSE 'STAGNARE'
   END AS trend_trimestrial
FROM trimestrial t
JOIN simbol_bursier sb
  ON sb.ticker = t.ticker
ORDER BY t.ticker, t.trimestru_start;