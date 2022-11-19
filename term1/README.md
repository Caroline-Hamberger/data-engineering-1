# Term project 1
**by: Caroline Hamberger**

### 1 Operational Layer

**Goals:**
- Create an operational data layer in MySQL. 
- Import a relational data set of your choosing into your local instance. 
- Find a data which makes sense to be transformed in analytical data layer for further analytics.

The data I imported was originally sourced [here](https://github.com/bbrumm/databasestar/tree/main/sample_databases/sample_db_superheroes/mysql).

A note, in case you are a fan of comic books: While the schema is named "superheroes", the data itself includes a number of villains, and anti-heroes and would therefore be better suited referred to as "comic book characters". Since this happens to be a terribly inconvenient naming convention, I am sticking with the "superheroes" label.

The script for importing the data is [hamberger_data.sql](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_data.sql)

### 2 Analytics

**Goals:**
- Create a short plan of what kind of analytics can be potentially executed on this data set. 
- Plan how the analytical data layer, ETL, Data Mart would look like to support these analytics.

I firstly created a model to get a good overview of the tables included in the schema.
The .mwb model can be found [here](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_model.mwb).

Here is what the model looks like:

![hamberger_model](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_model.png)

**Analysis:**
The code for the following analysis can be found [here](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_analytics.sql).

I approached this from the perspective of a blogger, who likes writing articles about favrious comic book figures. They therefore would be interested in creating "top 10" lists or similar, to then be able to adequately write about these characters.

For example, a list of the most intelligent DC Comics characters. To garner "intelligence", one can use the "attribute" table, where several important attributes for heros are listed (e.g. Intelligence, Strength, etc.). "attribute.id = 1" specifies that this view should only take into account Intelligence scores.

``` sql
USE superhero;

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
```

That same blogger might also want to get an overview of all the superpowers that these characters have that pertain to the four elements (water, fire, earth, and wind). They can do this using the superpower table.

``` sql
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
```


There are a few more examples in the actual code file, including a stored procedure. Earlier in the code, I created a list of the top 10 superheroes (by total attribute scores) who have fire-based powers. The following procedure allows our blogger to type in any of the ten superheroes and find out which fire-based superpower they control.

```sql
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

## Example output requests
CALL Elemental_Heroes("Ardina", @output);

CALL Elemental_Heroes("Vegeta", @output);
```

### 3 Analytical Layer

**Goals:**
- Design a denormalized data structure using the operational layer
- Create table in MySQL for this structure

The code for the analytical layer can be found [here](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_analytical_layer.sql).
My focus was on creating a denormalized data layer that allowed for the stored procedure to be run. It includes all necessary data without the excess.

``` sql
# Creating a denormalized data layer focusing on the names and powers of superheroes
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
	   ha.hero_id AS HeroID,
	   ha.attribute_value AS TotalAttributes
	FROM
		superhero s
	INNER JOIN hero_attribute ha ON s.id = ha.hero_id
	INNER JOIN hero_power hp ON s.id = hp.hero_id
	INNER JOIN superpower sp ON hp.power_id = sp.id
		GROUP BY s.id, s.superhero_name, sp.power_name, ha.attribute_value
		ORDER BY SUM(ha.attribute_value)
		DESC;

END //
DELIMITER ;

SELECT * FROM hero_powers;
```

### 4 ETL Pipeline

**Goals:**
- Create an ETL pipeline using Triggers, Stored procedures. 
- Make sure to demonstrate every element of ETL (Extract, Transform, Load)

The code for the ETL pipline can be found [here](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_etl.sql).

- Extracting: I extracted by joining the tables in the first part of code.
- Transforming: The transformation is a simple change of superhero_name to uppercase.
- Loading: Inserting into the hero_powers table


## 5 Data Mart

**Goals:**
- Create Views as data marts.

I've created all of my [analytical work](https://github.com/Caroline-Hamberger/data-engineering-1/blob/main/term1/hamberger_analytics.sql) as view. Here is some of that code again.

``` sql
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
```
