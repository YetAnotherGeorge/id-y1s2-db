-- RUN as SYSDBA
GRANT EXECUTE ON DBMS_ALERT TO proiect;

-- BEGIN
-- 	DBMS_ALERT.SIGNAL('ISTORIC_PRET_INS', 'new row inserted');
-- END;
-- /

CREATE OR REPLACE TRIGGER proiect.trg_istoric_pret_alert_ai
AFTER INSERT ON proiect.istoric_pret
FOR EACH ROW
BEGIN
	DBMS_ALERT.SIGNAL(
		'ISTORIC_PRET_INS',
		'ticker=' || :NEW.ticker || ', data=' || TO_CHAR(:NEW.data_cotatie, 'YYYY-MM-DD HH24:MI:SS')
	);
END;
/

COMMIT;

