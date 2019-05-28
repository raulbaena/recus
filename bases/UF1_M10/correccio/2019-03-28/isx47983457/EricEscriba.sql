-- Examen Triggers M10
-- ERIC ESCRIBA


-- AFEGIR CAMP NUM_REP
ALTER TABLE resultats add num_rep int default 1;

-- CANVIAR LA CLAU UNICA AFEGINT NUM_REP

ALTER TABLE resultats drop constraint resultats_analitica_prova_key;

ALTER TABLE resultats add unique (analitica,prova,num_rep);


-- #####################################################################

-- EX 1
CREATE OR REPLACE FUNCTION resultat_prova() RETURNS trigger AS
$$
DECLARE
	
	searchsql varchar := '';
	linia record;

BEGIN
	-- Comprovar si el resultat entrat es null
	IF NEW.resultat is NULL or NEW.resultat = '' or NEW.resultat = 'NULL' THEN
		RETURN NULL;
	END IF;
	
	-- Resultats prova/analitica
	searchsql := 'select * from resultats where  analitica = ' || NEW.analitica || 'and prova = ' || NEW.prova || 'and num_rep = 1;';
	
	FOR linia in EXECUTE searchsql LOOP
		-- Comprovar el resultat daquella prova d'aquella analtica entrada es NULL
		
		IF linia.resultat is NULL or linia.resultat = '' or linia.resultat = 'NULL' THEN
			RETURN NULL;
		-- ES REPETIT
		ELSE
			RAISE NOTICE 'ES REPETIT';
		END IF;
	END LOOP;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER prova_resultat BEFORE UPDATE on resultats
	FOR EACH ROW EXECUTE PROCEDURE resultat_prova();

-- COMPROVACIÓ 

-- EXEMPLE 1
-- ES REPETIT I FA L'UPDATE

centre_salut=# update resultats set  resultat = '66' where id_resultat = 37;
NOTICE:  ES REPETIT
UPDATE 1

centre_salut=# select * from resultats where id_resultat = 37;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          37 | 66       |        10 |     7 |       1
(1 row)


-- EXEMPLE 2
-- ES NULL I NO FA L'UPDATE

centre_salut=# select * from resultats where id_resultat =39;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          39 |          |         1 |     7 |       1

centre_salut=# update resultats set resultat = '100' where id_resultat=39;
UPDATE 0

centre_salut=# select * from resultats where id_resultat =39;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          39 |          |         1 |     7 |       1
(1 row)

-- CORRECCIÓ

1) no cal fer select de resultats, està a OLD
2) return NULL para operació UPDATE, i només s''ha de parar en el cas que es faci no INSERT


-- #####################################################################

-- BORREM EL TRIGGER PER FER L'EXERCICI 2
DROP TRIGGER prova_resultat ON resultats ;


-- EX 2 

CREATE OR REPLACE FUNCTION resultat_prova_1() RETURNS trigger AS
$$
DECLARE
	
	searchsql varchar := '';
	linia record;

BEGIN
	-- Comprovar si el resultat entrat es null
	IF NEW.resultat is NULL or NEW.resultat = '' or NEW.resultat = 'NULL' THEN
		RETURN NULL;
	END IF;
	
	-- Resultats prova/analitica
	searchsql := 'select * from resultats where  analitica = ' || NEW.analitica || 'and prova = ' || NEW.prova || 'and num_rep = 1;';
	
	FOR linia in EXECUTE searchsql LOOP
		-- Comprovar el resultat daquella prova d'aquella analtica entrada es NULL
		
		IF linia.resultat is NULL or linia.resultat = '' or linia.resultat = 'NULL' THEN
			RETURN NULL;
		-- Es repetit
		ELSE
			-- Fem l'insert a resultats amb el valors num_rep = 2
			INSERT INTO resultats values (default,NEW.resultat,NEW.analitica,NEW.prova,2);
			RETURN NULL;
		END IF;
	END LOOP;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER prova_resultat BEFORE UPDATE on resultats
	FOR EACH ROW EXECUTE PROCEDURE resultat_prova_1();


