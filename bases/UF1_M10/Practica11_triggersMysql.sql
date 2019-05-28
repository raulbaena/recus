DELIMITER //
CREATE FUNCTION VerboseCompare (n INT, m INT)
  RETURNS VARCHAR(50)

  BEGIN
    DECLARE s VARCHAR(50);

    IF n = m THEN SET s = 'equals';
    ELSE
      IF n > m THEN SET s = 'greater';
      ELSE SET s = 'less';
      END IF;

      SET s = CONCAT('is ', s, ' than');
    END IF;

    SET s = CONCAT(n, ' ', s, ' ', m, '.');

    RETURN s;
  END //

DELIMITER ;

----------------------------------------------------------------------------------------

delimiter #

create trigger VPLS_nodeB_before_ins_trig before insert on VPLS_nodeB
for each row

BEGIN
DECLARE nb INT default 0;
DECLARE nba INT default 0;

SET NEW.VPLS_ID_NodeB = CONCAT('21100', LPAD(NEW.VPLS_ID_NodeB,4,0));
SET nb = (SELECT COUNT(DISTINCT(VPLS_ID_aggregation)) FROM VPLS_nodeB WHERE id_ORT = NEW.id_ORT);

IF(nb > 5) THEN
    SET nba = nb + 1;
ELSE
    SET nba = nb;
END IF;

SET NEW.VPLS_ID_aggregation = CONCAT('21188', LPAD(NEW.id_ORT,2,0), LPAD(nba,2,0));

END#

delimiter ;
----------------------------------------------------------------------------------------


DELIMITER ||
DROP TRIGGER IF EXISTS insert_products_tags;
||
DELIMITER @@
CREATE TRIGGER insert_products_tags AFTER INSERT ON products
  FOR EACH ROW
  BEGIN
    DECLARE current_id integer;
    DECLARE tag_id integer;
    DECLARE next integer;
    DECLARE tag_field varchar(255);
    DECLARE next_sep integer;
    DECLARE current_tag varchar(255);
    DECLARE right_tag varchar(255);
 
    -- We use the field other as comma-separated tag_field
    SET tag_field = NEW.other;
 
    -- Check for empty tags
    IF (CHAR_LENGTH(tag_field) <> 0) THEN
        -- Loop until no more ocurrencies
       set next = 1;
       WHILE next = 1 DO
         -- Find possition of the next ","
         SELECT INSTR(tag_field, ',') INTO next_sep;
         IF (next_sep > 0) THEN
            SELECT SUBSTR(tag_field, 1, next_sep - 1) INTO current_tag;
            SELECT SUBSTR(tag_field, next_sep + 1, CHAR_LENGTH(tag_field)) INTO right_tag;
            set tag_field = right_tag;
         ELSE
           set next = 0;
           set current_tag = tag_field;
         END IF;
 
         -- Drop spaces between comas
         SELECT TRIM(current_tag) INTO current_tag;
 
         -- Insert the tag if not already present
         IF (NOT EXISTS (SELECT tag FROM freetags WHERE tag = current_tag)) THEN
           -- Insert the tag
           INSERT INTO freetags (tag) values (current_tag);
           SELECT LAST_INSERT_ID() INTO tag_id;
         ELSE
           -- Or get the id
           SELECT id FROM freetags WHERE tag = current_tag INTO tag_id;
         END IF;
 
         -- Link the object tagged with the tag
         INSERT INTO freetagged_objects
           (tag_id, object_id, module)
            values
           (tag_id, NEW.id, 'products');
       END WHILE;
    END IF;
  END;
@@
----------------------------------------------------------------------------------------
DELIMITER ||
DROP TRIGGER IF EXISTS update_products_tags;
||
DELIMITER @@
CREATE TRIGGER update_products_tags BEFORE UPDATE ON products
  FOR EACH ROW
  BEGIN
    DECLARE current_id integer;
    DECLARE tag_id integer;
    DECLARE next integer;
    DECLARE tag_field varchar(255);
    DECLARE next_sep integer;
    DECLARE current_tag varchar(255);
    DECLARE right_tag varchar(255);
 
    -- We use the field other as comma-separated tag_field
    SET tag_field = NEW.other;
 
    -- Only act if the field changes
    IF (tag_field <> OLD.other) THEN
      -- At the moment we regenerate the tags (not compare), needs some thinking because compare can be
      -- more performance killer
      DELETE FROM freetagged_objects WHERE object_id = OLD.id AND module = 'products';
      -- Insert again if not empty
      IF (CHAR_LENGTH(tag_field) <> 0) THEN
          -- Loop until no more ocurrencies
         set next = 1;
         WHILE next = 1 DO
           -- Find possition of the next ","
           SELECT INSTR(tag_field, ',') INTO next_sep;
           IF (next_sep > 0) THEN
              SELECT SUBSTR(tag_field, 1, next_sep - 1) INTO current_tag;
              SELECT SUBSTR(tag_field, next_sep + 1, CHAR_LENGTH(tag_field)) INTO right_tag;
              set tag_field = right_tag;
           ELSE
             set next = 0;
             set current_tag = tag_field;
           END IF;
 
           -- Drop spaces between comas
           SELECT TRIM(current_tag) INTO current_tag;
 
           -- Insert the tag if not already present
           IF (NOT EXISTS (SELECT tag FROM freetags WHERE tag = current_tag)) THEN
             -- Insert the tag
             INSERT INTO freetags (tag) values (current_tag);
             SELECT LAST_INSERT_ID() INTO tag_id;
           ELSE
             -- Or get the id
             SELECT id FROM freetags WHERE tag = current_tag INTO tag_id;
           END IF;
 
           -- Link the object tagged with the tag
           INSERT INTO freetagged_objects
             (tag_id, object_id, module)
              values
             (tag_id, NEW.id, 'products');
         END WHILE;
      END IF;
    END IF;
  END;
@@