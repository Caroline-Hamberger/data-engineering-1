# Term project 1
**by: Caroline Hamberger**

### 1 OPERATIONAL LAYER

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
The code for the following analysis can be found here.

I approached this from the perspective of a blogger, who likes writing articles about favrious comic book figures. They therefore would be interested in creating "top 10" lists or similar, to then be able to adequately write about these characters.

For example, a list of the most intelligent DC Comics characters.

``` js
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
```

