-- CONNTECT WTIH THE SYSTEM USER TO EXECUT THIS SCRIPT.

CREATE USER HOPITAL IDENTIFIED BY PASS123;

ALTER USER HOPITAL QUOTA UNLIMITED  ON USERS;

GRANT CREATE SESSION TO HOPITAL;

GRANT CREATE TABLE TO HOPITAL WITH ADMIN OPTION;

GRANT CREATE  VIEW TO HOPITAL WITH ADMIN OPTION;;

GRANT CREATE PROCEDURE TO HOPITAL WITH ADMIN OPTION;

GRANT CREATE TYPE TO HOTITAL WITH ADMIN OPTION;

