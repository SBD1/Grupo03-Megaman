DROP DATABASE megaman;

CREATE DATABASE megaman;

\c megaman

BEGIN;

\i SQL/TableCreation.sql
\i SP_e_Triggers/triggers.sql
\i SP_e_Triggers/procedures.sql
\i SQL/TuplasCreation.sql

COMMIT;