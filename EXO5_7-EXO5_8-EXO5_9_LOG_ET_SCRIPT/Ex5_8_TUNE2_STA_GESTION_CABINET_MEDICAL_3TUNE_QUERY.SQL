/*

LIRE ATTENTIVEMENT LE CHAPITRE 2 à 10 DU COURS TUNE 2 
CONCERNANT LE REGLAGE AUTOMATIQUE DE REQUETES ET SURTOUT
SQL TUNING ADVISOR (voir aussi les annexes).

Ecrire un script qui permet d'analyser et produire des 
recommandations sur un pool de requêtes sur l'application
APPLIBANK regroupé dans un  SQL Tuning Set. Le remplissage
du SQL TUNING SET set fait en récupérant les requêtes entre
deux clichés AWR.

Travail à faire via l'API et en partie via OEM.

1. Charger l'application bancaire (AppliBank.sql)
dans le schéma de l'utilisateur ORS2

2. Provoquer de l'activité (requêtes sur l'application bancaire) 
dans la base entre deux clichés AWR

3. Générer les recommandations

Ecrire un script qui permet d'analyser et produire des 
recommandations récupérées les requêtes entre
deux clichés AWR.


4. Afficher les résultats d'analyses

5. Gérer le script SQL proposé pour le réglage SQL

6. Activiter de réglage à faire à l'issue de l'exécution de ce script


*/



set autotrace off
set termout on
set echo on
set serveroutput on


-- Activation du spool pour logger toutes vos actions
-- dans ce script. Adapter le chemin en fonction de votre
-- contexte.
spool &SCRIPTPATH\LOG\Ex5_8_TUNE2_STA_GESTION_CABINET_MEDICAL_3TUNE_QUERY.log 

-- 1. Charger l'application bancaire (AppliBank.sql)
-- dans le schéma de l'utilisateur ORS2

-- Déjà fait dans ...start.sql

