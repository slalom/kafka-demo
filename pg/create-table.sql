-- Table Definition ----------------------------------------------

CREATE TABLE people (
    id integer DEFAULT nextval('untitled_table_id_seq'::regclass) PRIMARY KEY,
    first text,
    last text,
    datetime text DEFAULT now()
);

-- Indices -------------------------------------------------------

CREATE UNIQUE INDEX people_pkey ON people(id int4_ops);