-- COMPROVACIÓ 


centre_salut=# select * from resultats where id_resultat = 42;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          42 | 75       |         1 |     6 |       1
(1 row)

centre_salut=# update resultats set resultat = '74' where id_resultat=42;
UPDATE 0

-- No ha canviat el resultat que hi havia
centre_salut=# select * from resultats where id_resultat = 42;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          42 | 75       |         1 |     6 |       1
(1 row)

-- Ha fet un insert amb el nou resultat, i num_rep = 2

centre_salut=# select * from resultats where resultat = '74' and prova = 6 and analitica = 1;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          44 | 74       |         1 |     6 |       2
(1 row)

-- CORRECCIÓ
1) quan no és resultat repetit pares l'UPDATE al fer RETURN NULL
-- #####################################################################


-- BORREM EL TRIGGER PER FER L'EXERCICI 3
DROP TRIGGER prova_resultat ON resultats ;


-- EX 3

CREATE OR REPLACE FUNCTION resultat_prova_2() RETURNS trigger AS
$$
DECLARE
	
	searchsql varchar := '';
	searchsql2 varchar := '';
	linia record;
	linia2 record;

BEGIN
	-- Comprovar si el resultat entrat es null
	IF NEW.resultat is NULL or NEW.resultat = '' or NEW.resultat = 'NULL' THEN
		RETURN NULL;
	END IF;
	
	-- Resultats prova/analitica
	searchsql := 'select * from resultats where  analitica = ' || NEW.analitica || 'and prova = ' || NEW.prova || 'and num_rep = 1;';
	
	FOR linia in EXECUTE searchsql LOOP
		-- Comprovar el resultat daquella prova d'aquella analtica entrada es NULL
		
		IF linia.resultat is NULL or linia.resultat = '' or linia.resultat = 'NULL' THEN
			RETURN NULL;
		-- Es repetit
		ELSE
			-- Mirar quin és l'ultim registre de la prova d'aquella analilica per afegir el nou sumantli un.
			searchsql2 := 'select * from resultats where analitica = ' || NEW.analitica || 'and prova = ' || NEW.prova || ' order by num_rep desc limit 1;';

			FOR linia2 in execute searchsql2 LOOP
				NEW.num_rep := linia2.num_rep +1;
				RAISE NOTICE '%s',NEW.num_rep;
				-- Fem l'insert 
				INSERT INTO resultats values (default,NEW.resultat,NEW.analitica,NEW.prova,NEW.num_rep);
				RETURN NULL;
			END LOOP;
		END IF;
	END LOOP;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER prova_resultat BEFORE UPDATE on resultats
	FOR EACH ROW EXECUTE PROCEDURE resultat_prova_2();

-- COMPROVACIO 

-- 2 updates per a la prova 2 analitica 1

centre_salut=# select * from resultats where analitica = 1 and prova =2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           2 | 500      |         1 |     2 |       1
(1 row)


centre_salut=# update resultats set resultat = '400' where id_resultat = 2;
NOTICE:  2s
UPDATE 0
centre_salut=# update resultats set resultat = '350' where id_resultat = 2;
NOTICE:  3s
UPDATE 0
centre_salut=# update resultats set resultat = '250' where id_resultat = 2;
NOTICE:  4s
UPDATE 0

-- Ha afegit els inserts amb nous resultats i num_rep mes gran

centre_salut=# select * from resultats where analitica = 1 and prova =2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           2 | 500      |         1 |     2 |       1
          46 | 400      |         1 |     2 |       2
          47 | 350      |         1 |     2 |       3
          48 | 250      |         1 |     2 |       4
(4 rows)

-- Comprovar que si el resultat entrat es NULL o be el que hi ha a la taula es NULL, llavors no fa ni Insert ni Update
-- EXEMPLE 1
centre_salut=# select * from resultats where id_resultat =39;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          39 |          |         1 |     7 |       1
(1 row)

centre_salut=# update resultats set resultat = '100'  where id_resultat = 39;
UPDATE 0