-- Les index actuels sur l'application
-- Pour l'instant seul les 3 indexes primary doivent exister
select table_name, column_name, index_name 
from user_ind_columns
where table_name in ('O_EXAMEN','O_CONSULTATION','O_PRESCRIPTION','O_FACTURE','O_RENDEZ_VOUS','O_MEDECIN','O_PATIENT')
order by table_name, index_name, column_name;

 /*

TABLE_NAME                     COLUMN_NAME                              INDEX_NAME                                                                      
------------------------------ ---------------------------------------- --------------------------------------------------------------------------------
O_CONSULTATION                 REFMEDECIN                               IDX_O_CONSULTATION_REFMEDECIN                                                   
O_CONSULTATION                 REFPATIENT                               IDX_O_CONSULTATION_REFPATIENT                                                   
O_CONSULTATION                 DATE_CONSULTATION                        IDX_O_CONSULTATION_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                          
O_CONSULTATION                 REFMEDECIN                               IDX_O_CONSULTATION_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                          
O_CONSULTATION                 REFPATIENT                               IDX_O_CONSULTATION_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                          
O_CONSULTATION                 ID_CONSULTATION                          PK_O_CONSULTATION_ID_CONSULTATION                                               
O_CONSULTATION                 PLISTREFPRESCRIPTIONS                    SYS_C008613                                                                     
O_CONSULTATION                 PLISTREFEXAMENS                          SYS_C008614                                                                     
O_CONSULTATION                 SYS_NC_OID$                              SYS_C008615                                                                     
O_EXAMEN                       REFCONSULTATION                          IDX_O_EXAMEN_REFCONSULTATION                                                    
O_EXAMEN                       ID_EXAMEN                                PK_O_EXAMEN_ID_EXAMEN                                                           
O_EXAMEN                       SYS_NC_OID$                              SYS_C008590                                                                     
O_FACTURE                      MONTANT_TOTAL                            IDX_O_FACTURE_MONTANT_TOTAL                                                     
O_FACTURE                      REFCONSULTATION                          IDX_O_FACTURE_REFCONSULTATION                                                   
O_FACTURE                      REFPATIENT                               IDX_O_FACTURE_REFPATIENT                                                        
O_FACTURE                      ID_FACTURE                               PK_O_FACTURE_ID_FACTURE                                                         
O_FACTURE                      SYS_NC_OID$                              SYS_C008601                                                                     
O_MEDECIN                      EMAIL                                    IDX_O_MEDECIN_EMAIL_UNIQUE                                                      
O_MEDECIN                      NUMERO_SECURITE_SOCIALE                  IDX_O_MEDECIN_NUM_SEC_SOCIAL_UNIQUE                                             
O_MEDECIN                      SPECIALITE                               IDX_O_MEDECIN_SPECIALITE                                                        
O_MEDECIN                      ID_PERSONNE                              PK_O_MEDECIN_ID_PERSONNE                                                        
O_MEDECIN                      PLISTREFCONSULTATIONS                    SYS_C008583                                                                     
O_MEDECIN                      PLISTREFRENDEZVOUS                       SYS_C008584                                                                     
O_MEDECIN                      SYS_NC_OID$                              SYS_C008585                                                                     
O_PATIENT                      EMAIL                                    IDX_O_PATIENT_EMAIL_UNIQUE                                                      
O_PATIENT                      NUMERO_SECURITE_SOCIALE                  IDX_O_PATIENT_NUM_SEC_SOCIAL_UNIQUE                                             
O_PATIENT                      ID_PERSONNE                              PK_O_PATIENT_ID_PERSONNE                                                        
O_PATIENT                      PLISTREFFACTURES                         SYS_C008570                                                                     
O_PATIENT                      PLISTREFCONSULTATIONS                    SYS_C008571                                                                     
O_PATIENT                      PLISTREFRENDEZVOUS                       SYS_C008572                                                                     
O_PATIENT                      SYS_NC_OID$                              SYS_C008573                                                                     
O_PRESCRIPTION                 REFCONSULTATION                          IDX_O_PRESCRIPTION_REFCONSULTATION                                              
O_PRESCRIPTION                 ID_PRESCRIPTION                          PK_O_PRESCRIPTION_ID_PRESCRIPTION                                               
O_PRESCRIPTION                 SYS_NC_OID$                              SYS_C008595                                                                     
O_RENDEZ_VOUS                  REFMEDECIN                               IDX_O_RENDEZ_VOUS_REFMEDECIN                                                    
O_RENDEZ_VOUS                  REFPATIENT                               IDX_O_RENDEZ_VOUS_REFPATIENT                                                    
O_RENDEZ_VOUS                  DATE_RENDEZ_VOUS                         IDX_O_RENDEZ_VOUS_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                           
O_RENDEZ_VOUS                  REFMEDECIN                               IDX_O_RENDEZ_VOUS_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                           
O_RENDEZ_VOUS                  REFPATIENT                               IDX_O_RENDEZ_VOUS_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                           
O_RENDEZ_VOUS                  ID_RENDEZ_VOUS                           PK_O_RENDEZ_VOUS_ID_RENDEZ_VOUS                                                 
O_RENDEZ_VOUS                  SYS_NC_OID$                              SYS_C008607                                                                     

*/

-- Ne pas créer les indexes ci-dessous.
-- Ce sont les indexes qu'on aurait créés si on opérait
-- un réglage manuel. Lorsque SQLTUNING ADVISOR aura fait
-- des recommandations, comparez les indexes qu'ils recommandent
-- avec ceux ci. Ces indexes sont proposées au vu des clauses
-- WHERE des requêtes à optmiser automatiquement. 


  
-- vérification du type d'optimiseur
 show parameter optimizer_mode;

-- optimizer_mode                       string      ALL_ROWS
 
-- passer en mode all_rows si utile
set autotrace off
alter session set optimizer_mode=all_rows ;

-- calculer les statistiques sur les objets de l'utilisateur
-- &MYPDBUSER
execute dbms_stats.gather_schema_stats('&MYPDBUSER');

