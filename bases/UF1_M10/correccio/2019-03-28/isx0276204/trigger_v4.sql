CREATE OR REPLACE FUNCTION v4() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	linia1 record;
	id_pacient int := 0;
	valoracio  int := 0;
	num_rep bigint := 0; 
BEGIN
	num_rep := NEW.num_rep ;
	IF num_rep != 1 THEN 
		INSERT INTO resultats_patologics VALUES(NEW.id_resultat,current_timestamp,current_user);
	END IF;
RETURN new;
END;
$BODY$ 
LANGUAGE plpgsql;
/*Creació del TRIGGER: */

CREATE TRIGGER v4 BEFORE INSERT OR UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE v4();

-- CORRECCIÓ
1) no has entergat proves i resultats
2) què passa si ja existix registre a resultats_patologics????
