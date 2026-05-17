# Proiect ales: Evidenta acțiuni bursiere

## Tabele

- 01: **bursa**
   - `id_bursa` (Primary Key)
   - `cod_bursa` (VARCHAR2(10), UNIQUE, NOT NULL) - ex: NYSE, DAX
   - `denumire` (VARCHAR2(100), NOT NULL)
   - `tara` (VARCHAR2(50), NOT NULL)

- 02: **moneda**
   - `cod_moneda` (Primary Key, VARCHAR2(10), NOT NULL) - ex: USD, EUR
   - `denumire` (VARCHAR2(50), NOT NULL)

- 03: **curs_valutar**
   - `id_curs` (Primary Key)
   - `cod_moneda_sursa` (Foreign Key -> moneda.cod_moneda, NOT NULL)
   - `cod_moneda_dest` (Foreign Key -> moneda.cod_moneda, NOT NULL)
   - `data_curs` (DATE, NOT NULL)
   - `valoare_curs` (NUMBER(18,6), NOT NULL, CHECK (valoare_curs > 0))
   - Constrangere unica: (`cod_moneda_sursa`, `cod_moneda_dest`, `data_curs`)

- 04: **simbol_bursier**
   - `ticker` (Primary Key, VARCHAR2(10), NOT NULL)
   - `id_companie` (Foreign Key -> companie.id_companie, NOT NULL)
   - `cod_moneda` (Foreign Key -> moneda.cod_moneda, NOT NULL)
   - `denumire_simbol` (VARCHAR2(100), NOT NULL)
   - `sector` (VARCHAR2(60))

- 05: **companie**
   - `id_companie` (Primary Key)
   - `denumire` (VARCHAR2(120), NOT NULL)
   - `cod_fiscal` (VARCHAR2(30), UNIQUE)
   - `tara_origine` (VARCHAR2(50), NOT NULL)
   - `data_listare` (DATE)

- 06: **investitor**
   - `id_investitor` (Primary Key)
   - `nume` (VARCHAR2(50), NOT NULL)
   - `prenume` (VARCHAR2(50), NOT NULL)
   - `email` (VARCHAR2(120), UNIQUE, NOT NULL)
   - `data_inregistrare` (DATE, DEFAULT SYSDATE)

- 07: **portofoliu**
   - `id_portofoliu` (Primary Key)
   - `id_investitor` (Foreign Key -> investitor.id_investitor, NOT NULL)
   - `nume_portofoliu` (VARCHAR2(100), NOT NULL)
   - `data_creare` (DATE, DEFAULT SYSDATE)
   - `activ` (CHAR(1), DEFAULT 'Y', CHECK (activ IN ('Y','N')))

- 08: **detinere_portofoliu** (tabel asociativ)
   - `id_portofoliu` (Foreign Key -> portofoliu.id_portofoliu)
   - `ticker` (Foreign Key -> simbol_bursier.ticker)
   - `cantitate` (NUMBER(14,4), NOT NULL, CHECK (cantitate >= 0))
   - `pret_mediu` (NUMBER(14,4), CHECK (pret_mediu >= 0))
   - `data_actualizare` (DATE, DEFAULT SYSDATE)
   - Primary Key compus: (`id_portofoliu`, `ticker`)

- 09: **istoric_pret**
   - `ticker` (Primary Key part, Foreign Key -> simbol_bursier.ticker, NOT NULL)
   - `data_cotatie` (Primary Key part, VARCHAR2(19), NOT NULL) - de forma YYYY-MM-DD HH:MM:SS
   - `pret_deschidere` (NUMBER(14,4), CHECK (pret_deschidere > 0))
   - `pret_inchidere` (NUMBER(14,4), CHECK (pret_inchidere > 0))
   - `pret_maxim` (NUMBER(14,4), CHECK (pret_maxim > 0))
   - `pret_minim` (NUMBER(14,4), CHECK (pret_minim > 0))
   - `volum` (NUMBER, CHECK (volum >= 0))
   - Primary Key compus: (`ticker`, `data_cotatie`)

- 10: **ordin**
   - `id_ordin` (Primary Key)
   - `id_portofoliu` (Foreign Key -> portofoliu.id_portofoliu, NOT NULL)
   - `ticker` (Foreign Key -> simbol_bursier.ticker, NOT NULL)
   - `tip_sens` (VARCHAR2(10), CHECK (tip_sens IN ('CUMPARARE','VANZARE')))
   - `tip_ordin` (VARCHAR2(10), CHECK (tip_ordin IN ('PIATA','LIMITA')))
   - `cantitate` (NUMBER(14,4), NOT NULL, CHECK (cantitate > 0))
   - `pret_limita` (NUMBER(14,4))
   - `data_ordin` (DATE, DEFAULT SYSDATE)
   - `status_ordin` (VARCHAR2(10), DEFAULT 'NOU', CHECK (status_ordin IN ('NOU','PARTIAL','EXECUTAT','ANULAT')))

