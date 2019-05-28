/*EXERICI1*/
CREATE OR REPLACE FUNCTION exam1() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	sql2 varchar := '';
	sql3 varchar := '';
	line1 record;
	line2 record;
	line3 record;
	trobat bool := False;
	trobat2 bool := False;
	trobat3 bool := False;
	resultat int := 0;
	var_id_resultat int := 0;
	var_id_analitica int := 0;
	var_id_prova int := 0;
	id_anal int := 0;
	valoracio  int := 0;
	var_resultat varchar := '';
	msg varchar := 'Analitica No acabada';
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		IF NEW.resultat IS NOT NULL or NEW.resultat != '' THEN
			var_id_resultat := NEW.id_resultat;
			var_id_analitica := NEW.id_analitica;
			var_id_prova := NEW.id_prova;
			var_resultat := NEW.resultat;
			sql1 := 'select * from resultats where id_analitica ='|| var_id_analitica ||' and id_prova='|| var_id_prova ||' 
				and (resultat is not null or resultat != '''');';
			FOR line1 in EXECUTE (sql1) LOOP
				trobat := True;
			END LOOP;
			IF trobat THEN
				RAISE NOTICE 'Resultat repetit : la id_anal : % y la id_prova : % ',var_id_analitica,var_id_prova;
			END IF;
		END IF;
	ELSE
		RETURN NULL;
	END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER examen BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE exam1();



-- ~ INSERT INTO analitiques values (1,1,'2018-10-01');
-- ~ INSERT INTO resultats values (1,'negatiu',1,1);
-- ~ INSERT INTO resultats values (2,'200',1,2);

/*Cridem la funcio*/
-- ~ exam=# select * from resultats;
 -- ~ id_resultat | resultat | id_analitica | id_prova 
-- ~ -------------+----------+--------------+----------
           -- ~ 2 | 200      |            1 |        2
           -- ~ 1 | negatiu  |            1 |        1

-- ~ exam=# update resultats set resultat='positiu' where id_resultat = 1;
-- ~ NOTICE:  Es repeteix: id_anal : 1 id_prova : 1 

-- CORRECCIÓ
1) el NOTICE no és el que està escrit a la funció
2) no cal fer select de resultats, està a OLD
3) el where de resultat ha de ser AND

/*---------------EXERCICI 2 -----------------------------------------*/

CREATE OR REPLACE FUNCTION exam2() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	sql2 varchar := '';
	sql3 varchar := '';
	line1 record;
	line2 record;
	line3 record;
	trobat bool := False;
	trobat2 bool := False;
	trobat3 bool := False;
	resultat int := 0;
	var_id_resultat int := 0;
	var_id_analitica int := 0;
	var_id_prova int := 0;
	id_anal int := 0;
	valoracio  int := 0;
	var_resultat varchar := '';
	msg varchar := 'Analitica No acabada';
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		IF NEW.resultat IS NOT NULL or NEW.resultat != '' THEN
			var_id_analitica := NEW.id_analitica;
			var_id_prova := NEW.id_prova;
			var_resultat := NEW.resultat;
			sql1 := 'select * from resultats where id_analitica ='|| var_id_analitica ||' and id_prova='|| var_id_prova ||' 
				and (resultat is not null or resultat != '''');';
			FOR line1 in EXECUTE (sql1) LOOP
				trobat := True;
			END LOOP;
			IF trobat and var_resultat is not null and var_resultat != '' THEN
				RAISE NOTICE 'Es repeteix : la id_anal : % y la id_prova : % ',var_id_analitica,var_id_prova;
				INSERT INTO resultats VALUES(DEFAULT,var_resultat,var_id_analitica,var_id_prova,2);
			END IF;
		END IF;
	ELSE
		RETURN NULL;
	END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER examen BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE exam2();
    
/*-----------------------------------------------------------------------*/
INSERT INTO resultats values (1,'positiu',1,1,1);  
INSERT INTO resultats values (2,'140',1,2,1);
INSERT INTO resultats values (3,'negatiu',1,7,1);
/*---------------------------------------------------------------------*/
exam=# select * from resultats;
 id_resultat | resultat | id_analitica | id_prova | num_rep 
-------------+----------+--------------+----------+---------
           1 | positiu  |            1 |        1 |       1
           2 | 140      |            1 |        2 |       1
           3 | negatiu  |            1 |        7 |       1
(3 rows)

/*--------------------------------------------------------------------*/
update resultats set resultat='negatiu' where id_resultat = 1;

/*------------------------------------------------------------------*/
exam=# update resultats set resultat='negatiu' where id_resultat = 3;
NOTICE:  Es repeteix : la id_anal : 1 y la id_prova : 7 
UPDATE 1
exam=# select * from resultats;
 id_resultat | resultat | id_analitica | id_prova | num_rep 
-------------+----------+--------------+----------+---------
           1 | negatiu  |            1 |        1 |       1
           2 | negatiu  |            1 |        2 |       1
           4 | negatiu  |            1 |        7 |       2
           3 | negatiu  |            1 |        7 |       1
(4 rows)

-- CORRECCIÓ
1) el where de resultat ha de se AND
2) Quan es fa l'INSERT s'ha de parar UPDATE amb RETURN NULL
3) no fas insert amb resultat nou

