/*

Cr�er une proc�dure d'analyse des objets

Cette proc�dure permet d'analyser un segment
une table ou un tablespace avec Segment Advisor.
Il faut lui passer en param�tre :
- Le nom de la tache
- Si utile sa description
- Le type d'objet � analyser :TABLE, TABLESPACE 
- Le nom de l'objet
- Le propri�taire de l'objet si c'est une table


*/

set autotrace off
set termout on
set echo on
set serveroutput on

-- Activation du spool pour logger toutes vos actions
-- dans ce script. Adapter le chemin en fonction de votre
-- contexte.
spool &SCRIPTPATH\LOG\Ex5_9_Tune2_SA_SPOOL.log 


create or replace procedure execSegmentAdvisor(
taskName 	 IN	 varchar2,		-- Task name
taskDesc	 IN  varchar2 :=NULL, -- Task Description
objectType 	 IN 	 varchar2,		-- TABLE, TABLESPACE or SEGMENT
objectName	 IN 	 varchar2,		-- Object Name
objectOwner	 IN 	 varchar2:= NULL	-- ObjectOwner
) 
authid current_user as
obj_id  number;
attrib1	 varchar2(30);
attrib2	 varchar2(30):=NULL;
badObjectType	  exception;
pragma exception_init(badObjectType, -20000);
begin
	IF objectType NOT IN ('TABLE',  'TABLESPACE') THEN
		raise_application_error(-20000, 'L''objet � analyser n''est pas : un segment, une table et un tablespace');
		raise badObjectType;
	end if;
	
	--advisor_name => 'Segment Advisor',
	dbms_advisor.create_task (
		advisor_name => 'Segment Advisor',
		task_name    => taskName ,
		task_desc    => taskDesc
	);
	if objectType = 'TABLE' THEN
		attrib1:=objectOwner;
		attrib2:=objectName;
	elsif objectType='TABLESPACE' THEN
		attrib1:=objectName;
		attrib2:=NULL;
	end if;
	
	dbms_advisor.create_object (
		task_name   => taskName,
		object_type => objectType,
		attr1       => attrib1,
		attr2       => attrib2,
		attr3       => NULL,
		attr4       => NULL,
		attr5       => NULL,
		object_id   => obj_id
	);

	dbms_advisor.set_task_parameter(
		task_name   	=> taskName,
		parameter 		=> 'recommend_all',
		value       	=> 'TRUE'
	);
	dbms_advisor.execute_task(taskName);
	Exception
		WHEN badObjectType THEN
			raise badObjectType;
		WHEN others THEN
			raise ;

end;
/



-- 2. Analyser une table

-- 2.1 Cr�er une grosse table appel�e allObjects
drop table allObjects;
create table allObjects as select *
from all_objects, (select level l 
	from dual connect by level <= 2);


  
-- V�rifier l'espace occup�.
select sum(bytes)from USER_SEGMENTS 
where segment_name = 'ALLOBJECTS';

-- ?

-- Supprimer l'ensemble des lignes
delete from ALLOBJECTS;

-- Valider
commit;

-- V�rifier � nouveau l'espace occup�.
select sum(bytes)from USER_SEGMENTS 
where segment_name = 'ALLOBJECTS';
/*
SUM(BYTES)
----------
  12582912
*/
-- Malgr� la suppression des lignes l'espace
-- reste occup�.

-- 2.2 Analyser la table appel�e ALLOBJECTS 

-- Supprimer la tache si elle existe
execute  dbms_advisor.delete_task('TASK_SA_ALLOBJECTS');

set serveroutput on

