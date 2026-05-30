-- top 2 investitori dupa nr de ordine efectuate
SELECT * FROM investitor;

CREATE OR REPLACE VIEW v_investitori_activi AS
SELECT
   i.nume || ' ' || i.prenume AS nume_complet,
   p.id_portofoliu,
   o.id_ordin
FROM investitor i
JOIN portofoliu p ON p.id_investitor = i.id_investitor
JOIN ordin o ON o.id_portofoliu = p.id_portofoliu;

-- listare
SELECT * from v_investitori_activi;

-- group by id_portofoliu si insumeaza nr. de ordine
SELECT nume_complet, id_portofoliu, SUM(id_ordin) AS nr_ordine_total
FROM v_investitori_activi
GROUP BY nume_complet, id_portofoliu
ORDER BY nr_ordine_total DESC
FETCH FIRST 2 ROWS ONLY;
