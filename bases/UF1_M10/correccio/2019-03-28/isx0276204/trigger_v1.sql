CREATE OR REPLACE FUNCTION v1() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	up1 varchar := '';
	linia1 record;
	id_prova bigint := 0;
	id_resultat bigint := 0;
	num_rep bigint := 1;
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
		if resultat = linia1.resultat or resultat = null then
			up1 := 'insert into table resultat ( '
				|| id_resultat
				|| ','''
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
		end if;
		
	end loop; 
RETURN null;
END;
$BODY$ 
LANGUAGE plpgsql;
/*Creació del TRIGGER: */

CREATE TRIGGER v1 BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE v1();
-- CORRECCIÓ
1) el NOTICE no està entregat, no funciona?
2) no cal fer select de resultats, està a OLD
3) fa el notice quan el rsultat que es modifica és igual al que hi ha p quan és null? Just al revés del que havia de fer 