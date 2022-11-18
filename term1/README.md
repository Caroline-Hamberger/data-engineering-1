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
