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