-- Continua sent el mateix

centre_salut=# select * from resultats where id_resultat =39;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          39 |          |         1 |     7 |       1
(1 row)


-- EXEMPLE 2

centre_salut=# select * from resultats where id_resultat = 36;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          36 | 80       |        10 |     6 |       1
(1 row)

centre_salut=# update resultats set resultat = NULL where id_resultat = 36;
UPDATE 0

-- Continua sent el mateix

centre_salut=# select * from resultats where id_resultat = 36;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          36 | 80       |        10 |     6 |       1
(1 row)

-- CORRECCIÓ
1) Quan es resultat NULL o '' NO s''ha de parar UPDATE amb RETURN NULL

-- #####################################################################



-- NO MODIFICO LA FUNCIÓ ANTERIOR PEL TRIGGER
-- MODIFICO EL TRIGGER QUE CRIDA A DETERMINA RESULTAT QUE CRIDA A CALCULA RISC

-- EX 4
-- FUNCIONS 

CREATE OR REPLACE FUNCTION calcula_risc(id_prova bigint,resultat varchar,id_pacient bigint default null,data_resultat date default current_date)
RETURNS INT as
$$
DECLARE
	res int := -1;
	searchsql varchar := '';
	searchsql2 varchar := '';
	searchsql3 varchar := '';
	searchsql4 varchar := '';
	sortida varchar := '';
	min_pat int :=0;
	max_pat int :=0;
	min_panic int :=0;
	max_panic int :=0;
	linia record;
	linia2 record;
	calcul_edat varchar := '';
	edat int := -1;
	sexe int := 0;
	data_naix varchar := '';
	trobat bool :=True;
