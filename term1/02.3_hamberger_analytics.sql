USE superhero;

## The top most intelligent DC characters
DROP VIEW IF EXISTS `Smartest_Superheroes`;
CREATE VIEW `Smartest_Superheroes` AS
SELECT
s.id,
s.superhero_name,
p.publisher_name,
ha.attribute_value
FROM superhero s
INNER JOIN publisher p ON s.publisher_id = p.id
LEFT JOIN hero_attribute ha ON s.id = ha.hero_id
LEFT JOIN attribute a ON ha.attribute_id = a.id
WHERE p.id = (4) AND a.id = 1 AND attribute_value = 100
GROUP BY s.id, s.superhero_name, p.publisher_name
ORDER BY ha.attribute_value
DESC;

select * from Smartest_Superheroes;


## Top three human women by total attribute score
DROP VIEW IF EXISTS `Best_Human_Women`;
CREATE VIEW `Best_Human_Women` AS
SELECT
s.id,
s.superhero_name,
r.race,
g.gender,
SUM(ha.attribute_value) AS total_attributes
FROM superhero s
INNER JOIN race r ON s.race_id = r.id
LEFT JOIN hero_attribute ha ON s.id = ha.hero_id
LEFT JOIN attribute a ON ha.attribute_id = a.id
LEFT JOIN gender g ON s.gender_id = g.id
WHERE r.id = 24 AND attribute_value = 100 AND g.id = 2
GROUP BY s.id, s.superhero_name, r.race, g.gender
ORDER BY SUM(ha.attribute_value)
DESC;

select * from Best_Human_Women;




## All element-based powers
DROP VIEW IF EXISTS `Elemental_Powers`;
CREATE VIEW `Elemental_Powers` AS
SELECT
sp.power_name
FROM superhero s
LEFT JOIN hero_power hp ON s.id = hp.hero_id
LEFT JOIN superpower sp ON hp.power_id = sp.id
WHERE sp.id IN (5,11,56,72,75,79,90,104,117,129,140,141,155)
;

select distinct * from Elemental_Powers;

## Top 10 superheroes with fire-based superpowers (ordered by attribute levels)
SELECT 
s.id,
s.superhero_name,
sp.power_name,
SUM(ha.attribute_value) AS total_attributes
FROM superhero s
LEFT JOIN hero_attribute ha ON s.id = ha.hero_id
LEFT JOIN attribute a ON ha.attribute_id = a.id
LEFT JOIN hero_power hp ON s.id = hp.hero_id
LEFT JOIN superpower sp ON hp.power_id = sp.id
WHERE sp.id IN (56,79,90,104,140)
GROUP BY s.id, s.superhero_name, sp.power_name
ORDER BY SUM(ha.attribute_value)
DESC
LIMIT 10;

## Stored procedure that shows the different fire-themed superpowers
DROP PROCEDURE IF EXISTS Elemental_Heroes;
DELIMITER $$
CREATE PROCEDURE Elemental_Heroes(
IN HeroName VARCHAR(250),
OUT ElementalCat VARCHAR(250))
BEGIN
	DECLARE credit DECIMAL DEFAULT 0;

	SELECT 
	s.id,
	s.superhero_name,
	sp.power_name,
	SUM(ha.attribute_value) AS total_attributes
			FROM superhero s
				LEFT JOIN hero_attribute ha ON s.id = ha.hero_id
				LEFT JOIN attribute a ON ha.attribute_id = a.id
				LEFT JOIN hero_power hp ON s.id = hp.hero_id
				LEFT JOIN superpower sp ON hp.power_id = sp.id
					WHERE sp.id IN (56,79,90,104,140) AND s.superhero_name = HeroName
					GROUP BY s.id, s.superhero_name, sp.power_name
					ORDER BY SUM(ha.attribute_value)
					DESC
					LIMIT 10;

	IF s.superhero_name in ("Supergirl","Superman","Ardina") THEN
		SET ElementalCat = "Fire and/or Heat Resistance";
	ELSEIF s.superhero_name in ("Living Tribunal", "Spectre","Mister Mxyzptlk", "Vegeta") THEN
		SET ElementalCat = "Fire Control";
	ELSEIF s.superhero_name in ("Spectre", "Vegeta") THEN
		SET ElementalCat = "Heat Generation";
	ELSE
		SET ElementalCat = "No Fire-Based Power";
	END IF;
    
END$$
DELIMITER ;

CALL Elemental_Heroes("Ardina", @output);