-- Connexion avec au niveau CDB pour prendre un cliché AWR.
-- La gestion des statistiques se fait au niveau e ma CDB
connect &MYCDBUSER@&DBALIASCDB/&MYCDBUSERPASS

-- Prendre un premier cliché AWR pour délimiter
-- l'espace de récupération des requêtes.
set serveroutput on
variable snapid1 number;

begin
	:snapid1	:= dbms_workload_repository.create_snapshot;
	dbms_output.put_line('snap_id1='||:snapid1);
end;
/

-- ReConnexion à la  PDB pour utiliser STA
connect &MYPDBUSER@&DBALIASPDB/&MYPDBUSERPASS
set arraysize 5000
-- reporter le numéro de cliché rendu par le programme ici :
-- snap_id1=153  ? snap_id1=743

-- 2. Provoquer de l'activité (requêtes sur l'application bancaire) 
-- dans la base entre deux clichés AWR

-- Désactiver l'affichage à l'écran des résultats des requêtes.
 set autotrace &TRACEOPTION


 col compteid format a24
 col nom format a20
 col prenom format a20
 col ville format a20
 col adresse format a30

 
 -- Lancer plusieurs requêtes
 -- Cette requete retourne toutes les colonnes des consultations, jointes avec les informations des patients correspondants 
-- ou les ID PATIENT sont egaux dans les deux
-- tables. Cela permet d’obtenir des donnees combinees sur les consultations et les
-- patients dans une seule table resultante.
SELECT OC.*, DEREF(OC.refPatient) AS PATIENT FROM O_CONSULTATION OC;

-- Cette requete retourne toutes les colonnes des factures, jointes avec les informations
-- des patients correspondants o`u les ID PATIENT sont ´egaux dans les deux tables.
-- Cela permet d’obtenir des donn´ees combin´ees sur les factures et les patients dans
-- une seule table resultante.
SELECT OFA.*, DEREF(OFA.refPatient) AS PATIENT FROM O_FACTURE OFA;

-- Cette requete renvoie toutes les colonnes des consultations, jointes avec les informations des patients correspondants, 
-- et les ordonne par date de consultation croissante.
-- Cela permet d’obtenir une liste de consultations associ´ees `a leurs patients, tri´ees par
-- date de consultation.
SELECT OC.*, DEREF(OC.refPatient) AS PATIENT 
FROM O_CONSULTATION OC 
ORDER BY OC.Date_Consultation ASC;

-- Cette requete retourne l’identifiant du patient, son adresse e-mail, et la somme des
-- montants totaux de ses factures, regroup´es par identifiant de patient et e-mail, et
-- tries par identifiant de patient puis par e-mail. Cela permet d’obtenir une vue agr´eg´ee
-- des montants totaux de factures pour chaque patient avec leurs adresses email correspondantes.
SELECT OFA.refPatient.ID_PERSONNE AS ID_PATIENT, OFA.refPatient.EMAIL AS EMAIL, SUM(OFA.Montant_Total) AS MONTANT_TOTAL
FROM O_FACTURE OFA 
GROUP BY OFA.refPatient.ID_PERSONNE, OFA.refPatient.EMAIL
ORDER BY OFA.refPatient.ID_PERSONNE, OFA.refPatient.EMAIL DESC;


-- Cette requete retourne toutes les colonnes des consultations, des patients et des
-- examens associes, ou chaque consultation est liee a son patient correspondant via
-- la jointure avec la table "PATIENT", et chaque consultation est liee a ses examens
-- correspondants via la jointure avec la table "EXAMEN".
SELECT 
OE.*, 
DEREF(OE.refConsultation) AS CONSULTATION, 
DEREF(DEREF(OE.refConsultation).refPatient) AS PATIENT
FROM O_EXAMEN OE;

