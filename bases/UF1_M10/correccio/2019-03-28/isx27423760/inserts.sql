CREATE TABLE resultats(
	id_resultat bigserial PRIMARY KEY,
	resultat varchar(50),   /*treiem NULL per fer la practica 3*/
	id_analitica bigint not null references analitiques(id_analitica),
	id_prova bigint not null references proves(id_prova),
	num_rep int not null
);

/*Funcions necesarias per al triger revisa patoligica*/

CREATE OR REPLACE FUNCTION calcula_risc(id_prova bigint,id_pacient bigint,resultat character varying ,date_resultat date default current_date)
RETURNS INT AS
$$
DECLARE
	sql1 varchar := '';
	linia1 record;
	sql2 varchar := '';
	linia2 record;
	searchsql varchar := '';
	linia record;
	sexe_pac int:=0 ;
	datanaix text;
	edat_pac text;
	min_patologic int := 0;
	max_patologic int := 0;
	min_panic int := 0;
	max_panic int := 0;
	resultado int := 0;
	valor1 varchar := '';
	cas int := -1;
	trobat bool := False;
	trobat_pac bool := False;
BEGIN
	IF resultat is NULL or resultat = '' THEN
		resultado := 1;
	END IF;
	IF id_pacient IS NULL THEN
		resultado := 2; -- resultat patologic si no hi ha cap pacient a la base de dades
	ELSE
		sql1 := 'select * from pacients where id_pacient='|| id_pacient || ';';
		FOR linia1 IN EXECUTE sql1 LOOP
			sexe_pac := linia1.sexe;
			datanaix := linia1.data_naix;
			edat_pac := extract(year from age(CURRENT_DATE,linia1.data_naix));
		END LOOP;
		IF sexe_pac IS NULL OR datanaix IS NULL THEN
			resultado := 2;
		ELSE
			-- ~ raise notice 'sexe : %  , edat: %' , sexe_pac,edat_pac;
			searchsql := 'select * from tecnica_valors where id_prova = ' || id_prova || ' and sexe = ' || sexe_pac::int || ' and 
			( edat_inicial <= '|| edat_pac::int ||' and  edat_final >= '|| edat_pac::int ||') order by data_inici desc limit 1;';
			FOR linia IN EXECUTE searchsql LOOP
				trobat_pac := True;
				-- ~ raise notice '%',linia;
				IF linia.data_inici <= $4 AND trobat = False THEN
					trobat := True;
					IF linia.res_numeric  THEN
						min_patologic := linia.min_patologic;
						max_patologic := linia.max_patologic;
						min_panic := linia.min_panic;
						max_panic := linia.max_panic;
						cas := 0;
					ELSE
						valor1 := linia.valor;
						cas := 1;
					END IF;
					IF cas = 0 THEN
						IF resultat::int > min_patologic and resultat::int <  max_patologic THEN
							resultado := 1;
						ELSEIF resultat::int <= min_panic OR resultat::int >= max_panic THEN
							resultado := 3;
						ELSE
							resultado := 2;
						END IF;
					ELSE
						IF $3 != valor1 THEN
							resultado := 1;
						ELSE 
							resultado := 3;
						END IF;
					END IF;
				END IF;
			END LOOP;
			IF trobat_pac = False THEN
				sexe_pac := 0 ;
				-- ~ raise notice 'sexe : %  , edat: %' , sexe_pac,edat_pac;
				sql2 := 'select * from tecnica_valors where id_prova = ' || id_prova || ' and sexe = ' || sexe_pac || ' and 
				( edat_inicial <= '|| edat_pac::int ||' and  edat_final >= '|| edat_pac::int ||') order by data_inici desc limit 1;';
				FOR linia2 IN EXECUTE sql2 LOOP
					-- ~ raise notice '%',linia2;
					IF linia2.data_inici <= $4 AND trobat = False THEN
						trobat := True;
						IF linia2.res_numeric  THEN
							min_patologic := linia2.min_patologic;
							max_patologic := linia2.max_patologic;
							min_panic := linia2.min_panic;
							max_panic := linia2.max_panic;
							cas := 0;
						ELSE
							valor1 := linia2.valor;
							cas := 1;
						END IF;
						IF cas = 0 THEN
							IF resultat::int > min_patologic and resultat::int <  max_patologic THEN
								resultado := 1;
							ELSEIF resultat::int <= min_panic OR resultat::int >= max_panic THEN
								resultado := 3;
							ELSE
								resultado := 2;
							END IF;
						ELSE
							IF $3 != valor1 THEN
								resultado := 1;
							ELSE 
								resultado := 3;
							END IF;
						END IF;
					END IF;
				END LOOP;
			END IF;
		END IF;
	END IF;
	RETURN resultado;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;


/*select calcula_risc(5,4,'150')*/


/*select calcula_risc(2,1,'199');*/


CREATE OR REPLACE FUNCTION calcula_res(id_resultat bigint)
RETURNS INT AS
$$
DECLARE
	searchsql varchar := '';
	conv varchar := '';
	searchsql2 varchar := '';
	linia record;
	linia2 record;
	id_paciente int := 0;
	resultado int := -1;
	valor varchar := '';
	cas int := -1;
	trobat bool := False;
BEGIN
	searchsql := 'select * from resultats where id_resultat = ' || $1 || ';';
	FOR linia IN EXECUTE searchsql LOOP
		searchsql2 := 'select * from analitiques where id_analitica = ' || linia.id_analitica || ';';
		FOR linia2 IN EXECUTE searchsql2 LOOP
			resultado := calcula_risc(linia.id_prova,linia2.id_pacient,linia.resultat,linia2.data_analitica);
		END LOOP;
	END LOOP;
	RETURN resultado;
END;
$$
LANGUAGE 'plpgsql' VOLATILE;


