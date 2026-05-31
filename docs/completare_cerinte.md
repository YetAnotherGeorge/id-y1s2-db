### Status completare: 

1. [DONE] Descrierea modelului real, a utilității acestuia și a regulilor de funcționare.
2. [DONE] Prezentarea constrângerilor (restricții, reguli) impuse asupra modelului.
3. [DONE] Descrierea entităților, incluzând precizarea cheii primare.
4. [DONE] Descrierea relațiilor, incluzând precizarea cardinalității acestora.
5. [DONE] Descrierea atributelor, incluzând tipul de date și eventualele constrângeri, valori implicite, valori posibile ale atributelor.
6. [DONE] Realizarea diagramei entitate-relație corespunzătoare descrierii de la punctele 3-5. 
7. [DONE] Realizarea diagramei conceptuale corespunzătoare diagramei entitate-relație proiectate la punctul 6. Diagrama conceptuală obținută trebuie să conțină minimum 7 tabele (fără considerarea subentităților), dintre care cel puțin un tabel asociativ.
8. [DONE] Enumerarea schemelor relaționale corespunzătoare diagramei conceptuale proiectate la punctul 7.
> Rezolvare: Scheme relationale in descriere_proiect.md
9. [DONE] Realizarea normalizării până la forma normală 3 (FN1-FN3).
> Rezolvare: Sectiunea 9 din descriere_proiect.md
10. [DONE] Crearea unei secvențe ce va fi utilizată în inserarea înregistrărilor în tabele (punctul 11).
> Rezolvare: init/sql/02-tabele/02-phase0-seq_global_id.sql
11. [DONE] Crearea tabelelor în SQL și inserarea de date coerente în fiecare dintre acestea (minimum 5 înregistrări în fiecare tabel neasociativ; minimum 10 înregistrări în tabelele asociative; maxim 30 de înregistrări în fiecare tabel). 
12. [DONE] Formulați în limbaj natural și implementați 5 cereri SQL complexe ce vor utiliza, în ansamblul lor, următoarele elemente: 
    - [DONE] a\) subcereri sincronizate în care intervin cel puțin 3 tabele
    - [DONE] b\) subcereri nesincronizate în clauza FROM
    - [DONE] c\) grupări de date, funcții grup, filtrare la nivel de grupuri cu subcereri nesincronizate (în clauza de HAVING)
    - [DONE] d\) ordonări și utilizarea funcțiilor NVL și DECODE (în cadrul aceleiași cereri)
    - [DONE] e\) utilizarea a cel puțin 2 funcții pe șiruri de caractere, 2 funcții pe date calendaristice,  a cel puțin unei expresii CASE
    - [DONE] f\) utilizarea a cel puțin 1 bloc de cerere (clauza WITH)
    - Observație: Într-o cerere se vor regăsi mai multe elemente dintre cele enumerate mai sus, astfel încât cele 5 cereri să le cuprindă pe toate. 
13. [DONE] Implementarea a 3 operații de actualizare și de suprimare a datelor utilizând subcereri.
14. [DONE] Crearea unei vizualizări complexe. Dați un exemplu de operație LMD permisă pe vizualizarea respectivă și un exemplu de operație LMD nepermisă.
15. [DONE] Formulați în limbaj natural și implementați în SQL: 
    - [DONE] o cerere ce utilizează operația outer-join pe minimum 4 tabele, 
    - [DONE] o cerere ce utilizează operația division 
    - [DONE] și o cerere care implementează analiza top-n.
    - Observație: Cele 3 cereri sunt diferite de cererile de la exercițiul 12.
16. [DONE] La alegere: 
    - [_] a\) Optimizarea unei cereri, aplicând regulile de optimizare ce derivă din proprietățile operatorilor algebrei relaționale. Cererea va fi exprimată prin expresie algebrică, arbore algebric și limbaj (SQL), atât anterior cât și ulterior optimizării.
    - [DONE] sau b\) Prezentarea planului de execuție a unei cereri complexe, optimizare/compare plan alternativ folosind hint-uri și obiecte specifice optimizării cererilor (spre exemplu indexi).
> Rezolvare: init/sql/03-cerinte/ex_16.sql + sectiunea 16 din descriere_proiect.md
17. 2 Task-uri: 
    - [DONE] a. Realizarea normalizării BCNF, FN4, FN5.
    - [DONE] b. Aplicarea denormalizării, justificând necesitatea acesteia.
18. [DONE] Exemplificarea isolation levels prin exemple de tranzacții care se execută în paralel în condiții de concurență, evidențiind efectele diferitelor niveluri de izolare asupra concurenței și integrității datelor.
    - Rezolvare: init/sql/03-cerinte/ex_18_01.sql, ex_18_02.sql
19. [DONE] Justificarea necesități/utilității migrării la o bază de date de tip NoSql. Identificarea scenariilor în care utilizarea unei baze de date NoSQL este mai avantajoasă decât a unei baze de date relaționale.
    - [DONE] a\) Prezentarea structurii baze de date de tip NoSql.
    - [DONE] b\) Prezentarea comenzilor pentru crearea bazei de date (spre exemplu a colecțiilor într-o bază de date de tip document)
    - [DONE] c\) Prezentarea comenzilor pentru inserarea, modificarea și ștergerea documentelor sau înregistrărilor într-o bază de date NoSQL.
    - [DONE] d\) Exemplificarea comenzilor pentru interogarea datelor, incluzând operațiuni de filtrare și sortare.
    - Rezolvare: init/sql/03-cerinte/ex_19_mongo/ex_19_nosql_mongodb.md + init/sql/03-cerinte/ex_19_mongo/docker-compose.yaml
20. [DONE] Cerință rezervată (flexibilă) pentru alte concepte studiate relevant pentru dezvoltarea aplicațiilor cu suport pentru baze de date.

### Status generare tabele:

[DONE] bursa
[DONE] moneda
[DONE] curs_valutar
[DONE] simbol_bursier
[DONE] companie
[DONE] investitor
[DONE] portofoliu
[DONE] detinere_portofoliu
[DONE] istoric_pret
[DONE] ordin
[DONE] executie_ordin
[DONE] tranzactie_numerar