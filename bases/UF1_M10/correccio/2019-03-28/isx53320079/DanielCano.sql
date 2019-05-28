--1
CREATE OR REPLACE FUNCTION revisar_resultats()
RETURNS TRIGGER
AS
$$
DECLARE
	searchsql varchar := '';
	linia record;
BEGIN
	/*RAISE NOTICE 'resultat %', NEW.resultat;
	RAISE NOTICE 'analitica %', NEW.analitica;
	RAISE NOTICE 'prova %', NEW.prova;
	RAISE NOTICE 'id_resultat %', NEW.id_resultat;*/
	
	IF NEW.resultat IS NULL or NEW.resultat = '' THEN
		RETURN NULL;
	END IF;
	searchsql := 'select * from resultats where analitica = ' || NEW.analitica || ' and prova = ' || NEW.prova || ';';
	FOR linia IN EXECUTE searchsql LOOP
		IF linia.resultat = '' or linia.resultat IS NULL THEN
			RETURN NULL;
		ELSE
			RAISE NOTICE 'ATENCIO estem modificant un resultat';
		END IF;
	END LOOP;
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_revisio_resultat BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE revisar_resultats();

/*
update resultats set resultat = '200' where analitica = 1 and prova = 2;
	NOTICE:  ATENCIO estem modificant un resultat
	UPDATE 0
*/
-- CORRECCIÓ
1) no cal fer select de resultats, està a OLD
2) return NULL para operació UPDATE, i només s''ha de parar en el cas que es faci no INSERT


/*###############################################################################################################*/
--2
CREATE OR REPLACE FUNCTION revisar_resultats()
RETURNS TRIGGER
AS
$$
DECLARE
	searchsql varchar := '';
	insertsql varchar := '';
	linia record;
BEGIN
	/*RAISE NOTICE 'resultat %', NEW.resultat;
	RAISE NOTICE 'analitica %', NEW.analitica;
	RAISE NOTICE 'prova %', NEW.prova;
	RAISE NOTICE 'id_resultat %', NEW.id_resultat;*/
	
	IF NEW.resultat IS NULL or NEW.resultat = '' THEN
		RETURN NULL;
	END IF;
	searchsql := 'select * from resultats where analitica = ' || NEW.analitica || ' and prova = ' || NEW.prova || ';';
	FOR linia IN EXECUTE searchsql LOOP
		IF linia.resultat = '' or linia.resultat IS NULL THEN
			RETURN NULL;
		ELSE
			RAISE NOTICE 'ATENCIO estem modificant un resultat';
			insertsql := 'insert into resultats values (DEFAULT, ' || NEW.resultat || ', ' || NEW.analitica || ', ' || NEW.prova || ', 2);';
			RAISE NOTICE 'insert: %',insertsql;
			EXECUTE insertsql;
		END IF;
	END LOOP;
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_revisio_resultat BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE revisar_resultats();
/*
update resultats set resultat = '200' where analitica = 1 and prova = 2;
	NOTICE:  ATENCIO estem modificant un resultat
	NOTICE:  insert: insert into resultats values (DEFAULT, 200, 1, 2, 2);
	UPDATE 0

select * from resultats where analitica = 1 and prova = 2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           2 | 300      |         1 |     2 |       1
          26 | 200      |         1 |     2 |       2
(2 filas)
*/
-- CORRECCIÓ
1) quan es fa l'INSERT ha de ser RETURN NULL per parar UPDATE
2) quan no és resultat repetit pares l'UPDATE al fer RETURN NULL


/*###############################################################################################################*/
--3
CREATE OR REPLACE FUNCTION revisar_resultats()
RETURNS TRIGGER
AS
$$
DECLARE
	searchsql varchar := '';
	insertsql varchar := '';
	linia record;
	new_num_rep int ;
