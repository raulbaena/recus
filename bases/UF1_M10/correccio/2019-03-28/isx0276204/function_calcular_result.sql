CREATE OR REPLACE FUNCTION calcula_resultat(id_resultat bigint)
RETURNS INT AS
$$
DECLARE
	searchsql varchar := '';
	searchsql2 varchar := '';
	linia record;
	linia2 record;
	id_prova int := 0;
	resultat varchar := '';
	id_pacient int := 0;
	id_analitica int := 0;
	fecha_analitica date ;
	resultado_final int := -1;
BEGIN
	searchsql := 'select * from resultats where id_resultat = ' || $1 || ';';
	FOR linia IN EXECUTE searchsql LOOP
		id_prova := linia.id_prova;
		resultat := linia.resultat;
		id_analitica := linia.id_analitica;
	
		searchsql2 := 'select * from analitiques where id_analitica = ' || id_analitica || ';';
		FOR linia2 IN EXECUTE searchsql2 LOOP
			id_pacient := linia2.id_pacient;
			fecha_analitica := linia2.date_analitica;
			resultado_final := calcula_risc(id_prova,id_pacient,resultat,fecha_analitica);
		END LOOP;
	END LOOP;
	RETURN resultado_final;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;
