-- nom: Jose otero perez
-- dni: 41005342E
-- #############################################################################

-- EXAMEN TRIGGERS 2018-2019

-- #NUEVA TABLA RESULTADOS
-- ################################################################################
CREATE TABLE resultats(
  id_resultat bigserial PRIMARY KEY,
  resultat varchar(50),
  analitica bigint not null references analitiques(id_analitica),
  prova bigint not null references proves(id_prova),
  num_rep int default 1,
  unique (analitica, prova,num_rep)
);

-- ################################################################################
CREATE TABLE resultats_patologics(
	id_resultat int not null,
	stamp timestamp not null default current_timestamp
);


-- ###################################################################################
-- #inserts NULLs
INSERT INTO resultats values (DEFAULT,'NULL',1,1);
INSERT INTO resultats values (DEFAULT,'NULL',1,2);
INSERT INTO resultats values (DEFAULT,'NULL',1,3);

INSERT INTO resultats values (DEFAULT,'NULL',2,3);
-- ################################################################################
CREATE OR REPLACE FUNCTION primer_ejercicio()
RETURNS TRIGGER
AS
$emp_stamp$
DECLARE
linia record;
searchsql varchar :='';
BEGIN
if NEW.resultat = 'NULL' or NEW.resultat ='' then
  return null;
end if;
searchsql := 'select * from resultats where analitica =' || NEW.analitica || 'and prova =' || NEW.prova || 'and num_rep=1;';
for linia in execute searchsql LOOP
  if linia.resultat = 'NULL' or linia.resultat = '' THEN
  RAISE NOTICE 'ahora insertamos %',NEW.resultat;
  return null;
  end if;
end loop;
return null;
END;
$emp_stamp$
LANGUAGE 'plpgsql';
-- #############################################################################
-- Resultado
-- centre_salut=# update resultats set resultat = '133' where id_resultat = 1;
-- NOTICE:  ahora insertamos 133
-- UPDATE 0
-- ################################################################################
-- CORRECCIÓ
1) if linia.resultat = 'NULL' or linia.resultat = '' THEN --> l'insert s'ha de fer quan el resultat anterior no és
ni NULL ni ''
2) no cal fer select de resultats, està a OLD
3) no has posat el CREATE TRIGGER
4) return NULL para operació UPDATE, i només s''ha de parar en el cas que es faci  INSERT

CREATE OR REPLACE FUNCTION segundo_ejercicio()
RETURNS TRIGGER
AS
$emp_stamp$
DECLARE
linia record;
searchsql varchar :='';
BEGIN
if NEW.resultat = 'NULL' or NEW.resultat ='' then
  return null;
end if;
searchsql := 'Select * from resultats where analitica='|| NEW.analitica || 'and prova=' || NEW.prova ||';';
for linia in execute searchsql LOOP
  if linia.resultat = 'NULL' or linia.resultat = '' THEN
    return new;
  else
      NEW.num_rep := 2;
      INSERT INTO resultats values (DEFAULT,NEW.resultat,NEW.analitica,NEW.prova,NEW.num_rep);
  end if;
end loop;
return null;
END;
$emp_stamp$
LANGUAGE 'plpgsql';

-- ################################################################################
-- Pruebas

-- INSERT INTO resultats values (DEFAULT,'100',1,6);
-- update resultats set resultat = '133' where id_resultat = 4;
-- centre_salut=# select * from resultats;
--  id_resultat | resultat | analitica | prova | num_rep
-- -------------+----------+-----------+-------+---------
--            1 | NULL     |         1 |     1 |       1
--            2 | NULL     |         1 |     2 |       1
--            3 | NULL     |         1 |     3 |       1
--            4 | 100      |         1 |     6 |       1
--            5 | 133      |         1 |     6 |       2
-- (5 rows)

-- CORRECCIÓ

1) return NULL para operació UPDATE, i només s''ha de parar en el cas que es faci INSERT
-- #################################################################################

CREATE OR REPLACE FUNCTION tercer_ejercicio()
RETURNS TRIGGER
AS
$emp_stamp$
DECLARE
linia record;
searchsql varchar :='';
BEGIN
if NEW.resultat = 'NULL' or NEW.resultat ='' then
  return null;
