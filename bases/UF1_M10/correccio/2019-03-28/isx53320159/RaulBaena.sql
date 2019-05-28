alter table resultats add num_rep int default 1;

 id_resultat | resultat | analitica | prova | num_rep 
-------------+----------+-----------+-------+---------
           1 | Negatiu  |         1 |     1 |       1
           2 | Negatiu  |         1 |     2 |       1
           3 | 200      |         2 |     2 |       1
           4 | 150      |         3 |     2 |       1
           5 | Positiu  |         4 |     1 |       1
          35 | hola     |         4 |     3 |       1
          38 | Negatiu  |         1 |     5 |       1
          39 | Negatiu  |         1 |     6 |       1
          40 | 60       |         1 |     7 |       1
(9 rows)

--1 Quan arribi un resultat per una prova d’una analítica, 
--i sempre que el resultat que arriba sigui diferent de -
--NULL (o ‘’),  sabrem si és un resultat nou o un 
--resultat repetit mirant si el resultat que 
--tenim guardat amb num_rep=1 és NULL (o ‘’) o no és NULL (o ‘’) .
  
CREATE OR REPLACE FUNCTION insert_resultat_repetit() 
RETURNS TRIGGER AS $insert_resultat$
DECLARE
    searchsql varchar := '';
    linia record;
    resultado varchar := '';
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF NEW.resultat IS NULL or NEW.resultat = '' THEN
            RAISE NOTICE 'el resultat es null %', NEW.resultat;
        ELSE 
            searchsql := 'select * from resultats where analitica = '||NEW.analitica||' and prova ='||NEW.prova||' ORDER BY num_rep desc limit 1;';
            FOR linia in execute searchsql loop
                resultado := linia.resultat;
            END loop;
            IF resultado IS NULL or resultado = '' THEN
                RAISE NOTICE 'el resultat es null %', resultado;
            ELSE
                RAISE NOTICE 'Insertem resultat %', resultado;
            END IF;
        END IF;
    END IF;
END;
$insert_resultat$ 
LANGUAGE plpgsql;     

CREATE TRIGGER avisa_resultat AFTER UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE insert_resultat_repetit();
-- CORRECCIÓ
1) el trigger ha de ser BEFORE
2) no has entregat resultats

--2 En el cas que el resultat actual no sigui NULL 
--(o ‘’), en lloc de modificar el registre de la taula 
--resultats, se’n crearà un de nou (per aquesta part de l’examen, amb el valor 2 a num_rep)
CREATE OR REPLACE FUNCTION insert_resultat_repetit() 
RETURNS TRIGGER AS $insert_resultat$
DECLARE
    searchsql varchar := '';
    linia record;
    resultado varchar := '';
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF NEW.resultat IS NULL or NEW.resultat = '' THEN
            RAISE NOTICE 'el resultat es null %', NEW.resultat;
        ELSE 
            searchsql := 'select * from resultats where analitica = '||NEW.analitica||' and prova = '||NEW.prova||' ORDER BY num_rep desc limit 1;';
            FOR linia in execute searchsql loop
                resultado := linia.resultat;
            END loop;
            IF resultado IS NULL or resultado = '' THEN
                RAISE NOTICE 'el resultat es null %', resultado;
            ELSE
                INSERT INTO resultats VALUES (DEFAULT,NEW.resultat,NEW.analitica,NEW.prova,2);
                RETURN NEW;
            END IF;
        END IF;
    END IF;
RETURN NEW;
END;
$insert_resultat$ 
LANGUAGE plpgsql;  

CREATE TRIGGER inserta_resultat BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE insert_resultat_repetit();
-- CORRECCIÓ
1) quan es fa l''INSERT ha de ser RETURN NULL per parar UPDATE
2) no has entregat resultats

--3 Aquest nou registre tindrà a num_rep el valor de l’últim num_rep 
--guardat per aquella analítica i prova incrementat en 1.

CREATE OR REPLACE FUNCTION insert_resultat_repetit() 
RETURNS TRIGGER AS $insert_resultat$
DECLARE
    searchsql varchar := '';
    linia record;
    resultado varchar := '';
    num_repetit int := 0;
    increment int := 1;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF NEW.resultat IS NULL or NEW.resultat = '' THEN
            RAISE NOTICE 'el resultat es null %', NEW.resultat;
        ELSE 
            searchsql := 'select * from resultats where analitica = '||NEW.analitica||' and prova = '||NEW.prova||' ORDER BY num_rep desc limit 1;';
            FOR linia in execute searchsql loop
                resultado := linia.resultat;
                num_repetit := linia.num_rep
            END loop;
            IF resultado IS NULL or resultado = '' THEN
                RAISE NOTICE 'el resultat es null %', resultado;
            ELSE
                INSERT INTO resultats VALUES (DEFAULT,NEW.resultat,NEW.analitica,NEW.prova,num_repetit+increment);
                RETURN NEW;
            END IF;
        END IF;
    END IF;
END;
$insert_resultat$ 
LANGUAGE plpgsql;  
CREATE TRIGGER inserta_resultat BEFORE UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE insert_resultat_repetit();

-- CORRECCIÓ
1) quan es fa l''INSERT ha de ser RETURN NULL per parar UPDATE
2) en els altres casos ha de ser RETURN NEW

--4 
CREATE OR REPLACE FUNCTION insert_resultat_patologic() 
RETURNS TRIGGER AS $insert_patologic$
DECLARE
searchsql2 varchar := '';
searchsql varchar := '';
linia record;
BEGIN
searchsql2 varchar := 'select * from resultats;';
searchsql := 'select * from resultats where num_rep != 1;';
for linia in execute searchsql loop
    insert into resultats_patologics values(New.id_resultat,current_timestamp,pacient);
END loop;
$insert_patologic$ 
LANGUAGE plpgsql;  
CREATE TRIGGER inserta_resultat AFTER UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE insert_resultat_patologic();
	
-- CORRECCIÓ
1) gas insert per cada rsulatt repetit que hi hagi i no només pel que s'està modificant

