/*


Créer une procédure d'analyse des objets

Cette procédure permet d'analyser un segment
une table ou un tablespace avec Segment Advisor.
Il faut lui passer en paramètre :
- Le nom de la tache
- Si utile sa description
- Le type d'objet à analyser :TABLE, TABLESPACE 
- Le nom de l'objet
- Le propriétaire de l'objet si c'est une table


*/


-- se connecter à la base
-- Se connecter en tant ORS1 sur votre instance Oracle
-- Se déplacer dans le dossier 
-- Changer de répertoire sous en se déplacant dans le dossier ou se trouve :..\ScriptsTune2
-- exemple
-- cd  1agm05092005\1Cours\5ORS\2014_2015\TP_TUNE2_MODELE_2015\ScriptsTune2
-- Lancer sqlplus dans ce dossier ScriptsTune2

-----------------------------------------------------------------------------------
-- 1. Définition de variables, création d'un user si utile, 
-- Connexion à la base de données 
-----------------------------------------------------------------------------------

-- Connexion à la base de données 
-- Télécharger instant client pour votre OS site Oracle
-- ou récupérer le dans l'espace partagé que vous a communiqué l'enseignant
-- Créer un dossier "logiciels" sur votre disque C ou D
-- Prendre instant client sur le drive ici : 
-- ..\3ETU_M2MBDS_ESATIC\1COURS\Mopolo\5Tuning\OutilInstantClientet placer le zip -- dans le dossier : logiciel dezippé.
-----------------------------------------------------------------------------------

cmd
cd C:\Logiciels\..\instantclient_21_3_WindowsESATIC
cd C:\Logiciels\7_INSTANT_CLIENT\instantclient_21_3_WindowsESATIC\instantclient_21_3_WindowsESATIC
-- Lancer sqlplus sans se logger
sqlplus /nolog

-- Définir la variable qui indique l'emplacement des scripts
-- Attention le chemin vers le dossier du cours Tuning doit être sans espace
-- Créer un par exemple un dossier c:\tporacle et y déposer le dossier
-- du cours. 
define SCRIPTPATH=C:\workspaceSQL\ScriptsTune2\EXO_5_9

-- Définir la variable contenant le nom de l'instance

define MYINSTANCE=ORCL

-- Définir la vairiable qui va contenir le nom réseau de votre base PDB.
-- Le nom réseau se dans le fichier tnsnames.ora
-- Il est disponible dans le dossier : %ORACLE_HOME%\network\admin
-- Lancer netmgr pour Ajouter l'alias PDBM2ESA
-- 
define DBALIASPDB=HOPITAL

-- Définir la vairiable qui va contenir le nom réseau de votre base CDB.
-- Le nom réseau se dans le fichier tnsnames.ora
-- Il est disponible dans le dossier : %ORACLE_HOME%\network\admin
define DBALIASCDB=ORCL

-- Définir la variable contenant le nom de l'utilisateur que vous allez 
-- utiliser au niveau CDB. 
define MYCDBUSER=C##ORCLADMIN
 
-- Définir la variable contenant le pass de l'utilisateur que vous allez 
-- utiliser au niveau CDB.
define MYCDBUSERPASS=pass123$

-- Définir la variable contenant le nom de l'utilisateur que vous allez 
-- créer au niveau PDB ou utiliser s'il existe déjà. 

define MYPDBNUM=?
define MYPDBUSER=GESTION_CABINET_MEDICAL
 
-- Définir la variable contenant le pass de l'utilisateur que vous allez 
-- créer au niveau PDB ou utiliser s'il existe déjà.
define MYPDBUSERPASS=pass123$

-- Définir la variable contenant la trace que vous souhaitez :
-- ON : si affiche résultat+plan
-- TRACEONLY : si affichage plan uniquement
define TRACEOPTION=TRACEONLY

-- pour voir les variables définies tapez
define


-- Connexion avec le nouvel utilisateur ou un utilisateur existant au niveau
-- PDB. 
connect &MYPDBUSER@&DBALIASPDB/&MYPDBUSERPASS


---------------------------------------------------------------------------------------
-- 2. activation du script pour exécuter le conseiller SAA
-- Le résultat de cette exécution sera la génération dans le dossier :
-- %ORACLE_BASE%\admin\dpdump\nomBase\nomPdb
-- d'un fichier nommé : SAA_Generate_script_on_bank_app_'||mydate||'.sql
@&SCRIPTPATH\Ex5_9_Tune2_SA_2ACTIVITY.SQL

