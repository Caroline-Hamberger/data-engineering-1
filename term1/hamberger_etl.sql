## Creating a denormalized data layer focusing on the names and powers of superheroes
DROP PROCEDURE IF EXISTS HeroPowers;
DELIMITER //

CREATE PROCEDURE HeroPowers()
BEGIN

	DROP TABLE IF EXISTS hero_powers;

	CREATE TABLE hero_powers AS
	SELECT  
	   s.superhero_name AS HeroName, 
	   hp.power_id AS PowerID, 
	   sp.power_name AS Power,
	   ha.hero_id AS HeroID
	FROM
		superhero s
	INNER JOIN hero_attribute ha ON s.id = ha.hero_id
	INNER JOIN hero_power hp ON s.id = hp.hero_id
	INNER JOIN superpower sp ON hp.power_id = sp.id
		GROUP BY s.id, s.superhero_name, sp.power_name
		ORDER BY SUM(ha.attribute_value)
		DESC;

END //
DELIMITER ;

	
CALL HeroPowers();



## Checking if "event_scheduler" is running correctly
SHOW VARIABLES LIKE "event_scheduler";

## Calling HeroPowers (from hamberger_analytical_layer) every 1 minute in the next 1 hour to check if we can schedule events correctly
DROP EVENT IF EXISTS HeroPowersEvent;
DELIMITER $$

CREATE EVENT HeroPowersEvent
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ENDS CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
	BEGIN
		INSERT INTO messages SELECT CONCAT('event:',NOW());
    		SELECT * FROM hero_powers;
	END $$
DELIMITER ;

SHOW EVENTS;

## Creating a trigger that will activate if 
DROP TRIGGER IF EXISTS after_superhero; 
DELIMITER $$

CREATE TRIGGER after_superhero
AFTER INSERT
ON superhero FOR EACH ROW
BEGIN
	
    	INSERT INTO messages SELECT CONCAT('new superhero_name: ', NEW.superhero_name);

  	INSERT INTO hero_powers
	SELECT 
       s.superhero_name AS HeroName, 
	   hp.power_id AS PowerID, 
	   ha.hero_id AS HeroID,
       ha.attribute_value AS TotalAttributes,
       UPPER(sp.power_name) AS Power
	FROM
		superhero s
	INNER JOIN hero_attribute ha ON s.id = ha.hero_id
	INNER JOIN hero_power hp ON s.id = hp.hero_id
	INNER JOIN superpower sp ON hp.power_id = sp.id
		WHERE superhero_name = NEW.superhero_name
	GROUP BY s.id, s.superhero_name, sp.power_name, ha.attribute_value
	ORDER BY SUM(ha.attribute_value)
	DESC;
        
END $$

DELIMITER ;


## Activating the trigger
SELECT * FROM hero_powers ORDER BY PowerID;

INSERT INTO hero_powers VALUES("BestSuperhero", 200, "BestPower",999);

SELECT * FROM hero_powers ORDER BY PowerID DESC;