- 11: **executie_ordin**
   - `id_executie` (Primary Key)
   - `id_ordin` (Foreign Key -> ordin.id_ordin, NOT NULL)
   - `id_bursa` (Foreign Key -> bursa.id_bursa, NOT NULL)
   - `cantitate_executata` (NUMBER(14,4), NOT NULL, CHECK (cantitate_executata > 0))
   - `pret_executie` (NUMBER(14,4), NOT NULL, CHECK (pret_executie > 0))
   - `data_executie` (DATE, NOT NULL)

- 12: **tranzactie_numerar**
   - `id_tranzactie` (Primary Key)
   - `id_portofoliu` (Foreign Key -> portofoliu.id_portofoliu, NOT NULL)
   - `cod_moneda` (Foreign Key -> moneda.cod_moneda, NOT NULL)
   - `tip_miscare` (VARCHAR2(15), CHECK (tip_miscare IN ('DEPOZIT','RETRAGERE','COMISION','DIVIDEND')))
   - `suma` (NUMBER(14,2), NOT NULL, CHECK (suma > 0))
   - `data_tranzactie` (DATE, DEFAULT SYSDATE)

## 1) Descrierea modelului real, utilitate, reguli de functionare

Aplicatia modeleaza evidenta actiunilor bursiere pentru investitori individuali. Sistemul pastreaza informatii despre burse, companii listate, simboluri bursiere, preturi istorice, ordine, executii, portofolii si miscari de numerar.

Utilitate:
- analizarea simbolurilor bursiere
- simularea/monitorizarea ordinelor de cumparare si vanzare;
- calculul detinerilor curente per portofoliu;
- analiza performantelor investitorilor pe perioade.

Reguli de functionare:
- un investitor poate avea mai multe portofolii;
- un portofoliu poate detine mai multe simboluri;
- un simbol apartine unei companii si are o moneda de referinta;
- ordinele se emit din portofoliu pentru un simbol si pot avea una sau mai multe executii partiale;
- preturile istorice se inregistreaza periodic pe perechea (simbol, bursa, moment).

## 2) Constrangeri (restrictii, reguli)

- toate cheile primare sunt NOT NULL;
- urmatoarele coduri sunt unice: cod_bursa, ticker, cod_moneda;
- cantitatile si preturile sunt strict pozitive;
- tip_sens in ('CUMPARARE','VANZARE');
- tip_ordin in ('PIATA','LIMITA');
- status_ordin in ('NOU','PARTIAL','EXECUTAT','ANULAT');
- data_executie >= data_ordin;
- pe istoric_pret nu se permit duplicate pentru (ticker, data_cotatie);

## 3) Entitati (cu cheia primara)

1. bursa (id_bursa)
2. moneda (cod_moneda)
3. curs_valutar (id_curs)
4. simbol_bursier (ticker)
5. companie (id_companie)
6. investitor (id_investitor)
7. portofoliu (id_portofoliu)
8. detinere_portofoliu (id_portofoliu, ticker)  -- tabel asociativ
9. istoric_pret: Primary Key compus: (ticker, data_cotatie)
10. ordin (id_ordin)
11. executie_ordin (id_executie)
12. tranzactie_numerar (id_tranzactie)

## 4) Relatii si cardinalitati

- investitor 1:N portofoliu
- companie 1:N simbol_bursier
- moneda 1:N simbol_bursier
- portofoliu N:M simbol_bursier prin detinere_portofoliu
- simbol_bursier 1:N istoric_pret
- portofoliu 1:N ordin
- simbol_bursier 1:N ordin
- ordin 1:N executie_ordin
- bursa 1:N executie_ordin
- portofoliu 1:N tranzactie_numerar
- moneda 1:N tranzactie_numerar
- moneda 1:N curs_valutar (sursa)
- moneda 1:N curs_valutar (destinatie)
- relatie de tip superior (>2): evaluare zilnica a detinerii pentru tripletul (portofoliu, ticker, data_evaluare), in moneda de raportare

## 5) Atribute importante si constrangeri

