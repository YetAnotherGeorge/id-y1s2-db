-- ruleaza pentru a genera alerta de inserare in istoric pret

CREATE OR REPLACE VIEW istoric_pret_ins AS
SELECT 
   ip.ticker, 
   ip.data_cotatie + INTERVAL '1' DAY AS data_cotatie, 
   ip.pret_deschidere + 50 AS pret_deschidere,
   ip.pret_inchidere + 50 AS pret_inchidere,
   ip.pret_maxim + 50 AS pret_maxim,
   ip.pret_minim + 50 AS pret_minim,
   ip.volum + 1000 AS volum
FROM istoric_pret ip
ORDER BY ticker, data_cotatie DESC
FETCH FIRST 1 ROW ONLY;

-- SELECT * FROM istoric_pret_ins;

INSERT INTO istoric_pret (ticker, data_cotatie, pret_deschidere, pret_inchidere, pret_maxim, pret_minim, volum)
SELECT * FROM istoric_pret_ins;
COMMIT;

DELETE FROM istoric_pret
WHERE (ticker, data_cotatie) IN (SELECT ticker, data_cotatie - INTERVAL '1' DAY as data_cotatie FROM istoric_pret_ins);

DROP VIEW istoric_pret_ins;
COMMIT;



-- DEBUG: ce trebuie rulat pt calcul avg price change percent
-- SELECT pret_inchidere
-- FROM istoric_pret 
-- WHERE ticker='AAPL' 
-- ORDER by data_cotatie DESC FETCH FIRST 2 ROWS ONLY;