-- Cette requete retourne toutes les colonnes des factures, des patients et des consultations associ´ees, o`u chaque facture est li´ee `a son patient correspondant via la jointure
-- avec la table ”PATIENT”, et chaque facture est li´ee `a sa consultation correspondante
-- via la jointure avec la table ”CONSULTATION”.
SELECT 
OFA.*, 
OFA.refPatient AS PATIENT, 
OFA.refConsultation AS CONSULTATION 
FROM O_FACTURE OFA;

-- Cette requete renvoie toutes les colonnes des consultations, des patients et des examens associes, 
-- ou chaque consultation est liee a son patient correspondant via la
-- jointure avec la table ”PATIENT”, et chaque consultation est liee a ses examens
-- correspondants via la jointure avec la table ”EXAMEN”. Les resultats sont ensuite
-- tri´es par date de consultation croissante.
SELECT 
OE.*, 
DEREF(OE.refConsultation) AS CONSULTATION, 
DEREF(DEREF(OE.refConsultation).refPatient) AS PATIENT
FROM O_EXAMEN OE 
ORDER BY OE.refConsultation.Date_Consultation ASC;

-- Cette requete retourne l’identifiant du patient, son adresse e-mail, la somme des
-- montants totaux de ses factures, ainsi que les dates de la facture et de la consultation
-- correspondantes, regroup´es par identifiant de patient, adresse e-mail, date de facture
-- et date de consultation, et tri´es dans cet ordre. Cela permet d’obtenir une vue agr´eg´ee
-- des montants totaux de factures pour chaque patient, avec les d´etails des factures
-- et des consultations.
SELECT 
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
OFA.refConsultation.Date_Consultation;



 set autotrace off

-- Connexion avec lau niveau CDB pour prendre un cliché AWR
-- La gestion des statistiques se fait au niveau e ma CDB
connect &MYCDBUSER@&DBALIASCDB/&MYCDBUSERPASS


-- Prendre un deuxième cliché AWR pour délimiter
-- la fin de l'espace de récupération des requêtes.
variable snapid2 number;
set serveroutput on

begin
	:snapid2	:= dbms_workload_repository.create_snapshot;
	dbms_output.put_line('snap_id2='||:snapid2);
end;
/

-- ReConnexion à la  PDB pour utiliser STA
connect &MYPDBUSER@&DBALIASPDB/&MYPDBUSERPASS
set arraysize 5000
-- reporter le numéro de cliché rendu par le programme ici :
-- snap_id2= 154 ? snap_id2=744

-- Supprimer la tache  
-- Supprimer 1 tache GESTION_CABINET_MEDICAL_SQL_TUNING_TASK si elle existe déjà
execute DBMS_SQLTUNE.DROP_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER');
execute DBMS_SQLTUNE.DROP_SQLSET('GESTION_CABINET_MEDICAL_sql_tuning_set'||'&MYPDBUSER');
-- Si vous avez déjà exécuté ce script, il se peut qu'un
-- qu'un profile de requête ai déjà été créé. Dans ce cas:
-- Rechercher puis supprimer le profie s'il existe déjà 
---
set linesize 200
col sql_text format A40
select name 
from dba_sql_profiles
order by name;

-- Supprimer le(s) profile(s) s'ils ont été trouvés avec la requête 
-- précédente. NomProfile est le résultat de la requête
-- ci-dessus. Répéter l'action si utile.
execute DBMS_SQLTUNE.DROP_SQL_PROFILE('NomProfile');

-- 3. Générer les recommandations
-- Exécuter le script ci-dessous pour optimiser automatiquement
-- les requêtes lancées entre snap_id1 et snap_id2.
-- Le conseiller qui sera utilisé ici est SQL TUNNING ADVISOR.
set serveroutput on
DECLARE
my_task_name VARCHAR2(200);
nom_sqlset varchar2(200):='GESTION_CABINET_MEDICAL_sql_tuning_set'||'&MYPDBUSER';
l_cursor  DBMS_SQLTUNE.sqlset_cursor;
BEGIN
DBMS_SQLTUNE.CREATE_SQLSET(
sqlset_name => nom_sqlset,
description => 'I/O intensive workload');

-- Appel de la fonction DBMS_SQLTUNE.select_workload_repository 
-- pour recolter les requêtes à régler automatiquement entre
-- snap_id1 et snap_id2.
-- remplacer snap_id1 et snap_id2 par les valeurs capturées 
-- plus haut après les appels de:dbms_workload_repository.create_snapshot;.
--1059 et 1174
  OPEN l_cursor FOR
    SELECT VALUE(p)
    FROM   TABLE (DBMS_SQLTUNE.select_workload_repository (
                    :snapid1, --snap_id1,  -- begin_snap : 
                    :snapid2, --snap_id2,  -- end_snap
                    'parsing_schema_name =''&MYPDBUSER''  and parsing_schema_name <> ''SYS''', -- basic_filter
                    NULL, -- object_filter
                    NULL, -- ranking_measure1
                    NULL, -- ranking_measure2
                    NULL, -- ranking_measure3
                    NULL, -- result_percentage
					NULL, -- result_limit
					'ALL' -- attribute_list
					)
                --    10)   -- result_limit
                  ) p;

-- charger les requêtes recoltées entre snap_id1 et snap_id2
-- actuellement présente dans l_cursor dans le sql tuning 
-- set créé précédemment.
  DBMS_SQLTUNE.load_sqlset (
    sqlset_name     => nom_sqlset,
    populate_cursor => l_cursor);

-- créer une tâche de tuning pour le sql tuning set
-- alimenté en requête dans l'action ci-dessus.	
my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(
sqlset_name => nom_sqlset,
basic_filter => 'parsing_schema_name =''&MYPDBUSER''', -- basic_filter
scope => 'COMPREHENSIVE',
time_limit => 60,
task_name => 'GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER',
description => 'Task to tune a query on a specified bank queries'
);

-- Exécuter le tâche de tuning 
-- le conseiller utilisé ici est STA.
DBMS_SQLTUNE.EXECUTE_TUNING_TASK( task_name => my_task_name );

END;
/

-- profile des fonctions utilisées dans le programme ci-dessus.
-- A ne pas exécuter. Voir le manuel Oracle Oracle® Database
-- PL/SQL Packages and Types Reference pour la description
-- détaillée.
/*
DBMS_SQLTUNE.SELECT_WORKLAOD_REPOSITORY (
begin_snap IN NUMBER,
end_snap IN NUMBER,
basic_filter IN VARCHAR2 := NULL,
object_filter IN VARCHAR2 := NULL,
ranking_measure1 IN VARCHAR2 := NULL,
ranking_measure2 IN VARCHAR2 := NULL,
ranking_measure3 IN VARCHAR2 := NULL,
result_percentage IN NUMBER := 1,
result_limit IN NUMBER := NULL
attribute_list IN VARCHAR2 := NULL)
RETURN sys.sqlset PIPELINED;


DBMS_SQLTUNE.CREATE_TUNING_TASK(
sqlset_name IN VARCHAR2,
basic_filter IN VARCHAR2 := NULL,
object_filter IN VARCHAR2 := NULL,
rank1 IN VARCHAR2 := NULL,
rank2 IN VARCHAR2 := NULL,
rank3 IN VARCHAR2 := NULL,
result_percentage IN NUMBER := NULL,
result_limit IN NUMBER := NULL,
scope IN VARCHAR2 := SCOPE_COMPREHENSIVE,
time_limit IN NUMBER := TIME_LIMIT_DEFAULT,
task_name IN VARCHAR2 := NULL,
description IN VARCHAR2 := NULL
plan_filter IN VARCHAR2 := 'MAX_ELAPSED_TIME',
sqlset_owner IN VARCHAR2 := NULL)
RETURN VARCHAR2;

*/



-- 4. Afficher les résultats d'analyses

-- Consultation des informations sur la tache

-- Vérification de la tâche créée
col task_name format a30
SELECT task_name 
FROM DBA_ADVISOR_LOG 
WHERE owner ='ORS2' and task_name='GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER';

--?

-- La vue Advisor_tasks contient des informations 
-- sur les tâches

SELECT TASK_NAME, ADVISOR_NAME, status , RECOMMENDATION_COUNT, SOURCE         
FROM USER_ADVISOR_TASKS 
WHERE task_name = 'GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER';

--?

-- La vue V$ADVISOR_PROGRESS contient des informations 
-- sur la progression des tâches

-- Exemple de consultation de la progression

SELECT sofar, totalwork FROM
V$ADVISOR_PROGRESS  vp, 
DBA_ADVISOR_LOG da
WHERE vp.username = '&MYPDBUSER'  
AND vp.task_id=da.task_id
AND da.task_name = 'GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER';

--?

--La fonction DBMS_SQLTUNE.REPORT_TUNING_TASK permet d'afficher 
--le résultat d'une analyse


SET LONG 4000
SET LONGCHUNKSIZE 4000
SET LINESIZE 1000
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK( 'GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER')
FROM DUAL;


--?

-- résultat du report il est conseillée de restructurer la
-- requête.

--?

-- la ligne ci-dessous dans le rapport indique qu'il y'a une 
-- restructuration de la requete à faire.
-- Number of SQL Restructure Findings: 1

--
-- Type de recommandation
-- Consulter le type de recommandation dans la vue
-- DBA_ADVISOR_RECOMMENDATIONS
--

col task_name format A30
col PARENT_REC_IDS format A60
col vs.SQL_TEXT format a80
col reco_type format A30
set linesize 400
set pagesize 800


select distinct dar.task_name,  vs.sql_id, vs.SQL_TEXT, dar.type reco_type  , BENEFIT
from v$sqlarea vs, 
DBA_ADVISOR_SQLPLANS da,
DBA_ADVISOR_RECOMMENDATIONS dar
where vs.sql_id=da.sql_id
and da.task_id=dar.task_id
and dar.task_name='GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER'
and sql_text not like '%EXPLAIN%'
and sql_text not like '%opt_param%'
and sql_text not like '%insert%'
and sql_text not like '%V_$SESSTAT%'
and sql_text not like '%PLAN_TABLE%'
order by dar.task_name,  vs.sql_id, reco_type;


--?

--
-- Consultation la description du problème trouvé par STA
-- Dans la vue DBA_ADVISOR_FINDINGS
-- Résultation de la recherche
---

col task_name format A20
col message format A60
col more_info format A60
col impact_type format A60
col vs.SQL_TEXT format a60
set linesize 500
set pagesize 600

select distinct dar.task_name,  da.object_id, vs.sql_id, vs.SQL_TEXT, MESSAGE, impact_type, more_info 
from v$sqlarea vs, 
DBA_ADVISOR_SQLPLANS da,
DBA_ADVISOR_FINDINGS dar
where vs.sql_id=da.sql_id
and da.task_id=dar.task_id
and da.object_id=dar.object_id
and dar.task_name='GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER'
and sql_text not like '%EXPLAIN%'
and sql_text not like '%opt_param%'
and sql_text not like '%insert%'
and sql_text not like '%V_$SESSTAT%'
and sql_text not like '%PLAN_TABLE%'
order by dar.task_name,  da.object_id, vs.sql_id;



--?

---
--- recommandation
--- consulter les actions (diagnostic) recommandées par STA
--- dans la vue DBA_ADVISOR_ACTIONS
---
-- voir 
col task_name format A20
col message format A40
col more_info format A40
col impact_type format A40
col SQL_TEXT format a40

set linesize 200
set pagesize 400


select distinct dar.task_name,  da.object_id, vs.sql_id, vs.SQL_TEXT, message 
from v$sqlarea vs, 
DBA_ADVISOR_SQLPLANS da,
DBA_ADVISOR_ACTIONS dar
where vs.sql_id=da.sql_id
and da.task_id=dar.task_id
and da.object_id=dar.object_id
and dar.task_name='GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER'
and sql_text not like '%EXPLAIN%'
and sql_text not like '%opt_param%'
and sql_text not like '%insert%'
and sql_text not like '%V_$SESSTAT%'
and sql_text not like '%PLAN_TABLE%'
order by dar.task_name, da.object_id, vs.sql_id;

--?

-- Liste des actions possibles
set linesize 400
col ATTR1 format a60
col ATTR2 format a30
col attr3 format a30
col ATTR4 format a30
col attr5 format a60

select
object_id, 
ATTR1,
ATTR2,
ATTR3,
ATTR4,
ATTR5
from DBA_ADVISOR_ACTIONS
where attr1!='SYS'
and attr1 not like '%SYSMAN%'
order by object_id;


---
--- Raisonnement
--- Raisonnement avec des explications complémentaires sur 
--- le problème.
--- Consulté pour cela la vue DBA_ADVISOR_RATIONALE
---





col task_name format A20
col message format A40
col more_info format A40
col impact_type format A40
col SQL_TEXT format a40
set linesize 200
set pagesize 400


select distinct dar.task_name,  da.object_id, vs.sql_id, vs.SQL_TEXT, message 
from v$sqlarea vs, 
DBA_ADVISOR_SQLPLANS da,
DBA_ADVISOR_RATIONALE dar
where vs.sql_id=da.sql_id
and da.task_id=dar.task_id
and da.object_id=dar.object_id
and dar.task_name='GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER'
and sql_text not like '%EXPLAIN%'
and sql_text not like '%opt_param%'
and sql_text not like '%insert%'
and sql_text not like '%V_$SESSTAT%'
and sql_text not like '%PLAN_TABLE%'
order by dar.task_name,  da.object_id, vs.sql_id;
--?






--
-- Rechercher s'il y'a des scripts générés
-- Identifier s'il ya un profile pour cette requête choisie plus
-- haut.
-- afficher le script complet ou partiel
col myscript format a1000
set long 4000
select dbms_sqltune.SCRIPT_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER', 'ALL') MYSCRIPT from dual;

select dbms_sqltune.SCRIPT_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER', 'INDEXES') MYSCRIPT from dual;
select dbms_sqltune.SCRIPT_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER', 'PROFILES') MYSCRIPT from dual;
select dbms_sqltune.SCRIPT_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER', 'STATISTICS') MYSCRIPT from dual;

-- une autre façon d'afficher le script complet
set serveroutput on
begin
dbms_output.put_line(dbms_sqltune.SCRIPT_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER', 'ALL'));
end;
/
--?

-- 5. Gérer le script SQL proposé pour le réglage SQL
-- Gérer le script SQL proposé pour le réglage SQL : Attention ce script est disponible dans le dossier %ORACLE_BASE%\admin\dpdump
-- récupérer le script et le mettre dans votre dossier : EXO91
-- Editer ce script de façon approprié
declare 
mydate varchar2(20):=to_char(sysdate, 'DD_MM_YYYY_HH24_MI_SS');
fname varchar2(300):='STA_Generate_action_script_on_bank_app_'
||'&MYPDBUSER'|| '_'||mydate||'.sql';
begin

DBMS_ADVISOR.CREATE_FILE(
DBMS_SQLTUNE.SCRIPT_TUNING_TASK('GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER'),
'DATA_PUMP_DIR', 
fname
);
end;
/

-- exécuter le script pour accepter le profile de la requête choisie

-- execute dbms_sqltune.accept_sql_profile(task_name => 'GESTION_CABINET_MEDICAL_SQL_TUNING_TASK'||'&MYPDBUSER', replace => TRUE);

---
--- Vérifier la présence d'un profie dans la vue 
---
set linesize 200

col sql_text format A40
select name ,CATEGORY,  SQL_TEXT , STATUS,FORCE_MATCHING
from dba_sql_profiles
order by name;


SPOOL OFF



