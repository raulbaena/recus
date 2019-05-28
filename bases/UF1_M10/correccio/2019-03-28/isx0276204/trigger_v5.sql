CREATE OR REPLACE FUNCTION v5() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	linia1 record;
	sql2 varchar := '';
	linia2 record ;
	sql3 varchar := '';
	linia3 record ;
	sql4 varchar := '';
	linia4 record;
	ins1 varchar := '';
	
	resultat varchar := '';
	last_id_analitica bigint := 0;
	id_analitica bigint := 0;
	id_pacient int := 0;
	id_prova  int := 0;
	num_rep bigint := 0; 
	
BEGIN
	num_rep := NEW.num_rep ;
	IF num_rep != 1 THEN 
		INSERT INTO resultats_patologics VALUES(NEW.id_resultat,current_timestamp,current_user);
		sql1 := 'select * from resultats where id_resultat = '
			|| NEW.id_resultat
			|| ';';
		for linia1 in execute sql1 loop
			id_analitica := linia1.id_analitica ;
			id_prova := linia.id_prova ;
			sql2 := 'select * from analitiques where id_analitica = '
			|| id_analitica
			||';';
			for linia2 in execute sql2 loop
				id_pacient := linia2.id_pacient;
				sql3 := 'select * from analitiques where id_pacient = '
					|| id_pacient
					||' and id_analitica =! '
					|| id_analitica
					|| 'order by id_analitica limit 1 ;';
				for linia3 in execute sql3 loop
					last_id_analitica := linia3.id_analitica;
					sql4 := 'select * from resultats where id_analitica = '
						|| last_id_analitica
						|| 'and id_prova = '
						|| id_prova
						|| ' order by num_rep limit 1;';
						
					for linia4 in execute sql4 loop
						resultat := linia4.resultat;
						ins1 := 'insert into resultats values (default,'''
							|| resultat
							||''','
							|| id_analitica
							||','
							|| id_prova
							|| ','
							|| NEW.num_rep + 1
							||';';
						execute ins1;
					end loop ;
				end loop; 
			end loop;
			
		end loop;
	END IF;
RETURN new;
END;
$BODY$ 
LANGUAGE plpgsql;
/*Creació del TRIGGER: */

CREATE TRIGGER v5 BEFORE INSERT OR UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE v5();

	-- CORRECCIÓ
1) no fas l'insert amb num_rep = -1
2) si ja existeix un -1 per aquella prova o analítica no cal fer res
