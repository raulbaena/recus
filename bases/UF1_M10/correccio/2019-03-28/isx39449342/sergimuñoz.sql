-- Examen Base de Dades
--Nom: Sergi Muñoz Carmona
--Data: 28/03/2019
-----------------------------

--MODIFICACIONS ABANS DE FER ELS EXERCICIS

ALTER TABLE resultats add num_rep int default 1;

ALTER TABLE resultats ADD UNIQUE (id_resultat,id_analitica,id_prova,num_rep);

--la constraint unique (id_prova,id_analitica) no la borro amb alter table ja que la he tret de la taula resultats.

--1.EXERCICI

CREATE OR REPLACE FUNCTION comprova_resultat_v1()
RETURNS TRIGGER
AS
$$
DECLARE
	id_analitica_n int :=0;
	id_prova_n int :=0;
	resultat_n varchar :='';
	trobat boolean := False;
	sql1 varchar :='';
	line1 record;
	valor int := 1;
	
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		id_analitica_n := NEW.id_analitica;
		id_prova_n := NEW.id_prova;
		resultat_n := NEW.resultat;
	END IF;
	
	IF resultat_n IS NULL THEN
		RETURN NULL;
	END IF;
	
	sql1 := 'SELECT * FROM resultats WHERE (resultat is NULL or resultat = '''') and id_analitica = ' || id_analitica_n || ' and  id_prova = ' ||
	id_prova_n || ' and num_rep = ' || valor || ';';
	RAISE NOTICE 'sentencia sql1 %',sql1;
	FOR line1 IN EXECUTE sql1 LOOP
		trobat := True;
	END LOOP;
	
	IF trobat = False THEN
		RAISE NOTICE 'Pasat un nou resultat';
	END IF;	
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';		

CREATE TRIGGER comp_result_v1 AFTER UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE comprova_resultat_v1();

-- CORRECCIÓ
1) el NOTICE no l''has copiat
2) no cal fer select de resultats, està a OLD	
3) el trigger ha de ser BEFORE
4) el resultat a buscar no ha de ser ni NULL ni ''
	
--2.EXERCICI

CREATE OR REPLACE FUNCTION comprova_resultat_v2()
RETURNS TRIGGER
AS
$$
DECLARE
	id_analitica_n int :=0;
	id_prova_n int :=0;
	resultat_n varchar :='';
	trobat boolean := False;
	sql1 varchar :='';
	line1 record;
	valor int := 1;
	valor_2 int :=2;
	sqlupd varchar :='';
	sqlinsert varchar :='';
	
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		id_analitica_n := NEW.id_analitica;
		id_prova_n := NEW.id_prova;
		resultat_n := NEW.resultat;
	END IF;
	
	IF resultat_n IS NULL THEN
		RETURN NULL;
	END IF;
	
	sql1 := 'SELECT * FROM resultats WHERE (resultat is NULL or resultat = '''') and id_analitica = ' || id_analitica_n || ' and  id_prova = ' ||
	id_prova_n || ' and num_rep = ' || valor || ';';
	RAISE NOTICE 'sentencia sql1 %',sql1;
	FOR line1 IN EXECUTE sql1 LOOP
		trobat := True;
		RETURN NULL;
	END LOOP;
	
	IF trobat = False THEN
		RAISE NOTICE 'Pasat un nou resultat';
		sqlinsert := 'INSERT INTO resultats VALUES (DEFAULT,' || resultat_n || ' ,' || id_analitica_n || ',' || id_prova_n || ',' || valor_2 ||' );';
		EXECUTE (sqlinsert);
	END IF;	
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER comp_result_v2 BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE comprova_resultat_v2();
	
--RESULTAT:

 id_resultat | resultat | id_analitica | id_prova | num_rep 
-------------+----------+--------------+----------+---------
           1 | Negatiu  |            1 |        4 |       1
           2 | NULL     |            2 |        4 |       1
           3 | 200      |            4 |        1 |       1
           4 |          |            3 |        3 |       1
           5 | 150      |            4 |        1 |       2
(5 rows)

-- CORRECCIÓ

1) return NULL para operació UPDATE, i només s''ha de parar en el cas que es faci INSERT

--3.EXERCICI

CREATE OR REPLACE FUNCTION comprova_resultat_v3()
RETURNS TRIGGER
AS
$$
DECLARE
	id_analitica_n int :=0;
	id_prova_n int :=0;
	resultat_n varchar :='';
	trobat boolean := False;
	sql1 varchar :='';
	line1 record;
	valor int := 1;
	sqlupd varchar :='';
	sqlinsert varchar :='';
	num_rep_n int :=0;
	sql2 varchar :='';
	line2 record;
	
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		id_analitica_n := NEW.id_analitica;
		id_prova_n := NEW.id_prova;
		resultat_n := NEW.resultat;
	END IF;
	
	IF resultat_n IS NULL THEN
		RETURN NULL;
	END IF;
	
	sql1 := 'SELECT * FROM resultats WHERE (resultat is NULL or resultat = '''') and id_analitica = ' || id_analitica_n || ' and  id_prova = ' ||
	id_prova_n || ' and num_rep = ' || valor || ';';
	RAISE NOTICE 'sentencia sql1 %',sql1;
	FOR line1 IN EXECUTE sql1 LOOP
		trobat := True;
		RETURN NULL;
	END LOOP;
	
	IF trobat = False THEN
		RAISE NOTICE 'Pasat un nou resultat';
		sql2 := 'SELECT * from resultats where id_analitica = ' || id_analitica_n || ' and  id_prova = ' ||
	    id_prova_n || ' and num_rep = ' || valor ||' order by num_rep desc limit 1;';
	    FOR line2 IN EXECUTE sql2 LOOP
			num_rep_n := line2.num_rep;
			sqlinsert := 'INSERT INTO resultats VALUES (DEFAULT,' || resultat_n || ' ,' || id_analitica_n || ',' || id_prova_n || ',' || num_rep_n + 1||');';
			RAISE NOTICE 'Insert %',sqlinsert;
			EXECUTE (sqlinsert);
		END LOOP;
			
	END IF;	
	RETURN NULL;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER comp_result_v3 BEFORE UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE comprova_resultat_v3();


--RAISE NOTICE 'Pasat un nou resultat';
		--sqlupd :='UPDATE resultats SET num_rep = (select num_rep from resultats where id_prova = '||  id_prova_n || ' 
		--and id_analitica = ' || id_analitica_n ||') + ' || valor || ' where id_analitica = ' || id_analitica_n || ' 
		--and id_prova = ' || id_prova_n || ';';
		--RAISE NOTICE ' FENT UPDATE %',sqlupd;
		--EXECUTE (sqlupd);

sql2 := 'SELECT * from resultats where id_analitica = ' || id_analitica_n || ' and  id_prova = ' ||
	    id_prova_n || ' and num_rep = ' || valor || ';';
	    FOR line2 IN EXECUTE SQL 
-- CORRECCIÓ
1) falta prova i resultats de proves
2) Quan es fa l'INSERT s'ha de parar UPDATE amb RETURN NULL