- toate cheile primare sunt NOT NULL;
- `cod_moneda` si `ticker` sunt chei naturale (PK) pentru tabelele `moneda` si `simbol_bursier`;
- `ticker` este folosit drept FK in `detinere_portofoliu`, `istoric_pret`, `ordin`;
- `cod_moneda` este folosit drept FK in `simbol_bursier`, `tranzactie_numerar`, `curs_valutar`;
- `id_bursa` este folosit drept FK in `executie_ordin`;
- `cantitate > 0` in `ordin` si `executie_ordin`;
- `cantitate >= 0` in `detinere_portofoliu`;
- `status_ordin` are domeniu controlat: `NOU`, `PARTIAL`, `EXECUTAT`, `ANULAT`.

## 6) Diagrama entitate-relatie (ERD)
In ./erd/erd_relatii.mmd

## 7) Diagrama conceptuala
In ./erd/erd_tabele.mmd

## 8) Scheme relationale

- BURSA(`id_bursa` PK, `cod_bursa` UQ, `denumire`, `tara`)
- MONEDA(`cod_moneda` PK, `denumire`)
- CURS_VALUTAR(`id_curs` PK, `cod_moneda_sursa` FK, `cod_moneda_dest` FK, `data_curs`, `valoare_curs`, UQ(`cod_moneda_sursa`,`cod_moneda_dest`,`data_curs`))
- SIMBOL_BURSIER(`ticker` PK, `id_companie` FK, `cod_moneda` FK, `denumire_simbol`, `sector`)
- COMPANIE(`id_companie` PK, `denumire`, `cod_fiscal` UQ, `tara_origine`, `data_listare`)
- INVESTITOR(`id_investitor` PK, `nume`, `prenume`, `email` UQ, `data_inregistrare`)
- PORTOFOLIU(`id_portofoliu` PK, `id_investitor` FK, `nume_portofoliu`, `data_creare`, `activ`)
- DETINERE_PORTOFOLIU(`id_portofoliu` PK/FK, `ticker` PK/FK, `cantitate`, `pret_mediu`, `data_actualizare`)
- ISTORIC_PRET(`ticker` PK/FK, `data_cotatie` PK, `pret_deschidere`, `pret_inchidere`, `pret_maxim`, `pret_minim`, `volum`)
- ORDIN(`id_ordin` PK, `id_portofoliu` FK, `ticker` FK, `tip_sens`, `tip_ordin`, `cantitate`, `pret_limita`, `data_ordin`, `status_ordin`)
- EXECUTIE_ORDIN(`id_executie` PK, `id_ordin` FK, `id_bursa` FK, `cantitate_executata`, `pret_executie`, `data_executie`)
- TRANZACTIE_NUMERAR(`id_tranzactie` PK, `id_portofoliu` FK, `cod_moneda` FK, `tip_miscare`, `suma`, `data_tranzactie`)

## 9) Normalizare pana la FN3 (FN1-FN3)

- Exemplu non-FN1: camp `simboluri_lista` in `ordin` (valoare multipla in acelasi atribut).
- Transformare FN1: in `ordin` ramane un singur `ticker`; pentru mai multe simboluri se folosesc ordine distincte.

- Exemplu non-FN2: in `detinere_portofoliu` ar fi adaugat `denumire_companie` (depinde doar de `ticker`).
- Transformare FN2: `denumire_companie` ramane in `companie`; `detinere_portofoliu` pastreaza doar atribute dependente de cheia compusa (`id_portofoliu`, `ticker`).

- Exemplu non-FN3: in `investitor` s-ar stoca `domeniu_email` derivabil din `email`.
- Transformare FN3: `domeniu_email` nu se stocheaza, se calculeaza la interogare.

## 10) Secventa utilizata la inserare

Pentru toate tabelele cu PK numeric se va folosi o secventa comuna:
- `seq_global_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE`

Cheile naturale `cod_moneda` si `ticker` se insereaza direct (fara secventa).

## 11) Crearea tabelelor si inserarea datelor

Reguli de date de test:
- minimum 5 inregistrari in fiecare tabel neasociativ;
- minimum 10 inregistrari in tabelul asociativ `detinere_portofoliu`;
- maximum 30 inregistrari in fiecare tabel.

Datele vor fi coerente temporal si logic:
- `data_executie >= data_ordin`;
- `cod_moneda` existent in `moneda` pentru orice referinta in celelalte tabele;
- `ticker` existent in `simbol_bursier` pentru orice referinta in celelalte tabele.

## 12) Cinci cereri SQL complexe (enunt in limbaj natural)

