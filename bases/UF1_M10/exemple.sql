CREATE OR REPLACE FUNCTION pri_sel(id_cli integer)
RETURNS text AS
$$
DECLARE
    result text := '';
    searchsql text := '';
    var_match record;
BEGIN
     searchsql := 'SELECT * FROM prova WHERE a = ' || $1;      
     FOR var_match IN EXECUTE(searchsql) LOOP
          IF result > '' THEN
              result := result || ';' || var_match.a || '= ' || var_match;
          ELSE
              result := var_match.a || '= ' ||var_match;
         END IF;
    END LOOP;
    IF result = '' THEN
	result := 'Dades inexistents';
    END IF;
    RETURN searchsql || ': ' || result;
EXCEPTION 
    WHEN others THEN return '5';
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;

cadena varchar := 'TRWAGMYFPDXBNJZSQVHLCKE';
