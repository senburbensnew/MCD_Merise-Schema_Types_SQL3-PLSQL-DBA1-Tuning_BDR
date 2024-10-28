--Rem  SQL Access Advisor : Version 12.2.0.1.0 - Production
--Rem  
--Rem  Nom utilisateur :    ORS2
--Rem  T�che :             TASK_GESTION_CABINET_HOPITAL
--Rem  Date d'ex�cution :   

-- 3 Impl�mentation des recommandations
-- Copier le contenu du fichier g�n�r�
-- nomm� : SAA_Generate_script_on_GESTION_CABINET_HOPITAL_app_'||mydate||'.sql 
-- dans le dossier : -- %ORACLE_BASE%\admin\dpdump\nomBase\nomPdb
-- dans ce fichier :
-- Ex101_Tune2_SAA_BANK_3Recommandations.sql
-- Ce fichier se trouve dans le dossier :&SCRIPTPATH\EXO101
-- Nettoyer les doublons puis ex�cutez ce script pour impl�menter 
-- les recommandations

/*
< Mettre les actions ci-apr�s ce commentaire>
*/

/* RETAIN INDEX "HOPITAL"."PK_CONSULTATION" */

/* RETAIN INDEX "HOPITAL"."PK_PATIENT" */

/* RETAIN INDEX "HOPITAL"."PK_FACTURE" */

CREATE INDEX "HOPITAL"."EXAMEN_IDX$$_00130000"
    ON "HOPITAL"."EXAMEN"
    ("DETAILS_EXAMEN")
    COMPUTE STATISTICS;

