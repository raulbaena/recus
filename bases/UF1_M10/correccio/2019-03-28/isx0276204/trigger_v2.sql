CREATE OR REPLACE FUNCTION v2() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	up1 varchar := '';
	linia1 record;
	id_prova bigint := 0;
	id_resultat bigint := 0;
	num_rep bigint := 2;
	resultat varchar := '';
	id_analitica bigint := 0;

BEGIN
	id_resultat := NEW.id_resultat ;
	id_analitica := NEW.id_analitica ;
	resultat := new.resultat ;
	id_prova := NEW.id_prova ;
	
	sql1 := 'select * from resultats where id_prova = ' 
	|| id_prova
	|| 'and id_analitica = '
	|| id_analitica
	|| ';';
	for linia1 in execute sql1 loop
		if resultat != linia1.resultat or resultat = null then
			up1 := 'insert into resultats values( default ,'''
				|| resultat
				||''','
				|| id_analitica
				||','
				|| id_prova
				|| ','
				|| num_rep
				||');'
				;
			raise notice '%',up1;
			execute up1;
		end if;
		
	end loop; 
RETURN null;
END;
$BODY$ 
LANGUAGE plpgsql;
/*Creació del TRIGGER: */

CREATE TRIGGER v2 BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE v2();
-- CORRECCIÓ
1) no has entregat resultats
2) RETURN NUll par UOPDATE i només s'ha de parar en cas de INSERT