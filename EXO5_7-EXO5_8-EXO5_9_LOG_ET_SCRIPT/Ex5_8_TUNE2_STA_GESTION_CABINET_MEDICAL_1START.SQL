/*

LIRE ATTENTIVEMENT LE CHAPITRE 5, 6, 7, 8 et 9 DU COURS TUNE 2 
CONCERNANT LE REGLAGE AUTOMATIQUE DE REQUETES ET SURTOUT
SQL TUNING ADVISOR (voir aussi les annexes).

Ecrire un script qui permet d'analyser et produire des 
recommandations sur un pool de requêtes sur l'application
APPLIBANK regroupé dans un  SQL Tuning Set. Le remplissage
du SQL TUNING SET se fait en récupérant les requêtes entre
deux clichés AWR.

Travail à faire via l'API et en partie via OEM.

1. Charger l'application bancaire (AppliBank.sql)
dans le schéma de l'utilisateur &MYUSER

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

-- Se connecter en tant ORS2 sur votre instance Oracle
-- Se déplacer dans le dossier 
-- Changer de répertoire sous en se déplacant dans le dossier ou se trouve :..\ScriptsTune2
-- exemple
-- cd  1agm05092005\1Cours\5ORS\2014_2015\TP_TUNE2_MODELE_2015\ScriptsTune2
-- Lancer sqlplus dans ce dossier ScriptsTune2

-----------------------------------------------------------------------------------
-- 1. Définition de variables, création d'un user si utile, 
-- Connexion à la base de données 
-----------------------------------------------------------------------------------

cmd
-- Lancer sqlplus sans se logger
sqlplus /nolog

-- Définir la variable qui indique l'emplacement des scripts
define SCRIPTPATH=C:\workspaceSQL\ScriptsTune2\EXO_5_8



-- Définir la variable contenant le nom de l'instance
-- define MYINSTANCE=ORCL
define MYINSTANCE=ORCL
-- Définir la vairiable qui va contenir le nom réseau de votre base PDB.
-- Le nom réseau se dans le fichier tnsnames.ora
-- Il est disponible dans le dossier : %ORACLE_HOME%\network\admin
-- define DBALIASPDB=ORCLPDB
define DBALIASPDB=HOPITAL
-- Définir la vairiable qui va contenir le nom réseau de votre base CDB.
-- Le nom réseau se dans le fichier tnsnames.ora
-- Il est disponible dans le dossier : %ORACLE_HOME%\network\admin
--define DBALIASCDB=ORCL
define DBALIASCDB=ORCL
-- Définir la variable contenant le nom de l'utilisateur que vous allez 
-- utiliser au niveau CDB. 
define MYCDBUSER=SYSTEM
 
-- Définir la variable contenant le pass de l'utilisateur que vous allez 
-- utiliser au niveau CDB.
define MYCDBUSERPASS=pass123$

-- Définir la variable contenant le nom de l'utilisateur que vous allez 
-- créer au niveau PDB ou utiliser s'il existe déjà. 
define MYPDBUSER=GESTION_CABINET_MEDICAL
 
-- Définir la variable contenant le pass de l'utilisateur que vous allez 
-- créer au niveau PDB ou utiliser s'il existe déjà.
define MYPDBUSERPASS=pass123$

-- Définir la variable contenant la trace que vous souhaitez :
-- ON : si affiche résultat+plan
-- TRACEONLY : si affichage plan uniquement
define TRACEOPTION=TRACEONLY

-- Connexion avec le nouvel utilisateur ou un utilisateur existant au niveau
-- PDB. 
connect &MYPDBUSER@&DBALIASPDB/&MYPDBUSERPASS

-- 1. Lancer ce script au niveau PDB pour créer les tables (client, compte et transaction) 
-- et insérer des lignes de l'application bancaire AppliBank
@&SCRIPTPATH\Ex5_8_TUNE2_STA_GESTION_CABINET_MEDICAL_DDL.SQL


-- 2. Exécuter les requêtes de l'application bancaire avant leur optimisation
-- et demander au conseiller SQL TUNING ADVISOR de les régler
-- Un script avec des recommandations de nom :
-- 'STA_Generate_action_script_on_bank_app_'||'&MYPDBUSER'|| '_'||mydate||'.sql'
-- sera générer dans le dossier : %ORACLE_BASE%\ADMIN\NOMBASE\DPDUMP\NOMPDB
-- Un fichier log appelé Ex91_TUNE2_STA_BANK_3TUNE_QUERY.LOG
-- est généré dans le dossier &scriptpath\LOG
-- Ce fichier contient la trace d'exécution avec les plans d'exécution
@&SCRIPTPATH\Ex5_8_TUNE2_STA_GESTION_CABINET_MEDICAL_3TUNE_QUERY.SQL



-- 3. Après le l'exécution du script de tuning du point 2
-- Ouvrez le fichier généré en 2. et copiez les recommandations qui s'y 
-- trouvent et collez les dans le fichier des recommandations ci-dessus.
-- Eliminez les doublons. Exécuter ensuite ce script comme suit:
@&SCRIPTPATH\Ex5_8_TUNE2_STA_GESTION_CABINET_MEDICAL_6APPLY_RECOMMANDATIONS.sql

-- 4. Afin de vérifier que les recommandations exécutées en 3. ont 
-- été bien prises en compte, rélancer les activités faites en 2.
-- Il s'agit du même script qu'en 2 juste renommé.
-- Un script avec des recommandations de nom :
-- 'STA2_Generate_action_script_on_bank_app_'||'&MYPDBUSER'|| '_'||mydate||'After_Tune.sql'
-- sera générer dans le dossier : %ORACLE_BASE%\ADMIN\NOMBASE\DPDUMP\NOMPDB
-- Comparez ce ficher avec celui généré en 2
-- Un fichier log appelé Ex91_TUNE2_STA_BANK_7RETUNE_QUERY.LOG
-- est généré dans le dossier &scriptpath\LOG
-- Ce fichier contient la trace d'exécution avec les plans d'exécution
-- Comparez les plans d'exécution des deux LOG (LOG générés en 2 et en 4)
-- Refaire si utile l'étape 3 des recommandations
@&SCRIPTPATH\Ex5_8_TUNE2_STA_GESTION_CABINET_MEDICAL_7RETUNE_QUERY.SQL