end if;
searchsql := 'select * from resultats where analitica ='|| NEW.analitica ||' and prova='||NEW.prova||' order by num_rep desc limit 1;';
for linia in execute searchsql LOOP
  if linia.resultat = 'NULL' or linia.resultat = '' THEN
    return new;
  else
    NEW.num_rep := linia.num_rep + 1;
    RAISE NOTICE 'ahora insertamos %',NEW.num_rep;
      INSERT INTO resultats values (DEFAULT,NEW.resultat,NEW.analitica,NEW.prova,NEW.num_rep);
  end if;
end loop;
return null;
END;
$emp_stamp$
LANGUAGE 'plpgsql';

-- update resultats set resultat = '500' where id_resultat = 5;
--
--   centre_salut=# select * from resultats;
--    id_resultat | resultat | analitica | prova | num_rep
--   -------------+----------+-----------+-------+---------
--              1 | NULL     |         1 |     1 |       1
--              2 | NULL     |         1 |     2 |       1
--              3 | NULL     |         1 |     3 |       1
--              4 | 100      |         1 |     6 |       1
--              5 | 133      |         1 |     6 |       2
--              6 | 500      |         1 |     6 |       3
--
--   (6 rows)

-- CORRECCIÓ
2) Només s'ha de parar UPDATE amb RETURN NULL quan es fa l'INSERT, en els altres casos ha de tornar NEW

################################################################################


CREATE OR REPLACE FUNCTION cuarto_ejercicio()
RETURNS TRIGGER
AS
$emp_stamp$
DECLARE
linia record;
searchsql varchar :='';
BEGIN
if NEW.resultat = 'NULL' or NEW.resultat ='' then
  return null;
end if;
searchsql := 'select * from resultats where analitica ='|| NEW.analitica ||' and prova='||NEW.prova||' order by num_rep desc limit 1;';
for linia in execute searchsql LOOP
  if linia.resultat = 'NULL' or linia.resultat = '' THEN
    return new;
  else
    NEW.num_rep := linia.num_rep + 1;
    RAISE NOTICE 'ahora insertamos %',NEW.num_rep;
      INSERT INTO resultats values (DEFAULT,NEW.resultat,NEW.analitica,NEW.prova,NEW.num_rep);
      INSERT INTO resultats_patologics values (linia.id_resultat);
  end if;
end loop;
return null;
END;
$emp_stamp$
LANGUAGE 'plpgsql';

-- centre_salut=# update resultats set resultat = '500' where id_resultat=11
-- ;
-- NOTICE:  ahora insertamos 4
-- UPDATE 0
-- centre_salut=# select * from resultats_patologics ;
--  id_resultat |           stamp
-- -------------+----------------------------
--            1 | 2019-03-28 11:29:12.956944
--           18 | 2019-03-28 11:45:40.216096
-- (2 rows)
-- #### Modificacion del trigger asociado a la tabla resultados

CREATE OR REPLACE FUNCTION patolosirve()
RETURNS TRIGGER
AS
$emp_stamp$
DECLARE
mark as varchar
BEGIN
mark := calcula_risc(NEW.id_resultat);
IF mark = '2' or mark = '3' THEN
searchsql := 'select * from resultats_patologics where id_resultat ='|| NEW.id_resultat ||';';
for linia in execute searchsql LOOP
  return NULL;
INSERT INTO resultats_patologics(NEW.id_resultat, now(), user);
END IF;
RETURN NEW;
END;
$emp_stamp$
LANGUAGE 'plpgsql';

CREATE TRIGGER secure_insert AFTER INSERT OR UPDATE ON resultats
	FOR EACH ROW EXECUTE PROCEDURE patolosirve();

-- CORRECCIÓ
1) no has entergat proves i resultats
2) pares INSERT i UPDATE de resultats si trobes resultats_patologics


  -- se modifica el trigger para que valide si el resultado que va a insertar ya esta
  -- en la tabla resultats_patologics..

-- ################################################################################

