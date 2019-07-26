-- Table Definition ----------------------------------------------

CREATE TABLE people (
    id serial PRIMARY KEY,
    first text,
    last text,
    datetime text DEFAULT now()
);


-- Indices -------------------------------------------------------

CREATE UNIQUE INDEX people_pkey ON people(id);