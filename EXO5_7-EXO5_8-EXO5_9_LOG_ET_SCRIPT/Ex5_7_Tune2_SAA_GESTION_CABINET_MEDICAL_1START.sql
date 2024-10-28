/*

Exercice 1

Travail � faire via l'API

Ecrire un script qui permet d'analyser et produire des recommandations sur des requ�tes SQL stock�es dans une table utilisateur. Vous devez pour cela :
0. Connexion
1. D�finir une t�che avec un template OLTP ou DWH ou mixte
2. D�finir un workload � partir d'une table Utilisateur (voir Annexe 11.1) 
� cr�er � remplir avec au moins deux requ�tes
3. Attacher la t�che aux workload
4. Fixer certains param�tres de la t�che tel que 
EXECUTION_TYPE = INDEX_ONLY puis FULL
MODE = COMPREHENSIVE
5. Ex�cuter la t�che


Visualiser les recommandations

Et si possible accepter les recommandations

Travail � faire via OEM

Refaire le travail fait avec l'API via OEM

	
*/

-----------------------------------------------------------------------------------
-- 1. D�finition de variables, cr�ation d'un user si utile, 
-- Connexion � la base de donn�es 
-----------------------------------------------------------------------------------

cmd
-- Lancer sqlplus sans se logger
sqlplus /nolog

-- D�finir la variable qui indique l'emplacement des scripts
define SCRIPTPATH=C:\workspaceSQL\ScriptsTune2\EXO_5_7

-- D�finir la variable contenant le nom de l'instance
define MYINSTANCE=ORCL

-- D�finir la vairiable qui va contenir le nom r�seau de votre base PDB.
-- Le nom r�seau se dans le fichier tnsnames.ora
-- Il est disponible dans le dossier : %ORACLE_HOME%\network\admin
define DBALIASPDB=HOPITAL

-- D�finir la vairiable qui va contenir le nom r�seau de votre base CDB.
-- Le nom r�seau se dans le fichier tnsnames.ora
-- Il est disponible dans le dossier : %ORACLE_HOME%\network\admin
define DBALIASCDB=ORCL

-- D�finir la variable contenant le nom de l'utilisateur que vous allez 
-- cr�er au niveau PDB ou utiliser s'il existe d�j�. 
define MYPDBUSER=GESTION_CABINET_MEDICAL
 
-- D�finir la variable contenant le pass de l'utilisateur que vous allez 
-- cr�er au niveau PDB ou utiliser s'il existe d�j�.
define MYPDBUSERPASS=pass123$

-- D�finir la variable contenant la trace que vous souhaitez :
-- ON : si affiche r�sultat+plan
-- TRACEONLY : si affichage plan uniquement
define TRACEOPTION=TRACEONLY

-- Connexion avec le nouvel utilisateur ou un utilisateur existant au niveau
-- PDB. 
connect &MYPDBUSER/&MYPDBUSERPASS@&DBALIASPDB

---------------------------------------------------------------------------------------
-- 2. activation du script pour ex�cuter le conseiller SAA
-- Le r�sultat de cette ex�cution sera la g�n�ration dans le dossier :
-- %ORACLE_BASE%\admin\dpdump\nomBase\nomPdb
-- d'un fichier nomm� : SAA_Generate_script_on_bank_app_'||mydate||'.sql
@&SCRIPTPATH\Ex5_7_Tune2_SAA_GESTION_CABINET_MEDICAL_2ACTIVITY.SQL

-- 3 Impl�mentation des recommandations
-- Copier le contenu du fichier g�n�r� en 2 dans le dossier fichier :
-- Ex101_Tune2_SAA_BANK_3Recommandations.sql
-- Ce fichier se trouve dans le dossier :&SCRIPTPATH\EXO101
-- Nettoyer les doublons puis ex�cutez ce script pour impl�menter les recommandations
@&SCRIPTPATH\Ex5_7_Tune2_SAA_GESTION_CABINET_MEDICAL_3Recommandations.sql


-- 4. activation du script pour r�ex�cuter le conseiller SAA
-- Le r�sultat de cette r�ex�cution sera la g�n�ration dans le dossier :
-- %ORACLE_BASE%\admin\dpdump\nomBase\nomPdb
-- d'un fichier nomm� : SAA_Generate_script_on_bank_app_'||mydate||'.sql
-- Si l'�tape 3 est faite il ne doit pas avoir de recommandationn d'index
@&SCRIPTPATH\Ex5__Tune2_SAA_GESTION_CABINET_MEDICAL_4ACTIVITYRetune.SQL