-- Appeler la proc�dure d'anlyse execSegmentAdvisor
begin
execSegmentAdvisor(
taskName => 'TASK_SA_ALLOBJECTS',		-- Task name
taskDesc => 'Analyse avec SA de la table ALLOBJECTS', -- Task Description
objectType =>'TABLE',		-- TABLE, TABLESPACE or SEGMENT
objectName=>'ALLOBJECTS',		-- Object Name
objectOwner=>'&MYPDBUSER'	-- ObjectOwner
) ;
Exception
WHEN others then
dbms_output.put_line('Sqlcode='|| sqlcode);
dbms_output.put_line('Sqlerrm='|| sqlerrm);
end;
/
-- 2.3 Visualiser les recommandations
set linesize 200
set pagesize 500
col recommendations format a40
col segment_name format a15
SELECT segment_name,round(allocated_space/1024/1024,1) alloc_mb,
round( used_space/1024/1024, 1 ) used_mb,
round( reclaimable_space/1024/1024) reclaim_mb,
round(reclaimable_space/allocated_space*100,0) pctsave,
recommendations
FROM TABLE(dbms_space.asa_recommendations())
where segment_owner = '&MYPDBUSER'
/


-- select * from DBA_ADVISOR_DEFINITIONS

--
-- Type de recommandation
-- Consulter le type de recommandation dans la vue
-- DBA_ADVISOR_RECOMMENDATIONS
--

col task_name format A10
col PARENT_REC_IDS format A40
col  BENEFIT_TYPE format A40
set linesize 200

select TASK_NAME, type, RANK   , PARENT_REC_IDS, BENEFIT_TYPE 
from DBA_ADVISOR_RECOMMENDATIONS 
where task_name='TASK_SA_ALLOBJECTS';

--?

--
-- Consultation la description du probl�me trouv� par STA
-- Dans la vue DBA_ADVISOR_FINDINGS
-- R�sultation de la recherche
---

col task_name format A10
col message format A40
col more_info format A40
col impact_type format A40
set linesize 200
select TASK_NAME, MESSAGE, impact_type, more_info 
from DBA_ADVISOR_FINDINGS 
where task_name='TASK_SA_ALLOBJECTS';

--?


--- recommandation
--- consulter les actions (diagnostic) recommand�es par SA
--- dans la vue DBA_ADVISOR_ACTIONS
---
Col command format A20
Col attr1 format A40
Set long 500
SELECT rec_id, action_id, command, attr1
FROM user_advisor_actions 
WHERE task_name = 'TASK_SA_ALLOBJECTS'
ORDER BY rec_id, action_id;

--?

-- Avant d'appliquer v�rifier ces recommandations
-- depuis OEM.

-- 2.4 Appliquer les recommandation

-- Enable row movement
Alter table ALLOBJECTS enable row movement;

--Compacte, D�place les lignes et ajuste le HWM 
--(d�finit un nouveau HWM). Ajuste aussi les indexes 
--(option cascade)
ALTER TABLE ALLOBJECTS SHRINK SPACE cascade;

-- V�rifier l'espace occup�.
select sum(bytes)from USER_SEGMENTS 
where segment_name = 'ALLOBJECTS';

--?
	 
	 
	 
-----------------------------------
-- 3. Analyser un tablespace
------------------------------------

-- Cr�er une grosse table appel�e allObjects
drop table allObjects2;
create table allObjects2 as select *
from all_objects, (select level l from dual connect by level <= 2)
/

  
-- V�rifier l'espace occup�.
select sum(bytes)from USER_SEGMENTS 
where segment_name = 'ALLOBJECTS2';

--?

-- Supprimer l'ensemble des lignes
delete from ALLOBJECTS2;

commit;

-- V�rifier l'espace occup�.
select sum(bytes)from USER_SEGMENTS 
where segment_name = 'ALLOBJECTS2';

--?

  
-- Malgr� la suppression des lignes l'espace
-- reste occup�.

-- Analyser la table avec Segment Advisor

-- Supprimer la tache si elle existe
execute  dbms_advisor.delete_task('TASK_SA_TS_USERS');

