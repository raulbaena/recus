CREATE OR REPLACE FUNCTION calcula_risc
	(id_prova int,
	id_pacient int,
	resultat varchar,
	date_result date default current_date)
RETURNS TEXT AS
$$
DECLARE
	searchsql varchar := '';
	linia record;
	min_patologic int := 0;
	max_patologic int := 0;
	min_panic int := 0;
	max_panic int := 0;
	resultado int := 0;
	valor varchar := '';
	cas int := 0;
	trobat bool := false;
BEGIN
	searchsql := 'select * from tecnica_valors where id_prova = '
	 || $1 || ' order by data_inici desc ;';
	FOR linia IN EXECUTE searchsql LOOP
	  IF linia.data_inici < date_result and trobat = false then
		trobat := true;
	  
		IF linia.res_numeric THEN
			min_patologic := linia.min_patologic;
			max_patologic := linia.max_patologic;
			min_panic := linia.min_panic;
			max_panic := linia.max_panic;
		ELSE
			valor := linia.valor;
			cas := 1;
		END IF;
	  END if;
	END LOOP;
	IF cas = 0 THEN
		--raise notice '% % %',resultat::int,min_patologic,max_patologic;
		IF resultat::int > min_patologic and resultat::int <  max_patologic THEN
			resultado := 1;
		ELSEIF resultat::int > min_panic and resultat::int < max_panic THEN
			resultado := 2;
		ELSE
			resultado := 3;
		
		END IF;
	ELSE
		IF resultat = valor THEN
			resultado := 3;--equal to str of table
		ELSE 
			resultado := 1;--different than table str
		END IF;
	END IF;
	RETURN  resultado;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;


/*INSERT INTO pacients values 
(0,'Daniel','Cano Andújar','53320079F','06-06-1997',610913197,'Carrer Ànger Guimerà Nº13');
INSERT INTO pacients values 
(1,'Sergi','Muñoz Carmona','12345678A','08-03-1998',987654321,'Carrer del retard Nº1');
*/
