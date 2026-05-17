-- Trebuie rulat sub user-ul SYS pentru a crea un nou user cu privilegii de DBA

CREATE USER proiect IDENTIFIED BY proiect;

GRANT DBA TO proiect;

--pentru a acorda privilegii
--GRANT CREATE SESSION TO proiect;

-- spatiu nelimitat pe tablespace-ul USERS
ALTER USER proiect QUOTA UNLIMITED ON users;