set serveroutput on
begin
execSegmentAdvisor(
taskName => 'TASK_SA_TS_USERS',		-- Task name
taskDesc => 'Analyse avec SA du tablespace USERS', -- Task Description
objectType =>'TABLESPACE',		-- TABLE OR TABLESPACE 
objectName=>'USERS',		-- Object Name
objectOwner=>'&MYPDBUSER'	-- ObjectOwner
) ;
Exception
WHEN others then
dbms_output.put_line('Sqlcode='|| sqlcode);
dbms_output.put_line('Sqlerrm='|| sqlerrm);
end;
/
-- Visualiser les recommandations
col recommendations format a40
col segment_name format a15
SELECT segment_name,round(allocated_space/1024/1024,1) alloc_mb,
round( used_space/1024/1024, 1 ) used_mb,
round( reclaimable_space/1024/1024) reclaim_mb,
round(reclaimable_space/allocated_space*100,0) pctsave,
recommendations
FROM TABLE(dbms_space.asa_recommendations())
/

--?


-- Display the findings.
SET LINESIZE 250
set pagesize 300
COLUMN task_name FORMAT A18
COLUMN object_type FORMAT A15
COLUMN schema FORMAT A15
COLUMN object_name FORMAT A20
COLUMN object_name FORMAT A20
COLUMN message FORMAT A30
COLUMN more_info FORMAT A30

SELECT f.task_name,
       f.impact,
       o.type AS object_type,
       o.attr1 AS schema,
       o.attr2 AS object_name,
       f.message,
       f.more_info
FROM   dba_advisor_findings f
       JOIN dba_advisor_objects o 
	   ON f.object_id = o.object_id 
	   AND f.task_name = o.task_name
WHERE  f.task_name ='TASK_SA_TS_USERS';

--?

--
-- Type de recommandation
-- Consulter le type de recommandation dans la vue
-- DBA_ADVISOR_RECOMMENDATIONS
--

col task_name format A10
col PARENT_REC_IDS format A40
col  BENEFIT_TYPE format A40
set linesize 200

select TASK_NAME, type, RANK   , PARENT_REC_IDS, BENEFIT_TYPE 
from DBA_ADVISOR_RECOMMENDATIONS 
where task_name='TASK_SA_TS_USERS';

--?


--
-- Consultation la description du probl�me trouv� par STA
-- Dans la vue DBA_ADVISOR_FINDINGS
-- R�sultation de la recherche
---

col task_name format A10
col message format A40
col more_info format A40
col impact_type format A40
set linesize 200
select TASK_NAME, MESSAGE, impact_type, more_info 
from DBA_ADVISOR_FINDINGS 
where task_name='TASK_SA_TS_USERS';

--?

--- recommandation
--- consulter les actions (diagnostic) recommand�es par SA
--- dans la vue DBA_ADVISOR_ACTIONS
---
Col command format A50
Col attr1 format A40
Set long 500
SELECT rec_id, action_id, command, attr1
FROM user_advisor_actions 
WHERE task_name = 'TASK_SA_TS_USERS'
ORDER BY rec_id, action_id;

--?

--
-- Rechercher s'il y'a des scripts g�n�r�s
-- Identifier s'il ya un profile pour cette requ�te choisie plus
-- haut.
-- afficher le script complet ou partiel
col myscript format a1000
set long 4000
select dbms_sqltune.SCRIPT_TUNING_TASK('TASK_SA_TS_USERS', 'ALL') MYSCRIPT from dual;



set serveroutput on
declare
 buf CLOB;
begin
buf := DBMS_ADVISOR.GET_TASK_SCRIPT('TASK_SA_TS_USERS');
dbms_output.put_line( buf);
end;
/

spool off
--spool of 

-- La fonction CREATE_FILE permet de cr�er le fichier 
-- contenant le script
-- Pas applicable pour le conseiller SA : Segment Advisor
/*
begin
DBMS_ADVISOR.CREATE_FILE(
buffer=>DBMS_ADVISOR.GET_TASK_SCRIPT('TASK_SA_TS_USERS'),
location =>'DATA_PUMP_DIR', 
 filename=>'segment_advscript.sql'
);
end;
/
*/
