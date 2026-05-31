Cerinta: sistem de alertare pentru anomalii de pret.

1. Detectie de variatii peste un prag procentual - SQL + NodeJS
- Rezolvare: in SQL s-a calculat variatia pretului intre inregistrari consecutive (per ticker), iar in NodeJS s-a aplicat pragul procentual si s-au marcat valorile anormale.

2. Inregistrare alerte si asociere cu simbolul si momentul - SQL + NodeJS
- Rezolvare: inserarile in istoric_pret sunt urmarite prin DBMS_ALERT (trigger + SIGNAL), iar listener-ul din NodeJS primeste evenimentul si poate salva/afisa alerta cu ticker si timestamp.

3. Analiza diferente structura intre detectie in SQL si abordare NoSQL pentru date intraday
- Rezolvare: in SQL modelul este relational (join-uri, ferestre analitice, tranzactii stricte), iar logica de detectie este centrata pe interogari deterministe pe seturi de date ordonate temporal.

Abordare echivalenta in MongoDB (in loc de Oracle SQL)
- Datele ar fi stocate in colectii (ex: istoric_pret), cu documente care contin ticker, timestamp si preturi.
- Detectia de anomalii s-ar face prin aggregation pipeline (sort pe ticker+timestamp, calcul diferenta procentuala intre documente consecutive).
- Alertarea in timp real s-ar implementa cu Change Streams (watch pe colectie), in loc de DBMS_ALERT.
- Persistenta alertelor s-ar face intr-o colectie dedicata (ex: alerte_pret), cu campuri pentru ticker, tip anomalie, valoare detectata si moment.