/*-----------------------EXERCICI 3 --------------------------------*/

CREATE OR REPLACE FUNCTION exam2() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	sql2 varchar := '';
	sql3 varchar := '';
	line1 record;
	line2 record;
	line3 record;
	trobat bool := False;
	trobat2 bool := False;
	trobat3 bool := False;
	resultat int := 0;
	var_id_resultat int := 0;
	var_id_analitica int := 0;
	var_id_prova int := 0;
	id_anal int := 0;
	valoracio  int := 0;
	var_resultat varchar := '';
	msg varchar := 'Analitica No acabada';
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		IF NEW.resultat IS NOT NULL or NEW.resultat != '' THEN
			var_id_analitica := NEW.id_analitica;
			var_id_prova := NEW.id_prova;
			var_resultat := NEW.resultat;
			sql1 := 'select * from resultats where id_analitica ='|| var_id_analitica ||' and id_prova='|| var_id_prova ||' 
				and (resultat is not null or resultat != '''');';
			FOR line1 in EXECUTE (sql1) LOOP
				trobat := True;
			END LOOP;
			IF trobat and var_resultat is not null and var_resultat != '' THEN
				RAISE NOTICE 'Es repeteix : la id_anal : % y la id_prova : % ',var_id_analitica,var_id_prova;
				INSERT INTO resultats VALUES(DEFAULT,var_resultat,var_id_analitica,var_id_prova,(NEW.num_rep + 1));
			ELSE 
				RETURN NULL;
			END IF;
		ELSE
			RETURN NULL;
		END IF;
	ELSE 
		RETURN NULL;
	END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER examen BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE exam2();

/*--------------------------------------------------------------------*/
exam=# update resultats set resultat='positiu' where id_resultat = 4;
NOTICE:  Es repeteix : la id_anal : 1 y la id_prova : 7 
/*--------------------------------------------------------------------*/
exam=# select * from resultats;
 id_resultat | resultat | id_analitica | id_prova | num_rep 
-------------+----------+--------------+----------+---------
           1 | negatiu  |            1 |        1 |       1
           2 | 140      |            1 |        2 |       1
           3 | negatiu  |            1 |        7 |       1
           5 | negatiu  |            1 |        7 |       3   
           4 | positiu  |            1 |        7 |       2
(5 rows)
/*--------------------------------------------------------------------*/
-- CORRECCIÓ
1) no fas insert amb resulat nou, agafes l''anterior
2) Quan es fa l'INSERT s'ha de parar UPDATE amb RETURN NULL

/*------------------------------Exercic 4----------------------------------*/
/*Modifiquem la mateixa taula que teniam y fem que tambe inserti a 
resultats patologics els resultats amb num_rep != 1 */

CREATE OR REPLACE FUNCTION revisa_patologia() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	linia1 record;
	id_pacient int := 0;
	valoracio  int := 0;
BEGIN
	IF NEW.resultat IS NULL or NEW.resultat = '' THEN
		RETURN NULL;
	END IF;
	sql1 := 'select * from analitiques where id_analitica ='|| NEW.id_analitica ||';';
	FOR linia1 IN EXECUTE sql1 LOOP
		id_pacient := linia1.id_pacient;
	END LOOP;
	valoracio := calcula_risc(NEW.id_prova,id_pacient,NEW.resultat);
	-- ~ RAISE NOTICE '%',valoracio;
	IF valoracio = 2 or valoracio = 3 THEN 
		INSERT INTO resultats_patologics VALUES(NEW.id_resultat,current_timestamp,current_user);
	END IF;
	IF  NEW.num_rep != 1  THEN
		INSERT INTO resultats_patologics VALUES(NEW.id_resultat,current_timestamp,current_user);
	END IF;
RETURN NEW;
EXCEPTION
	WHEN unique_violation THEN return '2';
	WHEN foreign_key_violation THEN return '3';
END;
$BODY$ 
LANGUAGE plpgsql;


CREATE TRIGGER guarda_resultat AFTER INSERT OR UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE revisa_patologia();

-- CORRECCIÓ
1) fas 2 inserts, hauria de ser IF valoracio = 2 or valoracio = 3 or NEW.num_rep != 1 THEN 
2) no has entergat proves i resultats
	
/*---------------------------------------------------------------------------------*/

exam=# update resultats set resultat='negatiu' where id_resultat =1;
NOTICE:  Es repeteix : la id_anal : 1 y la id_prova : 1 

exam=# select * from resultats_patologics ;
 id_resultat |           stamp            |  userid  
-------------+----------------------------+----------
           1 | 2019-03-28 11:38:50.660047 | postgres
           2 | 2019-03-28 11:38:50.671291 | postgres
           4 | 2019-03-28 11:40:18.21092  | postgres
           4 | 2019-03-28 11:40:18.21092  | postgres
           3 | 2019-03-28 11:40:18.21092  | postgres
           5 | 2019-03-28 11:41:25.156467 | postgres
(6 rows)


/*--------------------------------EXERCICI 5--------------------------------*/

CREATE OR REPLACE FUNCTION exam2() RETURNS trigger 
AS $BODY$
DECLARE
	sql1 varchar := '';
	sql2 varchar := '';
	sql3 varchar := '';
	line1 record;
	line2 record;
	line3 record;
	trobat bool := False;
	trobat2 bool := False;
	trobat3 bool := False;
	resultat int := 0;
	var_id_resultat int := 0;
	var_id_analitica int := 0;
	var_id_prova int := 0;
	id_anal int := 0;
	valoracio  int := 0;
	id_pacient_trobat int := 0;
	var_resultat varchar := '';
	var_resultat_anterior varchar := '';
	msg varchar := 'resultat repetit';
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		IF NEW.resultat IS NOT NULL or NEW.resultat != '' THEN
			var_id_analitica := NEW.id_analitica;
			var_id_prova := NEW.id_prova;
			var_resultat := NEW.resultat;
			sql1 := 'select * from resultats where id_analitica ='|| var_id_analitica ||' and id_prova='|| var_id_prova ||' 
				and (resultat is not null or resultat != '''');';
			FOR line1 in EXECUTE (sql1) LOOP
				trobat := True;
			END LOOP;
			IF trobat and var_resultat is not null and var_resultat != '' THEN
				RAISE NOTICE 'Es repeteix : la id_anal : % y la id_prova : % ',var_id_analitica,var_id_prova;
				INSERT INTO resultats VALUES(DEFAULT,var_resultat,var_id_analitica,var_id_prova,(NEW.num_rep + 1));
			END IF;
			IF trobat THEN
				sql2 := 'select id_pacient FROM analitiques where id_analitica = '|| NEW.id_analitica ||';';
				FOR line2 IN EXECUTE sql2 LOOP
					id_pacient_trobat := line2.id_pacient;
				END LOOP;
				sql3 := 'select resultats.resultat FROM resultats JOIN analitiques  on resultats.id_analitica=analitiques.id_analitica
						WHERE analitiques.id_pacient='|| id_pacient_trobat ||' and resultats.id_prova = '|| NEW.id_prova ||' 
						and resultat is not NULL and resultat != '''' ORDER BY resultats.id_analitica DESC LIMIT 1;';
				FOR line3 IN EXECUTE sql3 LOOP
					var_resultat_anterior := line3.resultat;
				END LOOP;
				RAISE NOTICE 'Es repeteix : ames de % ',msg;
				INSERT INTO resultats VALUES(DEFAULT,var_resultat_anterior,var_id_analitica,var_id_prova,(NEW.num_rep + 1));
			END IF;
		ELSE
			RETURN NULL;
		END IF;
	ELSE 
		RETURN NULL;
	END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER examen BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE exam2();
    
    
/*--------------------------------------*/
exam=# update resultats set resultat='15' where id_resultat =2;
-- CORRECCIÓ
1) insertes SENSE NUM_REP=-1