BEGIN
	/*RAISE NOTICE 'resultat %', NEW.resultat;
	RAISE NOTICE 'analitica %', NEW.analitica;
	RAISE NOTICE 'prova %', NEW.prova;
	RAISE NOTICE 'id_resultat %', NEW.id_resultat;
	RAISE NOTICE 'num_rep %', NEW.num_rep;*/
	
	IF NEW.resultat IS NULL or NEW.resultat = '' THEN
		RETURN NULL;
	END IF;
	searchsql := 'select * from resultats where analitica = ' || NEW.analitica || ' and prova = ' || NEW.prova || 'order by num_rep desc limit 1;';
	FOR linia IN EXECUTE searchsql LOOP
		IF linia.resultat = '' or linia.resultat IS NULL THEN
			RETURN NULL;
		ELSE
			new_num_rep :=  linia.num_rep+1;
			RAISE NOTICE 'ATENCIO estem modificant un resultat';
			insertsql := 'insert into resultats values (DEFAULT, ' || NEW.resultat || ', ' || NEW.analitica || ', ' || NEW.prova || ', '|| new_num_rep || ');';
			RAISE NOTICE 'insert: %',insertsql;
			EXECUTE insertsql;
		END IF;
	END LOOP;
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_revisio_resultat BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE revisar_resultats();
/*
update resultats set resultat = '200' where analitica = 1 and prova = 2 and num_rep = 2;;
	NOTICE:  ATENCIO estem modificant un resultat
	NOTICE:  insert: insert into resultats values (DEFAULT, 200, 1, 2, 3);
	UPDATE 0

select * from resultats where analitica = 1 and prova = 2;;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           2 | 300      |         1 |     2 |       1
          26 | 200      |         1 |     2 |       2
          27 | 200      |         1 |     2 |       3
(3 filas)
*/
-- CORRECCIÓ
1) Sempre fas RETURN NULL i només s'ha de fer quan es fa l'INSERT, estàs parant els UPDATE de res no repetits

/*###############################################################################################################*/
--4
CREATE OR REPLACE FUNCTION revisar_resultats()
RETURNS TRIGGER
AS
$$
DECLARE
	searchsql varchar := '';
	searchsql2 varchar := '';
	searchsql3 varchar := '';
	insertsql varchar := '';
	insertsql2 varchar := '';
	linia record;
	linia2 record;
	linia3 record;
	new_num_rep int ;
	pacient int ;
	new_id_resultat bigint;