1. Afisati portofoliile active care au valoarea totala curenta peste media valorilor tuturor portofoliilor active (subcereri sincronizate, cel putin 3 tabele).
2. Afisati pentru fiecare `ticker` media lunara a volumului tranzactionat, folosind subcerere nesincronizata in `FROM`.
3. Afisati exchange-urile la care numarul de executii este peste media globala, cu `GROUP BY`, functii de grup si filtrare in `HAVING` cu subcerere.
4. Afisati ordinele, ordonate dupa prioritate, folosind in aceeasi cerere `NVL` si `DECODE`.
5. Cu `WITH`, afisati evolutia trimestriala pe simbol, folosind cel putin 2 functii pe siruri, 2 functii pe date si o expresie `CASE`.

## 13) Trei operatii UPDATE/DELETE cu subcereri

1. `UPDATE` status ordine la `ANULAT` pentru ordine fara executii mai vechi de 30 zile.
2. `UPDATE` `pret_mediu` in `detinere_portofoliu` pe baza pretului mediu ponderat din `executie_ordin`.
3. `DELETE` din `istoric_pret` pentru inregistrari mai vechi de un prag temporal, doar pentru simboluri inactive identificate prin subcerere.

## 14) Vizualizare complexa + operatii LMD permise/nepermise

Vizualizare propusa: `vw_rezumat_portofoliu`
- combina `portofoliu`, `investitor`, `detinere_portofoliu`, `simbol_bursier`, `istoric_pret` (agregat pe ultimul pret).

Exemplu LMD permis:
- `UPDATE` pe `nume_portofoliu` prin view, daca mapping-ul este pe randuri cheie-pastrate.

Exemplu LMD nepermis:
- `INSERT` direct intr-o view cu agregari si join multiplu, fara trigger `INSTEAD OF`.

## 15) Outer join, division, top-n (cereri diferite fata de punctul 12)

- Outer join pe minimum 4 tabele: investitor -> portofoliu -> ordin -> executie_ordin (left joins) pentru a include si ordine fara executie.
- Division: investitorii care au tranzactionat toate simbolurile dintr-un sector dat.
- Top-N: primele 5 simboluri dupa cresterea procentuala in ultimele 30 zile.

## 16) Optimizare / plan de executie

Varianta aleasa: 16.b (plan de executie)
- se analizeaza o cerere complexa din punctul 12;
- `EXPLAIN PLAN` + `DBMS_XPLAN.DISPLAY`;
- comparatie intre plan initial si plan dupa adaugarea de indexuri;
- optional comparatie cu hint-uri (`USE_HASH`, `INDEX`) si justificare.

## 17) BCNF, FN4, FN5 si denormalizare

- BCNF: verificare dependente functionale in tabele cu chei compuse (`detinere_portofoliu`).
- FN4: analiza dependentelor multivaloare (ex. preferinte multiple independente ale investitorului).
- FN5: analiza decompozitiilor fara pierdere pentru relatii complexe.
- Denormalizare justificata: tabel de raportare zilnica pentru valoare portofoliu, pentru raspuns rapid in dashboard.

## 18) Isolation levels (tranzactii concurente)

Se vor demonstra, in sesiuni paralele Oracle:
- `READ COMMITTED` (posibil non-repeatable read);
- `SERIALIZABLE` (izolare mai stricta, concurenta mai redusa).

Exemplele vor folosi operatii concurente pe aceeasi detinere si pe aceleasi ordine.

## 19) Justificarea migrarii la NoSQL

Argumente:
- ingestie rapida pentru fluxuri mari de cotatii intraday;
- schema flexibila pentru surse multiple de date de piata;
- permite sharding pentru scalare orizontala rapida

a) Structura NoSQL (exemplu document):
- colectie `cotatii_intraday` cu documente: `ticker`, `exchange`, `timestamp`, `open`, `high`, `low`, `close`, `volume`.

b) Comenzi creare baza/colectii:
- creare baza si colectii dedicate cotatiilor si evenimentelor de ordin.

c) Comenzi inserare/modificare/stergere:
- `insertOne`/`insertMany`, `updateOne`/`updateMany`, `deleteOne`/`deleteMany`.

d) Interogare date cu filtrare/sortare:
- `find` cu filtre pe interval temporal si `sort` pe `timestamp` sau `volume`.

## 20) Cerinta flexibila

Propunere: sistem de alertare pentru anomalii de pret.
- detectie de variatii peste un prag procentual;
- inregistrare alerte si asociere cu simbolul si momentul;
- comparatie performanta intre detectie in SQL si abordare NoSQL pentru date intraday.
    