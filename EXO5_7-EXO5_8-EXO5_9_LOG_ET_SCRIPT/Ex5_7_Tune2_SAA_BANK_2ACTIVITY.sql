/*

Exercice 101

Travail à faire via l'API

Ecrire un script qui permet d'analyser et produire des recommandations d'indexes 
et/ou de vues matérialisées sur des requêtes SQL stockées dans une table utilisateur. 
Vous devez pour cela :
 - Définir une tâche avec un template OLTP ou DWH ou mixte
 - Définir un workload à partir d'une table Utilisateur (voir Annexe 11.1) à créer 
   à remplir avec au moins deux requêtes
 - Attacher la tâche aux workload
 - Fixer certains paramètres de la tâche tel que 
EXECUTION_TYPE = INDEX_ONLY puis FULL
MODE = COMPREHENSIVE
- Exécuter la tâche

Visualiser les recommandations Et si possible accepter les recommandations

Les principales étapes du script sont:

1. Supprimer les indexes recommandés dans EXO91 et posés dans EXO91_TUNED
2. Charger les requêtes dans la table utilisateur user_workload
3. Analyser les requêtes et produire les recommandations
4. Consulter les recommandations

*/


set autotrace off
set termout on
set echo on
set serveroutput on


spool &SCRIPTPATH\LOG\Ex5_7_SAA_Tune2_GESTION_CABINET_HOPITAL__3SPOOL.LOG

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- 1. Supprimer les indexes recommandés dans EXO91 et posés dans EXO91_TUNED
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- liste des indexes actuels

select table_name, column_name, index_name 
from user_ind_columns
where table_name in ('O_EXAMEN','O_CONSULTATION','O_PRESCRIPTION','O_FACTURE','O_RENDEZ_VOUS','O_MEDECIN','O_PATIENT')
order by table_name, index_name, column_name;

/*
-- suppression des indexes posés dans le EXO91

declare 

sql_stmt 	varchar2(200);
cursor c1 is
	select index_name 
	from user_indexes
	where table_name in ('O_EXAMEN','O_CONSULTATION','O_PRESCRIPTION','O_FACTURE','O_RENDEZ_VOUS','O_MEDECIN','O_PATIENT')
	and 
	(UNIQUENESS = 'NONUNIQUE'
		OR 
		(UNIQUENESS='UNIQUE' 
			and index_name not in (
			select constraint_name 
			from user_constraints 
			where constraint_type 
			IN ('P', 'U') 
			)
		)
	);
begin
	for C1_elem in c1 
	loop
		sql_stmt:= 'drop index ' || c1_elem.index_name;
		EXECUTE IMMEDIATE sql_stmt;
	end loop;

end;
/
*/

-- liste des indexes après
select table_name, column_name, index_name 
from user_ind_columns
where table_name in ('O_EXAMEN','O_CONSULTATION','O_PRESCRIPTION','O_FACTURE','O_RENDEZ_VOUS','O_MEDECIN','O_PATIENT')
order by table_name, index_name, column_name;


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- 2. Charger les requêtes dans la table utilisateur user_workload
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- Si utile Suppession puis création de la table utilisateur
drop table user_workload;


create table user_workload(
MODULE VARCHAR2(64) , 	--Nom du module applicatif.
ACTION VARCHAR2(64),	-- Action sur l'application.
BUFFER_GETS NUMBER default 0, --nbre total de buffer-gets pour la requête.
CPU_TIME NUMBER default 0, -- Total CPU time in seconds for the statement.
ELAPSED_TIME NUMBER default 0, -- Total elapsed time in seconds for the statement.
DISK_READS NUMBER default 0 , --Total number of disk-read operations used 
				-- by the statement.
ROWS_PROCESSED NUMBER default 0, --  Total number of rows process by this 
				-- SQL statement.
EXECUTIONS NUMBER default 1, -- Total number of times the statement is executed.
OPTIMIZER_COST NUMBER default  0, -- Optimizer's calculated cost value for 
				          -- executing the query.
LAST_EXECUTION_DATE DATE  default SYSDATE , -- Last time the query is 
				-- used. Defaults to not available.
PRIORITY NUMBER default 2, 	--  Must be one of the following values:
				-- 1- HIGH, 2- MEDIUM, or 3- LOW
SQL_TEXT CLOB,		--  or LONG or VARCHAR2
				-- None The SQL statement. This is a required 			-- column.
STAT_PERIOD NUMBER default 1 ,
-- Period of time that corresponds to the execution statistics in seconds.
USERNAME VARCHAR(30) default user
--Current user User submitting the query. This is a required column.
);