BEGIN
	/*RAISE NOTICE 'resultat %', NEW.resultat;
	RAISE NOTICE 'analitica %', NEW.analitica;
	RAISE NOTICE 'prova %', NEW.prova;
	RAISE NOTICE 'id_resultat %', NEW.id_resultat;
	RAISE NOTICE 'num_rep %', NEW.num_rep;*/
	
	IF NEW.resultat IS NULL or NEW.resultat = '' THEN
		RETURN NULL;
	END IF;
	searchsql := 'select * from resultats where analitica = ' || NEW.analitica || ' and prova = ' || NEW.prova || 'order by num_rep desc limit 1;';
	FOR linia IN EXECUTE searchsql LOOP
		IF linia.resultat = '' or linia.resultat IS NULL THEN
			RETURN NULL;
		ELSE
			new_num_rep :=  linia.num_rep+1;
			RAISE NOTICE 'ATENCIO estem modificant un resultat';
			insertsql := 'insert into resultats values (DEFAULT, ' || NEW.resultat || ', ' || NEW.analitica || ', ' || NEW.prova || ', '|| new_num_rep || ');';
			RAISE NOTICE 'insert: %',insertsql;
			EXECUTE insertsql;
		END IF;
	END LOOP;
	
	IF new_num_rep > 1 THEN
		searchsql2 := 'select * from analitiques where id_analitica = ' || NEW.analitica || ';';
		FOR linia2 IN EXECUTE searchsql2 LOOP
			pacient := linia2.pacient;
		END LOOP;
		searchsql3 := 'select * from resultats where analitica = ' || NEW.analitica || ' and prova = ' || NEW.prova || 'order by num_rep desc limit 1;';
		FOR linia3 IN EXECUTE searchsql3 LOOP
			new_id_resultat := linia3.id_resultat;
		END LOOP;
		insertsql2 := 'INSERT INTO resultats_patologics VALUES(' || new_id_resultat || ', ''' || now() || ''', ' || pacient || ');';
		RAISE NOTICE 'insertsql2: %',insertsql2;
		EXECUTE insertsql2;
	END IF;
		
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_revisio_resultat BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE revisar_resultats();
/*
update resultats set resultat = '555' where analitica = 1 and prova = 2 and num_rep = 7;
	NOTICE:  ATENCIO estem modificant un resultat
	NOTICE:  insert: insert into resultats values (DEFAULT, 555, 1, 2, 8);
	NOTICE:  insertsql2: INSERT INTO resultats_patologics VALUES(38, '2019-03-28 12:14:06.857261+01', 1);
	UPDATE 0

select * from resultats where analitica = 1 and prova = 2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           2 | 300      |         1 |     2 |       1
          26 | 200      |         1 |     2 |       2
          27 | 200      |         1 |     2 |       3
          28 | 200      |         1 |     2 |       4
          33 | 666      |         1 |     2 |       5
          36 | 500      |         1 |     2 |       6
          37 | 555      |         1 |     2 |       7
          38 | 555      |         1 |     2 |       8
(8 filas)

select * from resultats_patologics ;
 id_resultat |           stamp            | pacient 
-------------+----------------------------+---------
          27 | 2019-03-28 11:27:11.413589 | 1
           3 | 2019-03-28 11:46:05.389859 | 1
          27 | 2019-03-28 12:06:30.680434 | 1
          33 | 2019-03-28 12:09:18.423347 | 1
          38 | 2019-03-28 12:14:06.857261 | 1
(5 filas)

*/
-- CORRECCIÓ
1) pares INSERT i UPDATE de resultats si trobes resultats_patologics
2) Pq llegeixes pacients i analítique en cas de que num_rep >1
3) No controles si ja existeix a resultats_patologics

/*###############################################################################################################*/
--5
CREATE OR REPLACE FUNCTION revisar_resultats()
RETURNS TRIGGER
AS
$$
DECLARE
	searchsql varchar := '';
	searchsql2 varchar := '';
	searchsql3 varchar := '';
	searchsql4 varchar := '';
	insertsql varchar := '';
	insertsql2 varchar := '';
	linia record;
	linia2 record;
	linia3 record;
	linia4 record;
	new_num_rep int ;
	pacient int ;
	fecha date ;
	old_analitica bigint;
	old_resultat varchar;
BEGIN
	/*RAISE NOTICE 'resultat %', NEW.resultat;
	RAISE NOTICE 'analitica %', NEW.analitica;
	RAISE NOTICE 'prova %', NEW.prova;
	RAISE NOTICE 'id_resultat %', NEW.id_resultat;
	RAISE NOTICE 'num_rep %', NEW.num_rep;*/
	
	IF NEW.resultat IS NULL or NEW.resultat = '' THEN
		RETURN NULL;
	END IF;
	searchsql := 'select * from resultats where analitica = ' || NEW.analitica || ' and prova = ' || NEW.prova || 'order by num_rep desc limit 1;';
	FOR linia IN EXECUTE searchsql LOOP
		IF linia.resultat = '' or linia.resultat IS NULL THEN
			RETURN NULL;
		ELSE
			new_num_rep :=  linia.num_rep+1;
			RAISE NOTICE 'ATENCIO estem modificant un resultat';
			insertsql := 'insert into resultats values (DEFAULT, ' || NEW.resultat || ', ' || NEW.analitica || ', ' || NEW.prova || ', '|| new_num_rep || ');';
			RAISE NOTICE 'insert: %',insertsql;
			EXECUTE insertsql;
		END IF;
	END LOOP;
	
	searchsql2 := 'select * from analitiques where id_analitica = ' || NEW.analitica || ';';
	FOR linia2 IN EXECUTE searchsql2 LOOP
		pacient := linia2.pacient;
		fecha := linia2.fecha_pedida;
	END LOOP;
		
	searchsql3:='select * from analitiques where pacient = ' || pacient || ' and fecha_pedida < ''' || fecha || ''' order by 3 desc limit 1;';
	FOR linia3 IN EXECUTE searchsql3 LOOP
		old_analitica := linia3.id_analitica;
	END LOOP;
	
	searchsql4 := 'select * from resultats where analitica = ' || old_analitica || ' and prova = ' || NEW.prova || 'order by num_rep desc limit 1;';
	FOR linia4 IN EXECUTE searchsql4 LOOP
		old_resultat := linia4.resultat;
		insertsql2 := 'insert into resultats values (DEFAULT, ' || old_resultat || ', ' || NEW.analitica || ', ' || NEW.prova || ', -1);';
		RAISE NOTICE 'insert2: %',insertsql2;
		EXECUTE insertsql2;
	END LOOP;
	
	
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER trigger_revisio_resultat BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE revisar_resultats();

/*
update resultats set resultat = '200' where analitica = 2 and prova = 2 and num_rep = 2;
	NOTICE:  ATENCIO estem modificant un resultat
	NOTICE:  insert: insert into resultats values (DEFAULT, 200, 2, 2, 4);
	NOTICE:  insert2: insert into resultats values (DEFAULT, 666, 2, 2, -1);
	UPDATE 0

select * from resultats where analitica = 2 and prova = 2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           3 | 200      |         2 |     2 |       1
          29 | 210      |         2 |     2 |       2
          31 | 200      |         2 |     2 |       3
          34 | 200      |         2 |     2 |       4
          35 | 666      |         2 |     2 |      -1
(5 filas)

select * from resultats where analitica = 1 and prova = 2 order by num_rep desc limit 1;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          33 | 666      |         1 |     2 |       5
(1 fila)

*/

-- CORRECCIÓ
1) per cada resultat repetit de la prova fas insert de nou resultat
2) si ja existeix amb -1 no s'ha de tornar a fer insert
