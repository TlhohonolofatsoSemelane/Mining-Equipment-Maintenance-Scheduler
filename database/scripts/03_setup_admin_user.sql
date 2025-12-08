GRANT DBA TO mining_admin;
GRANT CONNECT, RESOURCE TO mining_admin;
GRANT CREATE SESSION TO mining_admin;
GRANT CREATE TABLE TO mining_admin;
GRANT CREATE VIEW TO mining_admin;
GRANT CREATE PROCEDURE TO mining_admin;
GRANT CREATE SEQUENCE TO mining_admin;
GRANT CREATE TRIGGER TO mining_admin;
GRANT CREATE TYPE TO mining_admin;
GRANT CREATE MATERIALIZED VIEW TO mining_admin;
GRANT SELECT ANY TABLE TO mining_admin;
GRANT INSERT ANY TABLE TO mining_admin;
GRANT UPDATE ANY TABLE TO mining_admin;
GRANT DELETE ANY TABLE TO mining_admin;
GRANT EXECUTE ANY PROCEDURE TO mining_admin;
GRANT CREATE ANY INDEX TO mining_admin;
GRANT ALTER ANY TABLE TO mining_admin;
GRANT SELECT_CATALOG_ROLE TO mining_admin;
GRANT EXECUTE_CATALOG_ROLE TO mining_admin;
GRANT CREATE JOB TO mining_admin;

ALTER USER mining_admin QUOTA UNLIMITED ON mining_data;
ALTER USER mining_admin QUOTA UNLIMITED ON mining_indexes;
ALTER USER mining_admin QUOTA UNLIMITED ON mining_lobs;

SELECT username, account_status FROM dba_users WHERE username = 'MINING_ADMIN';