CREATE OR REPLACE FUNCTION quinto_ejercicio()
RETURNS TRIGGER
AS
$emp_stamp$
DECLARE
linia record;
linia2 record;
linia3 record;
linia4 record;
searchsql varchar :='';
searchsql2 varchar :='';
searchsql3 varchar :='';
searchsql4 varchar :='';
BEGIN
if NEW.resultat = 'NULL' or NEW.resultat ='' then
  return null;
end if;
searchsql2 := ' select * from resultats where analitica =' || NEW.analitica || 'and prova=' || NEW.prova || 'and resultat ='''|| NEW.resultat ||''';';
for linia2 in execute searchsql2 LOOP
  searchsql3 := 'select * from analitiques where id_analitica =' || NEW.analitica ||';';
  for linia3 in execute searchsql3 LOOP
    searchsql4 := 'select * from resultats join analitiques on id_analitica=analitica where pacient =' || linia3.pacient || 'and analitiques.id_analitica !=' || NEW.analitica ||'order by num_rep desc limit 1';
    for linia4 in execute searchsql4 LOOP
      NEW.resultat := linia4.resultat;
      NEW.num_rep := -1;
      return NEW;
    end loop;
  end loop;
end loop;
searchsql := 'select * from resultats where analitica ='|| NEW.analitica ||' and prova='||NEW.prova||' order by num_rep desc limit 1;';
for linia in execute searchsql LOOP
  if linia.resultat = 'NULL' or linia.resultat = '' THEN
    return new;
  else
    NEW.num_rep := linia.num_rep + 1;
    RAISE NOTICE 'ahora insertamos %',NEW.num_rep;
      INSERT INTO resultats values (DEFAULT,NEW.resultat,NEW.analitica,NEW.prova,NEW.num_rep);
      INSERT INTO resultats_patologics values (linia.id_resultat);
  end if;
end loop;
return null;
END;
$emp_stamp$
LANGUAGE 'plpgsql';

-- centre_salut=# update resultats set resultat='500' where id_resultat=7;
-- centre_salut=# select * from resultats;
--  id_resultat | resultat | analitica | prova | num_rep
-- -------------+----------+-----------+-------+---------
--            3 | NULL     |         1 |     3 |       1
--            4 | 100      |         1 |     6 |       1
--            5 | 133      |         1 |     6 |       2
--            6 | 500      |         1 |     6 |       3
--            8 | 200      |         1 |     1 |       2
--            2 | 200      |         1 |     2 |       2
--            1 | 200      |         1 |     1 |       1
--           10 | 200      |         2 |     3 |       1
--           11 | 300      |         2 |     3 |       2
--           18 | 400      |         2 |     3 |       3
--           19 | 500      |         2 |     3 |       4
--            7 | 500      |         1 |     6 |      -1
-- (12 rows)

-- centre_salut=# update resultats set resultat='12' where id_resultat=18;
-- NOTICE:  ahora insertamos 4
-- UPDATE 0
-- centre_salut=# select * from resultats;
--  id_resultat | resultat | analitica | prova | num_rep
-- -------------+----------+-----------+-------+---------
--            3 | NULL     |         1 |     3 |       1
--            4 | 100      |         1 |     6 |       1
--            5 | 133      |         1 |     6 |       2
--            6 | 500      |         1 |     6 |       3
--            8 | 200      |         1 |     1 |       2
--            2 | 200      |         1 |     2 |       2
--            1 | 200      |         1 |     1 |       1
--           10 | 200      |         2 |     3 |       1
--           11 | 300      |         2 |     3 |       2
--           18 | 400      |         2 |     3 |       3
--            7 | 500      |         1 |     6 |      -1
--           19 | 500      |         2 |     3 |      -1
--           20 | 12       |         2 |     3 |       4
-- (13 rows)

-- ##TRIGGER

CREATE TRIGGER aix_aix BEFORE UPDATE ON resultats
  FOR EACH ROW EXECUTE PROCEDURE primer_ejercicio();
  
  -- CORRECCIÓ
1) per cada resulat repetit que tingui la prova fas insert amb -1 de resultat anterior, i només s'ha 
de fer un cop pel resultat que s'està modificant

