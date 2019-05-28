CREATE OR REPLACE FUNCTION v3() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	up1 varchar := '';
	linia1 record;
	id_prova bigint := 0;
	id_resultat bigint := 0;
	num_rep bigint := 0;
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
	|| 'order by num_rep desc limit 1;';
	for linia1 in execute sql1 loop
		num_rep := linia1.num_rep + 1 ;
		if resultat != linia1.resultat  then
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

CREATE TRIGGER v3 BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE v3();
-- CORRECCIÓ
1) falta entregar prova i resultats
2) Quan es fa l'INSERT s'ha de parar UPDATE amb RETURN NULL, en tots els altres casos no s'ha de parar