-- chargement des requêtes dans cette table
-- aggregation with selection

INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example1', 'Action', 2,
' SELECT * FROM O_PATIENT OP')
/
 

 INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example2', 'Action', 2,
 'SELECT * FROM O_CONSULTATION OC');
 
 

INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example3', 'Action', 2,
 'SELECT E.details_examens, COUNT(*) AS NB_LIGNES
FROM (SELECT DISTINCT oe.Details_Examen AS details_examens FROM O_EXAMEN oe) E 
GROUP BY E.details_examens');
 
 
 -- liste des transactions par compte et client pour lesquels le solde du compte négatif
 INSERT INTO user_workload (username, module, action, priority, sql_text)
 VALUES ('&MYPDBUSER', 'Example3', 'Action', 2,'SELECT E.details_examens, COUNT(*) AS NB_LIGNES
FROM (SELECT DISTINCT oe.Details_Examen AS details_examens FROM O_EXAMEN oe) E 
GROUP BY E.details_examens 
ORDER BY E.details_examens ASC');

-- liste des transactions par compte et client connaissant le nom du client
 INSERT INTO user_workload (username, module, action, priority, sql_text)
 VALUES ('&MYPDBUSER', 'Example5', 'Action', 2,
 'SELECT COUNT(*) nb_total_factures, SUM(OFA.Montant_Total) somme_montants_totaux
FROM O_FACTURE OFA 
GROUP BY OFA.refPatient.ID_PERSONNE
ORDER BY OFA.refPatient.ID_PERSONNE');
 
 -- liste des transactions par compte et client connaissant le nom du client et opérées à une date donnée
 INSERT INTO user_workload (username, module, action, priority, sql_text)
 VALUES ('&MYPDBUSER', 'Example6', 'Action', 2,
 'SELECT OC.*, DEREF(OC.refPatient) AS PATIENT FROM O_CONSULTATION OC');

 -- 7ème requête
 -- liste des opération d'un client données de type DEBIT
INSERT INTO user_workload (username, module, action, priority, sql_text)
 VALUES ('&MYPDBUSER', 'Example7', 'Action', 2,
 'SELECT OFA.*, DEREF(OFA.refPatient) AS PATIENT FROM O_FACTURE OFA');
 
 -- Erreur 1 : total des transaction par client, par compte, par operation
INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example8', 'Action', 2,
 'SELECT OC.*, DEREF(OC.refPatient) AS PATIENT 
FROM O_CONSULTATION OC 
ORDER BY OC.Date_Consultation ASC');

 -- Erreur 2 : total des transaction par client, par compte, par operation 
 -- dont le total est supérieur à 10000
 INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example9', 'Action', 2,
 'SELECT OFA.refPatient.ID_PERSONNE AS ID_PATIENT, OFA.refPatient.EMAIL AS EMAIL, SUM(OFA.Montant_Total) AS MONTANT_TOTAL
FROM O_FACTURE OFA 
GROUP BY OFA.refPatient.ID_PERSONNE, OFA.refPatient.EMAIL
ORDER BY OFA.refPatient.ID_PERSONNE, OFA.refPatient.EMAIL DESC');

 
-- 10ème balance des transactions par type et par date
INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example10', 'Action', 2,
 'SELECT 
OE.*, 
DEREF(OE.refConsultation) AS CONSULTATION, 
DEREF(DEREF(OE.refConsultation).refPatient) AS PATIENT
FROM O_EXAMEN OE');

-- balance des transactions par type
INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example11', 'Action', 2,
 'SELECT 
OFA.*, 
OFA.refPatient AS PATIENT, 
OFA.refConsultation AS CONSULTATION 
FROM O_FACTURE OFA');
 
 -- balance des transactions par type pour des compte épargne entre deux dates
  INSERT INTO user_workload (username, module, action, priority, sql_text)
VALUES ('&MYPDBUSER', 'Example12', 'Action', 2,
 'SELECT 
OE.*, 
DEREF(OE.refConsultation) AS CONSULTATION, 
DEREF(DEREF(OE.refConsultation).refPatient) AS PATIENT
FROM O_EXAMEN OE 
ORDER BY OE.refConsultation.Date_Consultation ASC') ;


 INSERT INTO user_workload (username, module, action, priority, sql_text)
 VALUES ('&MYPDBUSER', 'Example13', 'Action', 2,
 'SELECT 
OFA.refPatient.ID_PERSONNE AS ID_PATIENT,
OFA.refPatient.Email AS EMAIL,
OFA.Date_Facture AS Date_Facture,
OFA.refConsultation.Date_Consultation AS Date_Consultation,
SUM(OFA.MONTANT_TOTAL) AS SOMME_MONTANTS
FROM O_FACTURE OFA
GROUP BY 
OFA.refPatient.ID_PERSONNE,
OFA.refPatient.Email,
OFA.Date_Facture,
OFA.refConsultation.Date_Consultation
ORDER BY 
OFA.refPatient.ID_PERSONNE,
OFA.refPatient.Email,
OFA.Date_Facture,
OFA.refConsultation.Date_Consultation');
 
 INSERT INTO user_workload (username, module, action, priority, sql_text)
 VALUES ('&MYPDBUSER', 'Example14', 'Action', 2,
 'select E.ID_EXAMEN, E.REFCONSULTATION.DIAGNOSTIC, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.REFCONSULTATION.ID_CONSULTATION =1') ;


commit;


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- 3. Analyser les requêtes et produire les recommandations
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------


-- programmation de tache Sql access advisor
set serveroutput on

-- fixer les spérateurs de nombre en Anglais. "," pour les décimaux et "." pour les groupes

-- Anglais
alter session set NLS_NUMERIC_CHARACTERS = '.,' ; 

-- Francais
-- alter session set NLS_NUMERIC_CHARACTERS = ',.'  ; 
declare
saved_stmts NUMBER;
failed_stmts NUMBER;
wkld_name VARCHAR2(30) :='WKLD_GESTION_CABINET_MEDICAL';
taskname VARCHAR2(30) := 'TASK_GESTION_CABINET_MEDICAL'; 
task_id NUMBER;
num_found NUMBER:=0;
Begin
-- détacher la tache et le workload
select count(*) into num_found 
from user_advisor_sqla_wk_map 
where task_name = taskname and workload_name = wkld_name;
IF num_found > 0 THEN
DBMS_ADVISOR.RESET_TASK (taskname);
DBMS_ADVISOR.DELETE_SQLWKLD_REF(taskname, wkld_name);
END IF;

-- suppression puis création de la t
select count(*) into num_found 
from dba_advisor_tasks 
where owner='&MYPDBUSER' and task_name=taskname;

IF num_found > 0 THEN
DBMS_ADVISOR.DELETE_TASK (taskname);
END IF;
DBMS_ADVISOR.CREATE_TASK ('SQL Access Advisor', task_id, taskname);

-- suppression et puis création du workload
select count(*) into num_found 
from user_advisor_sqlw_sum 
where workload_name = wkld_name;
IF num_found > 0 THEN
DBMS_ADVISOR.DELETE_SQLWKLD(workload_name=> wkld_name);
END IF;
DBMS_ADVISOR.CREATE_SQLWKLD (wkld_name);

-- chargement du workload
DBMS_ADVISOR.IMPORT_SQLWKLD_USER( 
workload_name=> wkld_name,import_mode=>'NEW', owner_name=>'&MYPDBUSER', 
table_name=>'USER_WORKLOAD', Saved_rows=>saved_stmts, 
Failed_rows=>failed_stmts);
dbms_output.put_line(' saved_stmts='||saved_stmts);
dbms_output.put_line(' failed_stmts='||failed_stmts);
-- Attacher le workload à une tâche
/* Link Workload to Task */
dbms_advisor.add_sqlwkld_ref(taskname,wkld_name);

--Mise à jour de paramètres de la tâche
dbms_advisor.set_task_parameter(taskname,'EXECUTION_TYPE','INDEX_ONLY');--'FULL');--'INDEX_ONLY');
dbms_advisor.set_task_parameter(taskname,'MODE','COMPREHENSIVE');

-- exécuter la tâche
DBMS_ADVISOR.EXECUTE_TASK(taskname);
Exception 
When others then
dbms_output.put_line(' SQLcode='||sqlcode);
dbms_output.put_line(' SQLerrm='||sqlerrm);
End;
/
/*
*
ERREUR à la ligne 1 :
ORA-13600: erreur survenue dans Advisor
ORA-13635: La valeur indiquée pour le paramètre ADJUSTED_SCALEUP_GREEN_THRESH
ne peut pas être convertie en nombre.
ORA-06512: à "SYS.PRVT_ADVISOR", ligne 3902
ORA-06512: à "SYS.DBMS_ADVISOR", ligne 102
ORA-06512: à ligne 26
*/

-- ALTER SYSTEM SET NLS_TERRITORY=FRANCE scope=spfile;

-- si cette apparait faire les 	actions suivantes 
-- Ne pas lancer les deux programmes qui suivent 
-- si pas d'erreur

/*
-- ne pas exécuter ce script si pas d'erreur plus haut
declare
template_id NUMBER;
template_name VARCHAR2(255):= 'MY_TEMPLATE';
Begin
DBMS_ADVISOR.SET_DEFAULT_TASK_PARAMETER (
'SQL Access Advisor', 
'ADJUSTED_SCALEUP_GREEN_THRESH'  ,
'1,25' -- au lieu de 1.25
);
end;
/

-- ne pas exécuter ce script si pas d'erreur plus haut
declare
template_id NUMBER;
template_name VARCHAR2(255):= 'MY_TEMPLATE';
Begin
DBMS_ADVISOR.SET_DEFAULT_TASK_PARAMETER (
'SQL Access Advisor', 
'OVERALL_SCALEUP_GREEN_THRESH'  ,
'1,5' -- au lieu de 1.5
);
end;
/

*/

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- 4. Consulter les recommandations
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- Consulter les requêtes de référence que va régler SAA
col WORKLOAD_NAME format a20
col SQL_TEXT format a70
set linesize 200
set pagesize 400
select WORKLOAD_NAME, sql_id, SQL_TEXT from DBA_ADVISOR_SQLW_STMTS
Where workload_name= 'WKLD_GESTION_CABINET_MEDICAL'
order by sql_id;


-- Visualisation des recommandations
-- Affiche du nr de recommandation, le rang et le bénéfice de 
-- la recommandation

SELECT REC_ID, RANK, BENEFIT, type
FROM USER_ADVISOR_RECOMMENDATIONS WHERE TASK_NAME = 'TASK_GESTION_CABINET_MEDICAL';

-- Visualisation des recommandations
-- Afficher des recommandations et des bénéfices 
-- par requêtes

SELECT sql_id, rec_id, precost, postcost,
(precost-postcost)*100/precost AS percent_benefit
FROM USER_ADVISOR_SQLA_WK_STMTS
WHERE TASK_NAME = 'TASK_GESTION_CABINET_MEDICAL'
AND workload_name = 'WKLD_GESTION_CABINET_MEDICAL';

-- Visualisation des recommandations
-- Affichage des actions recommandés :
-- Comptage des actions recommandées


SELECT 'Action Count', COUNT(DISTINCT action_id) cnt
FROM user_advisor_actions 
WHERE task_name = 'TASK_GESTION_CABINET_MEDICAL';



-- Visualisation des recommandations
-- Affichage des actions recommandés :
-- Liste des actions recommandées


Col command format A30
Col attr1 format A40
Set long 500
SELECT rec_id, action_id, command, attr1
FROM user_advisor_actions 
WHERE task_name = 'TASK_GESTION_CABINET_MEDICAL'
ORDER BY rec_id, action_id;


-- Visualisation des recommandations
-- Génération des scripts SQL
-- Afin d'implémenter les recommandations il est possible de 
-- générer des scripts

-- La fonction GET_TASK_SCRIPT construire le script
set serveroutput on
begin
dbms_output.put_line(DBMS_ADVISOR.GET_TASK_SCRIPT('TASK_GESTION_CABINET_MEDICAL'));
end;
/

-- La fonction CREATE_FILE permet de créer le fichier 
-- contenant le script
declare 
mydate varchar2(20):=to_char(sysdate, 'DD_MM_YYYY_HH24_MI_SS');
fname varchar2(300):='SAA_Generate_script_on_gestion_cabinet_medical_app_'||mydate||'.sql';
begin
dbms_output.put_line(fname);
DBMS_ADVISOR.CREATE_FILE(
buffer=>DBMS_ADVISOR.GET_TASK_SCRIPT('TASK_GESTION_CABINET_MEDICAL'),
location =>'DATA_PUMP_DIR', 
 filename=>fname
);
end;
/

spool off