BEGIN
	
	IF id_pacient is null THEN
		id_pacient := 0;
	END IF;
	
	searchsql2:= 'select * from pacients where id_pacient =' || id_pacient || ';';
	
	FOR linia2 in EXECUTE searchsql2 LOOP
		sexe := linia2.sexe;
		data_naix := linia2.data_naix;
	END LOOP;
	
	IF sexe = 0 or data_naix = '' THEN
		trobat := False;
	END IF;
	
	IF trobat THEN
	
		calcul_edat := 'select extract(year from age(current_timestamp,''' || data_naix ||'''));';
		EXECUTE calcul_edat into edat;
		
		searchsql3:= 'select * from tecnica_valors where id_prova =' || id_prova || ' and data_inici <=''' || data_resultat || ''' and sexe =' || sexe || ' and ' || edat::int || ' between edat_inicial and edat_final order by data_inici desc limit 1;';
		--RAISE NOTICE '%s',searchsql3;
		EXECUTE searchsql3 into searchsql;
		
		IF searchsql is Null THEN
			searchsql4:= 'select * from tecnica_valors where id_prova =' || id_prova || ' and data_inici <=''' || data_resultat || ''' and sexe =0 and ' || edat::int || ' between edat_inicial and edat_final order by data_inici desc limit 1;';
			-- RAISE NOTICE '%s',searchsql4;
			sortida := searchsql4;
		ELSE
			sortida := searchsql3;
		END IF;
	
		FOR linia in EXECUTE sortida LOOP
		
			IF resultat is NULL or resultat = '' or resultat = 'NULL' THEN
				res := 1;

			ELSEIF linia.res_numeric = True THEN
				min_pat := linia.min_patologic;
				max_pat := linia.max_patologic;
				min_panic := linia.min_panic;
				max_panic := linia.max_panic;
				
				IF (resultat::int >= max_pat and resultat::int < max_panic) or (resultat::int <= min_pat and resultat::int > min_panic) THEN
					res := 2;
				ELSEIF resultat::int <= min_panic or resultat::int >= max_panic THEN
					res :=3;
				ELSE
					res :=1;
				END IF;
			ELSE
				IF resultat = linia.valor THEN
					res := 2;
				ELSE
					res := 1;
				END IF;
			END IF;	
		END LOOP;
	ELSE
		res := 2;
	END IF;

	RETURN res;
END; 4 |       3 | 2019-03-28
            5 |       3 | 2018-07-07
            6 |       3 | 2018-05-05
            7 |       4 | 2017-12-12
            8 |       3 | 2018-07-07

$$
LANGUAGE 'plpgsql' VOLATILE;


CREATE OR REPLACE FUNCTION determina_resultat(id_resultat bigint)
RETURNS INT AS
$$
DECLARE
	searchsql varchar := '';
	searchsql2 varchar := '';
	linia record;
	an record;
	nom_resultat varchar := '';
	analitica int := -1;
	prova int := -1;
	data_analitica varchar := '';
	pacient int := -1;
	res_final int := -1;

BEGIN
	
	searchsql := 'select * from resultats where id_resultat =' || id_resultat || ';';
	
	FOR linia in EXECUTE searchsql LOOP
		nom_resultat := linia.resultat;
		analitica := linia.analitica;
		prova := linia.prova;
		
		searchsql2 := 'select * from analitiques where id_analitica =' || analitica || ';';
		
		FOR an in EXECUTE searchsql2 LOOP
			data_analitica :=  an.data_analitica;
			pacient := an.pacient;
			
			res_final := calcula_risc(prova::int,nom_resultat,pacient::int,cast(data_analitica as date));
		END LOOP;
	END LOOP;

	RETURN res_final;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;


-- TRIGGER QUE INSERTA A RESULTATS_PATOLOGICS

CREATE OR REPLACE FUNCTION estat_resultat() RETURNS trigger 
AS $resultats_resultat$
DECLARE
  searchsql varchar := '';
  linia record;
  res int :=-1;
BEGIN
	res := determina_resultat(NEW.id_resultat);
	--RAISE NOTICE '%s',res;
	IF res = 2 or res = 3 THEN
		INSERT INTO resultats_patologics VALUES(NEW.id_resultat, current_timestamp, current_user);
	END IF;
	
	-- Busquem si el nou resultat ha estat introduit a la taula resultats_patologics
	searchsql := 'select * from resultats_patologics where id_resultat = ' || NEW.id_resultat || ';';
	
	FOR linia in EXECUTE searchsql LOOP
	-- Si ha estat introduim ja no cal que continuem
		RETURN NULL;
	END LOOP;
	
	-- SI no ha estat introduit, mirem el num_rep
	IF NEW.num_rep > 1 THEN
	-- Afegim a la taula resultats_patologics
		INSERT INTO resultats_patologics values (NEW.id_resultat,current_timestamp, current_user);
	END IF;
	
	RETURN NEW;
END;
$resultats_resultat$ 
LANGUAGE plpgsql;



CREATE TRIGGER estat_resultat AFTER INSERT OR UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE estat_resultat();


-- COMPROVACIÓ
-- EXEMPLE
centre_salut=# select * from resultats where analitica = 2 and prova = 2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           5 | 200      |         2 |     2 |       1
(1 row)
 4 |       3 | 2019-03-28
            5 |       3 | 2018-07-07
            6 |       3 | 2018-05-05
            7 |       4 | 2017-12-12
            8 |       3 | 2018-07-07


centre_salut=# update resultats set resultat = '250' where id_resultat = 5;
NOTICE:  2s
UPDATE 0


centre_salut=# select * from resultats where analitica = 2 and prova = 2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           5 | 200      |         2 |     2 |       1
          50 | 250      |         2 |     2 |       2
(2 rows)


centre_salut=# select * from resultats_patologics ;
 id_resultat |           stamp            |  userid  
-------------+----------------------------+----------
          50 | 2019-03-28 11:40:19.162299 | postgres
(1 row)

-- EXEMPLE 2

centre_salut=# update resultats set resultat = '150' where id_resultat = 50;
NOTICE:  3s
UPDATE 0


centre_salut=# select * from resultats where analitica = 2 and prova = 2;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           5 | 200      |         2 |     2 |       1
          50 | 250      |         2 |     2 |       2
          51 | 150      |         2 |     2 |       3
(3 rows)


centre_salut=# select * from resultats_patologics ;
 id_resultat |           stamp            |  userid  
-------------+----------------------------+----------
          50 | 2019-03-28 11:40:19.162299 | postgres
          51 | 2019-03-28 11:42:03.32756  | postgres
(2 rows)

-- CORRECCIÓ

1) pares INSERT i UPDATE de resultats si trobes resultats_patologics

-- #####################################################################

-- EX 5

-- BORREM EL TRIGGER PER FER L'EXERCICI 5
DROP TRIGGER prova_resultat ON resultats ;


-- MILLORAT EL TRIGGER DE L'EXERCICI 3

CREATE OR REPLACE FUNCTION resultat_prova_3() RETURNS trigger AS
$$
DECLARE
	searchsql varchar := '';
	searchsql2 varchar := '';
	searchsql3 varchar := '';
	data_ana varchar = '';
	linia record;
	linia2 record;
	linia3 record;
	rep int := -1;

BEGIN
	-- Comprovar si el resultat entrat es null
	IF NEW.resultat is NULL or NEW.resultat = '' or NEW.resultat = 'NULL' THEN
		RETURN NULL;
	END IF;
	
	-- Resultats prova/analitica
	searchsql := 'select * from resultats where  analitica = ' || NEW.analitica || 'and prova = ' || NEW.prova || 'and num_rep = 1;';
	
	FOR linia in EXECUTE searchsql LOOP
		-- Comprovar el resultat daquella prova d'aquella analtica entrada es NULL
		
		IF linia.resultat is NULL or linia.resultat = '' or linia.resultat = 'NULL' THEN
			RETURN NULL;
		-- Es repetit
		ELSE
			searchsql2 := 'select * from analitiques where id_analitica = ' || NEW.analitica || ';';
			-- Per l'analitica entrada
			FOR linia2 in EXECUTE searchsql2 LOOP
				data_ana := linia2.data_analitica;
				-- Busquem l'ultim resultat de l'ultima analitica d'aquell pacient per aquella prova
				searchsql3 := 'select * from resultats join analitiques on id_analitica=analitica where pacient = ' || linia2.pacient || ' and id_analitica != ' || NEW.analitica || 'and prova =' || NEW.prova || 'and data_analitica <= ''' || data_ana || ''' order by  data_analitica desc , num_rep desc limit 1;';
				FOR linia3 in EXECUTE searchsql3 LOOP
					NEW.resultat := linia3.resultat;
					NEW.num_rep := rep;
					INSERT INTO resultats values (default,NEW.resultat,NEW.analitica,NEW.prova,NEW.num_rep);
					RETURN NULL;
				END LOOP;
			END LOOP;
		END IF;
	END LOOP;
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER prova_resultat BEFORE UPDATE on resultats
	FOR EACH ROW EXECUTE PROCEDURE resultat_prova_3();


-- COMPROVACIÓ

-- Afago com a exemple el pacient 3 que te 4 analitiques

centre_salut=# select * from analitiques where pacient = 3;
 id_analitica | pacient | data_analitica 
--------------+---------+----------------
            4 |       3 | 2019-03-28
            5 |       3 | 2018-07-07
            6 |       3 | 2018-05-05
            8 |       3 | 2018-07-07
(4 rows)


-- Canvio el resultat de la prova 1 de l'analitica 4 :

update resultats set resultat = 'prova' where id_resultat = 12;
UPDATE 0

-- Com que ha trobat un resultat de la prova 1 a l'analitica 8, l'agafa i el substitueix.

centre_salut=# select * from resultats where prova = 1 and analitica = 4;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          12 | Positiu  |         4 |     1 |       1
          52 | Positiu  |         4 |     1 |      -1
(2 rows)


centre_salut=# select * from resultats where analitica = 8 and prova = 1;
 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
          27 | Positiu  |         8 |     1 |       1
(1 row)



-- CORRECCIÓ
1) fas insert amb -1 per cada resultat de la prova, només s'ha de fer pel que s'està modificant




















