-- 4.1  Organisation  physique  de  la  base  sous  Oracle  18c  ou  plus(2 
-- jours)

-- Vous devez donc assurerer les tâches suivantes : 
-- o Créer les tablespaces suivants et expliquer leur intérêt: 
--  Un ou plusieurs tabespaces pour stocker les données des tables. 
--  Un ou plusieurs tablespaces pour stocker les données d’indexes 
--  Un tablespace pour stocker les segments temporaires. 
-- Note : Tous vos tablespaces seront gérés localement. Ils seront en mode 
-- AUTOALLOCATE ou UNIFORM SIZE.  Vous  devez  expliquer  l’intérêt  et  les 
-- bénéfices de vos choix.
<réponses et trace ici> :
-- 1. Tablespaces pour stocker les données des tables
--     Création :
    CREATE TABLESPACE DATA_TS
    DATAFILE '%ORACLE_BASE%\oradata\XE\hopitalpdb\datafile_data_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    AUTOALLOCATE;

    -- Tablespace created.

-- 2. Tablespaces pour stocker les données d’indexes
--     Création :

    CREATE TABLESPACE INDEX_TS
    DATAFILE '%ORACLE_BASE%\oradata\XE\hopitalpdb\datafile_index_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    AUTOALLOCATE;

    -- Tablespace created.

-- 3. Tablespace pour stocker les segments temporaires
--     Création :

    CREATE TEMPORARY TABLESPACE TEMP_TS
    TEMPFILE '%ORACLE_BASE%\oradata\XE\hopitalpdb\tempfile_temp_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL;

    -- Tablespace created.

-- ** En résumé ** :
    -- Tablespaces dédiés pour les tables et les indexes permettent une meilleure gestion
    -- des performances et des I/O.

    -- Tablespace temporaire est crucial pour les opérations SQL complexes.

    -- Gestion locale optimise la gestion des extensions et améliore la performance.

    -- AUTOALLOCATE convient pour une gestion dynamique de l’espace, tandis que UNIFORM SIZE 
    -- est approprié si la taille des objets est prévisible et similaire.

    -- Ces choix garantissent une meilleure organisation physique de la base de données 
    -- et facilitent la gestion quotidienne, tout en assurant une performance optimale.




-- 4.1.1. Créer  un  utilisateur  de  votre  choix  qui  sera  propriétaire  de  votre  application.  Les 
-- segments  temporaires  doivent  être  localisés  dans  le  tablespace  approprié  créé 
-- précédement. Vous devez lui donner les droits appropriés. 

-- 1. Création de l'utilisateur
    CREATE USER Hopital IDENTIFIED BY pass123$
    DEFAULT TABLESPACE data_ts
    TEMPORARY TABLESPACE temp_ts
    QUOTA UNLIMITED ON data_ts;

-- 2. Attribution des droits
    GRANT DBA TO Hopital;

-- 3. Créer le schéma de données en séparant les données des tables et les index  
--  Vous  dimensionnerez  de  façon  pertinente  les  segments.  Pour  cela  vous  devez 
-- utiliser  le  package  DBMS_SPACE  pour  estimer  la  volumétrie  de  vos  tables  et 
-- de vos indexes afin de trouver le volume de données nécessaire dès la création 
-- de ces segments. Il est important d’estimer le nombre total de lignes de chacune 
-- de vos tables.


-- Nota Bene : La procédure Oracle DBMS_SPACE.CREATE_TABLE_COST ne prend pas en charge 
-- les types abstraits tels que les types d'objet, les tables imbriquées ou les collections
-- (par exemple, VARRAY, TABLE OF) directement dans son entrée DDL. Donc pour calculer la volumétrie
-- de nos tables et de nos indexes, on va d'abord calculer la taille moyennes lignes manuellement.


-- Estimation pour la table O_PATIENT
    -- ID_PERSONNE (NUMBER(8)) = 8 octets 
    -- NUMERO_SECURITE_SOCIALE VARCHAR2(12) => 12 octets
    -- NOM VARCHAR2(30) => 30 octets 
    -- EMAIL VARCHAR2(30) => 30 octets
    -- ADRESSE = NUMERO NUMBER(4) => 4 octets +  RUE VARCHAR2(40) => 40 octets +  CODE_POSTAL NUMBER(5) => 5 octets 
    --             +  VILLE VARCHAR2(30) => 30 octets = 79 octets
    -- SEXE VARCHAR2(10) => 10 octets
    -- DATE_NAISSANCE DATE => 7 octets
    -- LIST_TELEPHONES LIST_TELEPHONES_T => VARRAY(3) OF VARCHAR2(30) = 90 octets
    -- LIST_PRENOMS LIST_PRENOMS_T => VARRAY(3) OF VARCHAR2(30) = 90 octets
    -- POIDS NUMBER(3) => 3 octets
    -- HAUTEUR NUMBER(3) => 3 octets
    -- PLISTREFRENDEZVOUS LIST_REFRENDEZVOUS_T => Si un patient a en moyenne 5 rendez-vous,
    --                                             chaque référence prend 16 octets, soit 5 × 16 = 80 octets.
    -- pListRefConsultations LIST_REF_CONSULTATION_T => Si un patient a en moyenne 5 consultations,
    --                                             chaque référence prend 16 octets, soit 5 × 16 = 80 octets.
    -- pListRefFactures LIST_REF_FACTURE_T => Si un patient a en moyenne 5 factures,
    --                                             chaque référence prend 16 octets, soit 5 × 16 = 80 octets. 

-- Calculer la Taille Moyenne des Lignes 
    -- TML = 8 + 12 + 30 + 30 + 79 + 10 + 7 + 90 + 90 + 3 + 3 + 80 + 80 + 80 = 428 octets

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_PATIENT.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    428,
                                    1000,           -- Estimation pour 1000 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /

    -- PL/SQL procedure successfully completed.
    -- used bytes =  516096 bytes
    -- allocated bytes = 524288 bytes

    DROP TABLE O_PATIENT CASCADE CONSTRAINTS;
    CREATE TABLE O_PATIENT OF PATIENT_T(
	CONSTRAINT pk_o_patient_id_personne PRIMARY KEY(ID_PERSONNE),
	NUMERO_SECURITE_SOCIALE CONSTRAINT o_patient_num_secu_social_not_null NOT NULL,
	NOM CONSTRAINT o_patient_nom_not_null NOT NULL,
	EMAIL CONSTRAINT o_patient_email_not_null NOT NULL,
	DATE_NAISSANCE CONSTRAINT o_patient_date_naissance_not_null NOT NULL,
	SEXE CONSTRAINT o_patient_sexe_not_null NOT NULL,
	POIDS CONSTRAINT o_patient_poids_not_null NOT NULL,
	HAUTEUR CONSTRAINT o_patient_hauteur_not_null NOT NULL,
	CONSTRAINT o_patient_sexe_check CHECK (SEXE IN ('Masculin', 'Feminin', 'Autre'))
    )
    NESTED TABLE pListRefRendezVous STORE AS o_patient_table_pListRefRendezVous
    NESTED TABLE pListRefConsultations STORE AS o_patient_table_pListRefConsultations
    NESTED TABLE pListRefFactures STORE AS o_patient_table_pListRefFactures
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 524K NEXT 516K MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


-- Estimation pour la table O_MEDECIN
    -- ID_PERSONNE (NUMBER(8)) = 8 octets 
    -- NUMERO_SECURITE_SOCIALE VARCHAR2(12) => 12 octets
    -- NOM VARCHAR2(30) => 30 octets 
    -- EMAIL VARCHAR2(30) => 30 octets
    -- ADRESSE = NUMERO NUMBER(4) => 4 octets +  RUE VARCHAR2(40) => 40 octets +  CODE_POSTAL NUMBER(5) => 5 octets 
    --             +  VILLE VARCHAR2(30) => 30 octets = 79 octets
    -- SEXE VARCHAR2(10) => 10 octets
    -- DATE_NAISSANCE DATE => 7 octets
    -- LIST_TELEPHONES LIST_TELEPHONES_T => VARRAY(3) OF VARCHAR2(30) = 90 octets
    -- LIST_PRENOMS LIST_PRENOMS_T => VARRAY(3) OF VARCHAR2(30) = 90 octets
    -- CV CLOB = > 2000 octets
    -- SPECIALITE VARCHAR2(40) => 40 octets
    -- pListRefRendezVous LIST_REFRENDEZVOUS_T => Si un medecin a en moyenne 5 rendez-vous,
    --                                             chaque sélection prend 16 octets, soit 5 × 16 = 80 octets. 
    -- pListRefConsultations LIST_REF_CONSULTATION_T => Si un medecin a en moyenne 5 consultations,
    --                                             chaque sélection prend 16 octets, soit 5 × 16 = 80 octets. 
   
-- Calculer la Taille Moyenne des Lignes 
    -- TML = 8 + 12 + 30 + 30 + 79 + 10 + 7 + 90 + 90 + 2000 + 40 + 80 + 80 = 2556 octets

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_MEDECIN.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    2556,
                                    100,           -- Estimation pour 100 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /

    -- used bytes: 409600 bytes
    -- allocated bytes: 458752 bytes

    DROP TABLE O_MEDECIN CASCADE CONSTRAINTS;
    CREATE TABLE O_MEDECIN OF MEDECIN_T(
	CONSTRAINT pk_o_medecin_id_personne PRIMARY KEY(Id_Personne),
	Numero_Securite_Sociale CONSTRAINT o_medecin_num_secu_social_not_null NOT NULL,
	Nom CONSTRAINT o_medecin_nom_not_null NOT NULL,
	Email CONSTRAINT o_medecin_email_not_null NOT NULL,
	DATE_NAISSANCE CONSTRAINT o_medecin_date_naissance_not_null NOT NULL,
	Sexe CONSTRAINT o_medecin_sexe_not_null NOT NULL,
	CONSTRAINT o_medecin_sexe_check CHECK (Sexe IN ('Masculin', 'Feminin', 'Autre')),
	Specialite CONSTRAINT o_medecin_specialite_not_null NOT NULL,
	CONSTRAINT o_medecin_specialite_check CHECK (Specialite IN ('Urologue', 'Gynecologue', 'Interniste', 'Cardiologue', 'Pediatre', 'Chirurgien'))
    )
    NESTED TABLE pListRefRendezVous STORE AS o_medecin_table_pListRefRendezVous
    NESTED TABLE pListRefConsultations STORE AS o_medecin_table_pListRefConsultations
    LOB(CV) STORE AS storeCV(PCTVERSION 30)
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 458K NEXT 409K MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


-- Estimation pour la table O_EXAMEN
    -- ID_EXAMEN NUMBER(8) => 8 octets
    -- refConsultation REF CONSULTATION_T => 16 octets
    -- Details_Examen VARCHAR2(200) => 200 octets
    -- Date_Examen DATE => 7 octets  

-- Calculer la Taille Moyenne des Lignes 
    -- TML = 8 + 16 + 200 + 7 = 231 octets

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_EXAMEN.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    231,
                                    3000,           -- Estimation pour 3000 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /

    -- used bytes: 794624 bytes
    -- allocated bytes: 851968 bytes

    DROP TABLE O_EXAMEN CASCADE CONSTRAINTS;
    CREATE TABLE O_EXAMEN OF EXAMEN_T(
	CONSTRAINT pk_o_examen_id_examen PRIMARY KEY(Id_Examen),
	refConsultation CONSTRAINT o_examen_ref_consultation_not_null NOT NULL,
	Details_Examen CONSTRAINT details_examen_not_null NOT NULL,
	Date_Examen CONSTRAINT date_examen_not_null NOT NULL
    )
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 794K NEXT 851K MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


--  Estimation pour la table O_PRESCRIPTION
    -- ID_PRESCRIPTION NUMBER(8) => 8 octets
    -- refConsultation REF CONSULTATION_T => 16 octets
    -- Details_Prescription VARCHAR2(200) => 200 octets
    -- Date_Prescription DATE => 7 octets

-- Calculer la Taille moyenne des Lignes 
    -- TML = 8 + 16 + 200 + 7 = 231 octets

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_PRESCRIPTION.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    231,
                                    3000,           -- Estimation pour 3000 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);    
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /   

    -- used bytes: 794624 bytes
    -- allocated bytes: 851968 bytes    

    DROP TABLE O_PRESCRIPTION CASCADE CONSTRAINTS;
    CREATE TABLE O_PRESCRIPTION OF PRESCRIPTION_T(
	CONSTRAINT pk_o_prescription_id_prescription PRIMARY KEY(Id_Prescription),
	refConsultation CONSTRAINT o_prescription_ref_consultation_not_null NOT NULL,
	Details_Prescription CONSTRAINT details_prescription_not_null NOT NULL,
	Date_Prescription CONSTRAINT date_prescription_not_null NOT NULL
    )
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 794K NEXT 851K MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


--  Estimation pour la table O_FACTURE
    -- ID_FACTURE NUMBER(8) => 8 octets
    -- refPatient REF PATIENT_T => 16 octets
    -- refConsultation REF CONSULTATION_T => 16 octets
    -- Montant_Total NUMBER(8) => 8 octets
    -- Date_Facture DATE => 7 octets

-- Calculer la Taille moyenne des Lignes 
    -- TML = 8 + 16 + 16 + 8 + 7 = 55 octets

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_FACTURE.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    55,
                                    3000,           -- Estimation pour 3000 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /           

    -- used bytes: 196608 bytes
    -- allocated bytes: 196608 bytes    

    DROP TABLE O_FACTURE CASCADE CONSTRAINTS;
    CREATE TABLE O_FACTURE OF FACTURE_T(	
	CONSTRAINT pk_o_facture_id_facture PRIMARY KEY(Id_Facture),
	refPatient CONSTRAINT o_facture_ref_patient_not_null NOT NULL,
	refConsultation CONSTRAINT o_facture_ref_consultation_not_null NOT NULL,
	Montant_Total CONSTRAINT montant_total_not_null NOT NULL,
	Date_Facture CONSTRAINT date_facture_not_null NOT NULL
    )
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 197K NEXT 197K MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


--  Estimation pour la table O_RENDEZ_VOUS
    -- Id_Rendez_Vous NUMBER(8) =>  8 octets
    -- refPatient REF PATIENT_T => 16 octets
	-- refMedecin REF MEDECIN_T => 16 octets
	-- Date_Rendez_Vous DATE    =>  7 octets
	-- Motif VARCHAR2(200)      => 200 octets

 -- Calculer la Taille moyenne des Lignes
    -- TML = 8 + 16 + 16 + 7 + 200 = 247 octets   

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_RENDEZ_VOUS.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    247,
                                    3000,           -- Estimation pour 3000 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /

    -- used bytes: 851968 bytes
    -- allocated bytes: 851968 bytes

    DROP TABLE O_RENDEZ_VOUS CASCADE CONSTRAINTS;
    CREATE TABLE O_RENDEZ_VOUS OF RENDEZ_VOUS_T(
	CONSTRAINT pk_o_rendez_vous_id_rendez_vous PRIMARY KEY(Id_Rendez_Vous),
	refPatient CONSTRAINT o_rendez_vous_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_rendez_vous_ref_medecin_not_null NOT NULL,
	Date_Rendez_Vous CONSTRAINT date_rendez_vous_not_null NOT NULL,
	Motif CONSTRAINT motif_not_null NOT NULL
    )
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 852K NEXT 852K MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


--  Estimation pour la table O_CONSULTATION
    -- Id_Consultation NUMBER(8) => 8 octets
	-- refPatient REF PATIENT_T  => 16 octets
	-- refMedecin REF MEDECIN_T  => 16 octets
	-- Raison VARCHAR2(200)      => 200 octets
	-- Diagnostic VARCHAR2(200)  => 200 octets
	-- Date_Consultation DATE    => 7 octets

 -- Calculer la Taille moyenne des Lignes
    -- TML = 8 + 16 + 16 + 200 + 200 + 7 = 440 octets 

    -- utilisons la procédure DBMS_SPACE.CREATE_TABLE_COST pour estimer la volumétrie de la table O_CONSULTATION.
    DECLARE
        l_used_bytes        NUMBER;
        l_allocated_bytes   NUMBER;
    BEGIN
        -- Estimation pour une table simple avec des colonnes standards
        DBMS_SPACE.CREATE_TABLE_COST ('DATA_TS',
                                    440,
                                    3000,           -- Estimation pour 3000 lignes
                                    10, -- PCTFREE : espace réservé pour des mises à jour
                                    l_used_bytes,
                                    l_allocated_bytes);

        DBMS_OUTPUT.PUT_LINE ('Estimated used bytes: ' || l_used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Estimated allocated bytes: ' || l_allocated_bytes);
    END;
    /  

    -- used bytes: 1540096 bytes
    -- allocated bytes: 2097152 bytes    

    DROP TABLE O_CONSULTATION CASCADE CONSTRAINTS;
    CREATE TABLE O_CONSULTATION OF CONSULTATION_T(
	CONSTRAINT pk_o_consultation_id_consultation PRIMARY KEY(Id_Consultation),
	refPatient CONSTRAINT o_consultation_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_consultation_ref_medecin_not_null NOT NULL,
	Raison CONSTRAINT raison_not_null NOT NULL,
	Date_Consultation CONSTRAINT date_consultation_not_null NOT NULL
    ) 
    NESTED TABLE pListRefExamens STORE AS table_pListRefExamens
    NESTED TABLE pListRefPrescriptions STORE AS table_pListRefPrescriptions
    PCTFREE 10
    TABLESPACE DATA_TS
    STORAGE ( INITIAL 2097K NEXT 1540K MINEXTENTS 1 MAXEXTENTS 3072 PCTINCREASE 0);
    /



-- Utilisation de DBMS_SPACE.CREATE_INDEX_COST  pour estimer la volumétrie des indexes.

--  Estimation pour l'indexe idx_o_patient_email_unique
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_patient_email_unique
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_patient_email_unique ON O_PATIENT(Email)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 500
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_patient_email_unique;
    CREATE UNIQUE INDEX idx_o_patient_email_unique ON O_PATIENT(Email)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 500 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

--  Estimation pour l'indexe idx_o_patient_num_sec_social_unique
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_patient_num_sec_social_unique
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_patient_num_sec_social_unique ON O_PATIENT(Numero_Securite_Sociale)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result                        
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);                                    
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 260
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_patient_num_sec_social_unique;
    CREATE UNIQUE INDEX idx_o_patient_num_sec_social_unique ON O_PATIENT(Numero_Securite_Sociale)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 260 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


--  Estimation pour l'indexe idx_o_medecin_email_unique
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_medecin_email_unique
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_medecin_email_unique ON O_MEDECIN(Email)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result    
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 230
    -- Allocated Bytes: 65536   

    DROP INDEX idx_o_medecin_email_unique;
    CREATE UNIQUE INDEX idx_o_medecin_email_unique ON O_MEDECIN(Email)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 230 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

--  Estimation pour l'indexe idx_o_medecin_num_sec_social_unique
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_medecin_num_sec_social_unique
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_medecin_num_sec_social_unique ON O_MEDECIN(Numero_Securite_Sociale)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 120    
    -- Allocated Bytes: 65536       

    DROP INDEX idx_o_medecin_num_sec_social_unique;
    CREATE UNIQUE INDEX idx_o_medecin_num_sec_social_unique ON O_MEDECIN(Numero_Securite_Sociale)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 120 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

--  Estimation pour l'indexe idx_o_medecin_specialite
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_medecin_specialite
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX idx_o_medecin_specialite ON O_MEDECIN(Specialite)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result    
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);            
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 110
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_medecin_specialite;
    CREATE INDEX idx_o_medecin_specialite ON O_MEDECIN(Specialite)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 110 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

--  Estimation pour l'indexe idx_o_facture_montant_total
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_facture_montant_total
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX idx_o_facture_montant_total ON O_FACTURE(Montant_Total)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 40
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_facture_montant_total;
    CREATE INDEX idx_o_facture_montant_total ON O_FACTURE(Montant_Total)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 40 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

--  Estimation pour l'indexe IDX_O_RENDEZ_VOUS_refPatient
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_RENDEZ_VOUS_refPatient
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_RENDEZ_VOUS_refPatient ON O_RENDEZ_VOUS(refPatient)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_RENDEZ_VOUS_refPatient;
    ALTER TABLE O_RENDEZ_VOUS ADD (SCOPE FOR (refPatient) IS O_PATIENT);
    CREATE INDEX IDX_O_RENDEZ_VOUS_refPatient ON O_RENDEZ_VOUS(refPatient)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

--  Estimation pour l'indexe IDX_O_RENDEZ_VOUS_refMedecin
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;   
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_RENDEZ_VOUS_refMedecin
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_RENDEZ_VOUS_refMedecin ON O_RENDEZ_VOUS(refMedecin)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_RENDEZ_VOUS_refMedecin;
    ALTER TABLE O_RENDEZ_VOUS ADD (SCOPE FOR (refMedecin) IS O_MEDECIN);
    CREATE INDEX IDX_O_RENDEZ_VOUS_refMedecin ON O_RENDEZ_VOUS(refMedecin)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

 -- Estimation pour l'indexe idx_o_rendez_vous_ref_patient_ref_medecin_date_unique
    DECLARE 
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_rendez_vous_ref_patient_ref_medecin_date_unique
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique ON O_RENDEZ_VOUS(refPatient, refMedecin, Date_Rendez_Vous)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result                        
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);                                    
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);          
    END;    
    /

    -- Used Bytes: 520
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique;
    CREATE UNIQUE INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique ON O_RENDEZ_VOUS(refPatient, refMedecin, Date_Rendez_Vous)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 520 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

 -- Estimation pour l'indexe IDX_O_FACTURE_refPatient
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_FACTURE_refPatient
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_FACTURE_refPatient ON O_FACTURE(refPatient)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);  

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_FACTURE_refPatient;
    ALTER TABLE O_FACTURE ADD (SCOPE FOR (refPatient) IS O_PATIENT);
    CREATE INDEX IDX_O_FACTURE_refPatient ON O_FACTURE(refPatient)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /


-- Estimation pour l'indexe IDX_O_CONSULTATION_refPatient
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_CONSULTATION_refPatient
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_CONSULTATION_refPatient ON O_CONSULTATION(refPatient)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /   

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_CONSULTATION_refPatient;
    ALTER TABLE O_CONSULTATION ADD (SCOPE FOR (refPatient) IS O_PATIENT);
    CREATE INDEX IDX_O_CONSULTATION_refPatient ON O_CONSULTATION(refPatient)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe IDX_O_CONSULTATION_refMedecin
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_CONSULTATION_refMedecin
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_CONSULTATION_refMedecin ON O_CONSULTATION(refMedecin)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /   

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_CONSULTATION_refMedecin;
    ALTER TABLE O_CONSULTATION ADD (SCOPE FOR (refMedecin) IS O_MEDECIN);
    CREATE INDEX IDX_O_CONSULTATION_refMedecin ON O_CONSULTATION(refMedecin)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique ON O_CONSULTATION(refPatient, refMedecin, Date_Consultation)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 620
    -- Allocated Bytes: 65536

    DROP INDEX idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique;
    CREATE UNIQUE INDEX idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique ON O_CONSULTATION(refPatient, refMedecin, Date_Consultation)
    TABLESPACE INDEX_TS 
    STORAGE (INITIAL 65536 NEXT 620 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

 -- Estimation pour l'indexe IDX_O_FACTURE_refConsultation
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_FACTURE_refConsultation   
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_FACTURE_refConsultation ON O_FACTURE(refConsultation)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /   

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_FACTURE_refConsultation;
    ALTER TABLE O_FACTURE ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
    CREATE INDEX IDX_O_FACTURE_refConsultation ON O_FACTURE(refConsultation)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

 -- Estimation pour l'indexe IDX_O_PRESCRIPTION_refConsultation
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_PRESCRIPTION_refConsultation
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_PRESCRIPTION_refConsultation ON O_PRESCRIPTION(refConsultation)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_PRESCRIPTION_refConsultation;
    ALTER TABLE O_PRESCRIPTION ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
    CREATE INDEX IDX_O_PRESCRIPTION_refConsultation ON O_PRESCRIPTION(refConsultation)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

 -- Estimation pour l'indexe IDX_O_EXAMEN_refConsultation
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index IDX_O_EXAMEN_refConsultation
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE INDEX IDX_O_EXAMEN_refConsultation ON O_EXAMEN(refConsultation)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 270
    -- Allocated Bytes: 65536

    DROP INDEX IDX_O_EXAMEN_refConsultation;
    ALTER TABLE O_EXAMEN ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
    CREATE INDEX IDX_O_EXAMEN_refConsultation ON O_EXAMEN(refConsultation)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 270 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value ON o_medecin_table_pListRefConsultations(Nested_table_id, Column_value)',

            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /       

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    
    DROP INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value;
    ALTER TABLE o_medecin_table_pListRefConsultations ADD (SCOPE FOR (column_value) IS O_CONSULTATION);
    CREATE UNIQUE INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value ON o_medecin_table_pListRefConsultations(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value ON o_medecin_table_pListRefRendezVous(Nested_table_id, Column_value)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value;
    ALTER TABLE o_medecin_table_pListRefRendezVous ADD (SCOPE FOR (column_value) IS O_RENDEZ_VOUS);
    CREATE UNIQUE INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value ON o_medecin_table_pListRefRendezVous(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

        
-- Estimation pour l'indexe idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value ON o_patient_table_pListRefConsultations(Nested_table_id, Column_value)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result        
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value;
    ALTER TABLE o_patient_table_pListRefConsultations ADD (SCOPE FOR (column_value) IS O_CONSULTATION);
    CREATE UNIQUE INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value ON o_patient_table_pListRefConsultations(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value ON o_patient_table_pListRefRendezVous(Nested_table_id, Column_value)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value;
    ALTER TABLE o_patient_table_pListRefRendezVous ADD (SCOPE FOR (column_value) IS O_RENDEZ_VOUS);
    CREATE UNIQUE INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value ON o_patient_table_pListRefRendezVous(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value ON o_patient_table_pListRefFactures(Nested_table_id, Column_value)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    DROP INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value;
    ALTER TABLE o_patient_table_pListRefFactures ADD (SCOPE FOR (column_value) IS O_FACTURE);
    CREATE UNIQUE INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value ON o_patient_table_pListRefFactures(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /   


-- Estimation pour l'indexe idx_table_pListRefExamens_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_table_pListRefExamens_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_table_pListRefExamens_Nested_table_id_Column_value ON table_pListRefExamens(Nested_table_id, Column_value)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    DROP INDEX idx_table_pListRefExamens_Nested_table_id_Column_value;
    ALTER TABLE table_pListRefExamens ADD (SCOPE FOR (column_value) IS O_EXAMEN);
    CREATE UNIQUE INDEX idx_table_pListRefExamens_Nested_table_id_Column_value ON table_pListRefExamens(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /

-- Estimation pour l'indexe idx_table_pListRefPrescriptions_Nested_table_id_Column_value
    DECLARE
        used_bytes    NUMBER;
        alloc_bytes   NUMBER;
    BEGIN
        -- Estimation pour l'espace de l'index idx_table_pListRefPrescriptions_Nested_table_id_Column_value
        DBMS_SPACE.CREATE_INDEX_COST (
            ddl           =>
                'CREATE UNIQUE INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value ON table_pListRefPrescriptions(Nested_table_id, Column_value)',
            used_bytes    => used_bytes,
            alloc_bytes   => alloc_bytes);

        -- Output the result
        DBMS_OUTPUT.PUT_LINE ('Used Bytes: ' || used_bytes);
        DBMS_OUTPUT.PUT_LINE ('Allocated Bytes: ' || alloc_bytes);
    END;
    /

    -- Used Bytes: 170
    -- Allocated Bytes: 65536

    DROP INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value;
    ALTER TABLE table_pListRefPrescriptions ADD (SCOPE FOR (column_value) IS O_PRESCRIPTION);
    CREATE UNIQUE INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value ON table_pListRefPrescriptions(Nested_table_id, Column_value)
    TABLESPACE INDEX_TS
    STORAGE (INITIAL 65536 NEXT 170 MINEXTENTS 1 MAXEXTENTS 2048 PCTINCREASE 0);
    /



-- 4 Insérer  pour l’instant en  moyenne  une  dizaine  de  lignes  de  test  dans  chacune 
-- des tables. 
-- <réponses et trace ici> 

        -- INSERTION DES LIGNES DANS LES TABLES OBJETS
    DELETE FROM O_PATIENT;
    DELETE FROM O_MEDECIN;
    DELETE FROM O_FACTURE;
    DELETE FROM O_CONSULTATION;
    DELETE FROM O_RENDEZ_VOUS;
    DELETE FROM O_PRESCRIPTION;
    DELETE FROM O_EXAMEN;
    COMMIT;
        
    DECLARE
        refPatient1 REF PATIENT_T; refPatient2 REF PATIENT_T; refPatient3 REF PATIENT_T; refPatient4 REF PATIENT_T; refPatient5 REF PATIENT_T; refPatient6 REF PATIENT_T; refPatient7 REF PATIENT_T; refPatient8 REF PATIENT_T; refPatient9 REF PATIENT_T; refPatient10 REF PATIENT_T; refPatient11 REF PATIENT_T; refPatient12 REF PATIENT_T; refPatient13 REF PATIENT_T; refPatient14 REF PATIENT_T; refPatient15 REF PATIENT_T; refPatient16 REF PATIENT_T; refPatient17 REF PATIENT_T; refPatient18 REF PATIENT_T; refPatient19 REF PATIENT_T; refPatient20 REF PATIENT_T; 
        refMedecin1 REF MEDECIN_T; refMedecin2 REF MEDECIN_T; refMedecin3 REF MEDECIN_T; refMedecin4 REF MEDECIN_T; refMedecin5 REF MEDECIN_T; refMedecin6 REF MEDECIN_T; refMedecin7 REF MEDECIN_T; refMedecin8 REF MEDECIN_T; refMedecin9 REF MEDECIN_T; refMedecin10 REF MEDECIN_T;    
        refRendezVous1 REF RENDEZ_VOUS_T; refRendezVous2 REF RENDEZ_VOUS_T; refRendezVous3 REF RENDEZ_VOUS_T; refRendezVous4 REF RENDEZ_VOUS_T; refRendezVous5 REF RENDEZ_VOUS_T; refRendezVous6 REF RENDEZ_VOUS_T; refRendezVous7 REF RENDEZ_VOUS_T; refRendezVous8 REF RENDEZ_VOUS_T; refRendezVous9 REF RENDEZ_VOUS_T; refRendezVous10 REF RENDEZ_VOUS_T;
        refConsultation1 REF CONSULTATION_T; refConsultation2 REF CONSULTATION_T; refConsultation3 REF CONSULTATION_T; refConsultation4 REF CONSULTATION_T; refConsultation5 REF CONSULTATION_T; refConsultation6 REF CONSULTATION_T; refConsultation7 REF CONSULTATION_T; refConsultation8 REF CONSULTATION_T; refConsultation9 REF CONSULTATION_T; refConsultation10 REF CONSULTATION_T;
        refFacture1 REF FACTURE_T; refFacture2 REF FACTURE_T; refFacture3 REF FACTURE_T; refFacture4 REF FACTURE_T; refFacture5 REF FACTURE_T; refFacture6 REF FACTURE_T; refFacture7 REF FACTURE_T; refFacture8 REF FACTURE_T; refFacture9 REF FACTURE_T; refFacture10 REF FACTURE_T;
        refExamen1 REF EXAMEN_T; refExamen2 REF EXAMEN_T; refExamen3 REF EXAMEN_T; refExamen4 REF EXAMEN_T; refExamen5 REF EXAMEN_T; refExamen6 REF EXAMEN_T; refExamen7 REF EXAMEN_T; refExamen8 REF EXAMEN_T; refExamen9 REF EXAMEN_T; refExamen10 REF EXAMEN_T;
        refPrescription1 REF PRESCRIPTION_T; refPrescription2 REF PRESCRIPTION_T; refPrescription3 REF PRESCRIPTION_T; refPrescription4 REF PRESCRIPTION_T; refPrescription5 REF PRESCRIPTION_T; refPrescription6 REF PRESCRIPTION_T; refPrescription7 REF PRESCRIPTION_T; refPrescription8 REF PRESCRIPTION_T; refPrescription9 REF PRESCRIPTION_T; refPrescription10 REF PRESCRIPTION_T;
    BEGIN	 
    -- INSERTION DES PATIENTS
        INSERT INTO O_PATIENT OP 
        VALUES(PATIENT_T(1, '12345678901', 'Doe', 'john.doe@gmail.com', ADRESSE_T(1, 'Main St', 75001, 'PARIS'), 'Masculin', TO_DATE('12/05/1985', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0612345678', '0654321098'), LIST_PRENOMS_T('John', 'Michael'), 75, 180, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient1;

        INSERT INTO O_PATIENT OP  
        VALUES(PATIENT_T(2, '98765432101', 'Smith', 'jane.smith@yahoo.com', ADRESSE_T(2, 'Rue de Rivoli', 75004, 'PARIS'), 'Feminin', TO_DATE('08/03/1990', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0698765432', '0643210987'), LIST_PRENOMS_T('Jane', 'Elizabeth'), 65, 170, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient2;

        INSERT INTO O_PATIENT OP 
        VALUES(PATIENT_T(3, '11112222333', 'Johnson', 'michael.johnson@outlook.com', ADRESSE_T(3, 'Avenue des Champs-Elysees', 75008, 'PARIS'), 'Autre', TO_DATE('15/11/1978', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0678901234', '0687654321'), LIST_PRENOMS_T('Michael', 'Andrew'), 85, 175, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient3;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(4, '22223333444', 'Williams', 'will.williams@hotmail.com', ADRESSE_T(4, 'Boulevard Saint-Germain', 75005, 'PARIS'), 'Masculin', TO_DATE('22/06/1982', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0690123456', '0610987654'), LIST_PRENOMS_T('William', 'James'), 80, 182, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient4;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(5, '33334444555', 'Brown', 'chris.brown@live.com', ADRESSE_T(5, 'Rue Montorgueil', 75002, 'PARIS'), 'Masculin', TO_DATE('30/01/1992', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0687654321', '0632109876'), LIST_PRENOMS_T('Chris', 'David'), 78, 177, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient5;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(6, '44445555666', 'Jones', 'emma.jones@gmail.com', ADRESSE_T(6, 'Rue de la Banque', 75002, 'PARIS'), 'Feminin', TO_DATE('12/12/1994', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0623456789', '0676543210'), LIST_PRENOMS_T('Emma', 'Marie'), 60, 165, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient6;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(7, '55556666777', 'Garcia', 'lucas.garcia@wanadoo.fr', ADRESSE_T(7, 'Rue de Vaugirard', 75006, 'PARIS'), 'Masculin', TO_DATE('05/04/1988', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0699988776', '0621345678'), LIST_PRENOMS_T('Lucas', 'Daniel'), 85, 185, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient7;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(8, '66667777888', 'Miller', 'olivia.miller@free.fr', ADRESSE_T(8, 'Avenue de la République', 75011, 'PARIS'), 'Feminin', TO_DATE('19/09/1993', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0611122233', '0677899001'), LIST_PRENOMS_T('Olivia', 'Claire'), 55, 160, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient8;
        
        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(9, '77778888999', 'Martinez', 'maria.martinez@orange.fr', ADRESSE_T(9, 'Rue de Rennes', 75006, 'PARIS'), 'Feminin', TO_DATE('07/07/1991', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0622233444', '0645566778'), LIST_PRENOMS_T('Maria', 'Isabella'), 70, 170, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient9;
        
        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(10, '99990000181', 'Martinez', 'sofia.martinez@laposte.net', ADRESSE_T(21, 'Avenue des Ternes', 75017, 'PARIS'), 'Feminin', TO_DATE('15/05/1992', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0622334455', '0677889900'), LIST_PRENOMS_T('Sofia', 'Gabrielle'), 60, 165, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient10;
        
        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(11, '99990000111', 'Wilson', 'sophie.wilson@laposte.net', ADRESSE_T(11, 'Rue du Faubourg Saint-Antoine', 75011, 'PARIS'), 'Autre', TO_DATE('26/11/1986', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0645566778', '0612345678'), LIST_PRENOMS_T('Sophie', 'Anne'), 62, 167, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient11;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(12, '00006111222', 'Anderson', 'julia.anderson@orange.fr', ADRESSE_T(12, 'Rue Oberkampf', 75011, 'PARIS'), 'Feminin', TO_DATE('03/03/1995', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0633445566', '0655443322'), LIST_PRENOMS_T('Julia', 'Rose'), 68, 169, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient12;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(13, '19188222339', 'Thomas', 'jacob.thomas@gmail.com', ADRESSE_T(13, 'Rue de la Pompe', 75016, 'PARIS'), 'Autre', TO_DATE('18/10/1983', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0622334455', '0644556677'), LIST_PRENOMS_T('Jacob', 'Matthew'), 77, 173, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient13;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(14, '42493313444', 'Taylor', 'elizabeth.taylor@hotmail.com', ADRESSE_T(14, 'Boulevard de Courcelles', 75017, 'PARIS'), 'Feminin', TO_DATE('27/07/1989', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0677889900', '0633221100'), LIST_PRENOMS_T('Elizabeth', 'Grace'), 70, 172, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient14;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(15, '332334444555', 'Moore', 'daniel.moore@wanadoo.fr', ADRESSE_T(15, 'Rue du Bac', 75007, 'PARIS'), 'Masculin', TO_DATE('15/09/1990', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0621345678', '0611122233'), LIST_PRENOMS_T('Daniel', 'Patrick'), 90, 185, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient15;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(16, '44445559996', 'Jackson', 'amy.jackson@gmail.com', ADRESSE_T(16, 'Boulevard Voltaire', 75011, 'PARIS'), 'Feminin', TO_DATE('24/06/1987', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0655443322', '0611122233'), LIST_PRENOMS_T('Amy', 'Louise'), 62, 164, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient16;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(17, '55777666777', 'Harris', 'ryan.harris@laposte.net', ADRESSE_T(17, 'Rue Saint-Antoine', 75004, 'PARIS'), 'Masculin', TO_DATE('13/01/1985', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0612345678', '0687654321'), LIST_PRENOMS_T('Ryan', 'ChristOPher'), 85, 180, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient17;
        
        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(18, '66667777668', 'Martin', 'chloe.martin@orange.fr', ADRESSE_T(18, 'Rue de la Pompe', 75016, 'PARIS'), 'Autre', TO_DATE('21/04/1991', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0623456789', '0698765432'), LIST_PRENOMS_T('Chloe', 'SOPhia'), 57, 162, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient18;

        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(19, '88889999000', 'Thompson', 'luke.thompson@free.fr', ADRESSE_T(20, 'Rue du Faubourg Saint-Denis', 75010, 'PARIS'), 'Masculin', TO_DATE('12/09/1984', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0633445566', '0611223344'), LIST_PRENOMS_T('Luke', 'Alexander'), 88, 180, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient19;
        
        INSERT INTO O_PATIENT OP
        VALUES(PATIENT_T(20, '97300000111', 'Martinez', 'sofiane.martinez@laposte.net', ADRESSE_T(21, 'Avenue des Ternes', 75017, 'PARIS'), 'Autre', TO_DATE('15/05/1992', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0622334455', '0677889900'), LIST_PRENOMS_T('Sofiane', 'Gabrielle'), 60, 165, ListRefRendezVous_t(), ListRefConsultations_t(), ListRefFactures_t())) 
        RETURNING REF(OP) INTO refPatient20;
        
    -- INSERTION DES MEDECINS
        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(1, '12345678901', 'Doe', 'john.doe@gmail.com', ADRESSE_T(1, 'Main St', 75001, 'PARIS'), 'Masculin', TO_DATE('12/05/1985', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0612345678', '0654321098'), LIST_PRENOMS_T('John', 'Michael'), 'Urologue', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin1;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(2, '23456789012', 'Smith', 'jane.smith@gmail.com', ADRESSE_T(2, 'Rue de Rivoli', 75004, 'PARIS'), 'Feminin', TO_DATE('23/08/1979', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0611122233', '0677654321'), LIST_PRENOMS_T('Jane', 'Elizabeth'), 'Gynecologue', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin2;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(3, '34567890123', 'Brown', 'will.brown@hotmail.com', ADRESSE_T(3, 'Avenue Montaigne', 75008, 'PARIS'), 'Masculin', TO_DATE('17/02/1980', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0633445566', '0688776655'), LIST_PRENOMS_T('William', 'Andrew'), 'Interniste', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin3;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(4, '45678901234', 'Jones', 'claire.jones@yahoo.fr', ADRESSE_T(4, 'Boulevard Saint-Germain', 75005, 'PARIS'), 'Feminin', TO_DATE('05/11/1975', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0622334455', '0699887766'), LIST_PRENOMS_T('Claire', 'Marie'), 'Cardiologue', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin4;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(5, '56789012345', 'Garcia', 'carlos.garcia@outlook.com', ADRESSE_T(5, 'Avenue des Champs-Élysées', 75008, 'PARIS'), 'Masculin', TO_DATE('15/09/1982', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0677889900', '0655443322'), LIST_PRENOMS_T('Carlos', 'Javier'), 'Pediatre', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin5;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(6, '67890123456', 'Miller', 'emma.miller@gmail.com', ADRESSE_T(6, 'Place de la Concorde', 75008, 'PARIS'), 'Feminin', TO_DATE('22/06/1990', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0611223344', '0677990011'), LIST_PRENOMS_T('Emma', 'Charlotte'), 'Chirurgien', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin6;
        
        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(7, '22334455667', 'Lopez', 'marc.lopez@gmail.com', ADRESSE_T(11, 'Rue de Rennes', 75006, 'PARIS'), 'Masculin', TO_DATE('11/02/1978', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0612456789', '0666778899'), LIST_PRENOMS_T('Marc', 'Pierre'), 'Chirurgien', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin7;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(8, '33445566778', 'Dubois', 'anne.dubois@hotmail.fr', ADRESSE_T(12, 'Boulevard Haussmann', 75008, 'PARIS'), 'Feminin', TO_DATE('09/10/1989', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0622334455', '0655447788'), LIST_PRENOMS_T('Anne', 'Julie'), 'Gynecologue', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin8;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(9, '44556677889', 'Nguyen', 'paul.nguyen@wanadoo.fr', ADRESSE_T(13, 'Avenue Victor Hugo', 75116, 'PARIS'), 'Masculin', TO_DATE('22/11/1980', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0688776655', '0622445566'), LIST_PRENOMS_T('Paul', 'Jean'), 'Interniste', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin9;

        INSERT INTO O_MEDECIN OM
        VALUES(MEDECIN_T(10, '55667788990', 'Bernard', 'lucie.bernard@sfr.fr', ADRESSE_T(14, 'Rue du Faubourg Saint-Honoré', 75008, 'PARIS'), 'Feminin', TO_DATE('06/04/1983', 'DD/MM/YYYY'), LIST_TELEPHONES_T('0644332211', '0611223344'), LIST_PRENOMS_T('Lucie', 'Catherine'), 'Pediatre', NULL, ListRefRendezVous_t(), ListRefConsultations_t())) 
        RETURNING REF(OM) INTO refMedecin10;
    
    -- INSERTION DES RENDEZ_VOUS   
        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(1, refPatient1, refMedecin3, TO_DATE('12/01/2024', 'DD/MM/YYYY'), 'Routine check-up'))
        RETURNING REF(ORV) INTO refRendezVous1;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(2, refPatient2, refMedecin5, TO_DATE('15/01/2024', 'DD/MM/YYYY'), 'Follow-up on previous consultation'))
        RETURNING REF(ORV) INTO refRendezVous2;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(3, refPatient3, refMedecin2, TO_DATE('18/01/2024', 'DD/MM/YYYY'), 'Discuss test results'))
        RETURNING REF(ORV) INTO refRendezVous3;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(4, refPatient4, refMedecin4, TO_DATE('22/01/2024', 'DD/MM/YYYY'), 'General consultation'))
        RETURNING REF(ORV) INTO refRendezVous4;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(5, refPatient5, refMedecin1, TO_DATE('25/01/2024', 'DD/MM/YYYY'), 'Specialist referral'))
        RETURNING REF(ORV) INTO refRendezVous5;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(6, refPatient6, refMedecin6, TO_DATE('28/01/2024', 'DD/MM/YYYY'), 'Prescription renewal'))
        RETURNING REF(ORV) INTO refRendezVous6;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(7, refPatient7, refMedecin8, TO_DATE('30/01/2024', 'DD/MM/YYYY'), 'Vaccination consultation'))
        RETURNING REF(ORV) INTO refRendezVous7;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(8, refPatient8, refMedecin7, TO_DATE('02/02/2024', 'DD/MM/YYYY'), 'Pediatric consultation'))
        RETURNING REF(ORV) INTO refRendezVous8;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(11, refPatient11, refMedecin4, TO_DATE('12/02/2024', 'DD/MM/YYYY'), 'Annual physical examination'))
        RETURNING REF(ORV) INTO refRendezVous9;

        INSERT INTO O_RENDEZ_VOUS ORV VALUES(RENDEZ_VOUS_T(12, refPatient12, refMedecin2, TO_DATE('15/02/2024', 'DD/MM/YYYY'), 'Post-operative follow-up'))
        RETURNING REF(ORV) INTO refRendezVous10;
        
        -- MISE A JOUR DES LISTES DES RENDEZ-VOUS
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient1) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient1;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient2) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient2;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient3) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient3;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient4) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient4;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient5) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient5;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient6) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient6;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient7) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient7;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient8) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient8;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient9) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient9;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient10) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient10;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient11) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient11;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient12) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient12;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient13) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient13;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient14) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient14;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient15) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient15;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient16) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient16;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient17) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient17;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient18) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient18;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient19) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient19;
        INSERT INTO TABLE(SELECT OP.PLISTREFRENDEZVOUS FROM O_PATIENT OP WHERE REF(OP)=refPatient20) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refPatient = refPatient20;
        
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin1) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin1;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin2) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin2;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin3) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin3;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin4) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin4;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin5) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin5;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin6) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin6;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin7) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin7;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin8) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin8;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin9) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin9;
        INSERT INTO TABLE(SELECT OM.PLISTREFRENDEZVOUS FROM O_MEDECIN OM WHERE REF(OM)=refMedecin10) SELECT REF(ORV) FROM O_RENDEZ_VOUS ORV WHERE ORV.refMedecin = refMedecin10;

        -- INSERTION DES CONSULTATIONS
        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(1, refPatient1, refMedecin2, 'Routine check-up', 'Good health', TO_DATE('01/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation1;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(2, refPatient2, refMedecin3, 'Chest pain', 'Mild angina', TO_DATE('03/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation2;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(3, refPatient3, refMedecin4, 'Headache', 'Tension headache', TO_DATE('05/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation3;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(4, refPatient4, refMedecin5, 'Fever and cough', 'Viral infection', TO_DATE('07/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation4;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(5, refPatient5, refMedecin6, 'Stomach pain', 'Gastritis', TO_DATE('09/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation5;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(6, refPatient6, refMedecin1, 'Back pain', 'Muscle strain', TO_DATE('11/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation6;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(7, refPatient7, refMedecin2, 'Follow-up after surgery', 'Recovering well', TO_DATE('13/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation7;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(8, refPatient8, refMedecin3, 'Skin rash', 'Allergic reaction', TO_DATE('15/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation8;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(9, refPatient9, refMedecin4, 'Joint pain', 'Arthritis', TO_DATE('17/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation9;

        INSERT INTO O_CONSULTATION OC VALUES(CONSULTATION_T(10, refPatient10, refMedecin5, 'Shortness of breath', 'Asthma', TO_DATE('19/01/2024', 'DD/MM/YYYY'), ListRefExamens_t(), ListRefPrescriptions_t()))
        RETURNING REF(OC) INTO refConsultation10;
        
        -- MISE A JOUR DES LISTES DES CONSULTATIONS
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient1) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient1;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient2) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient2;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient3) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient3;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient4) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient4;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient5) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient5;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient6) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient6;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient7) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient7;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient8) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient8;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient9) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient9;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient10) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient10;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient11) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient11;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient12) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient12;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient13) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient13;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient14) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient14;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient15) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient15;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient16) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient16;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient17) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient17;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient18) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient18;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient19) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient19;
        INSERT INTO TABLE(SELECT OP.pListRefConsultations FROM O_PATIENT OP WHERE REF(OP)=refPatient20) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refPatient = refPatient20;
        
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin1) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin1;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin2) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin2;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin3) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin3;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin4) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin4;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin5) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin5;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin6) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin6;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin7) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin7;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin8) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin8;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin9) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin9;
        INSERT INTO TABLE(SELECT OM.pListRefConsultations FROM O_MEDECIN OM WHERE REF(OM)=refMedecin10) SELECT REF(OC) FROM O_CONSULTATION OC WHERE OC.refMedecin = refMedecin10;

        
    -- INSERTION DES FACTURES
        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(1, refPatient1, refConsultation3, 95.8, TO_DATE('19/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture1;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(2, refPatient2, refConsultation1, 120.0, TO_DATE('20/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture2;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(3, refPatient3, refConsultation2, 80.5, TO_DATE('21/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture3;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(4, refPatient4, refConsultation4, 150.0, TO_DATE('22/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture4;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(5, refPatient5, refConsultation5, 60.0, TO_DATE('23/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture5;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(6, refPatient6, refConsultation6, 200.0, TO_DATE('24/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture6;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(7, refPatient7, refConsultation7, 130.75, TO_DATE('25/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture7;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(8, refPatient8, refConsultation8, 110.0, TO_DATE('26/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture8;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(9, refPatient9, refConsultation9, 90.25, TO_DATE('27/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture9;

        INSERT INTO O_FACTURE OFA VALUES(FACTURE_T(10, refPatient10, refConsultation10, 105.5, TO_DATE('28/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OFA) INTO refFacture10;
        
        -- MISE A JOUR DES LISTES DES FACTURES
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient1) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient1;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient2) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient2;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient3) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient3;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient4) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient4;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient5) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient5;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient6) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient6;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient7) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient7;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient8) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient8;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient9) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient9;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient10) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient10;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient11) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient11;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient12) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient12;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient13) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient13;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient14) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient14;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient15) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient15;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient16) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient16;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient17) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient17;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient18) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient18;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient19) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient19;
        INSERT INTO TABLE(SELECT OP.pListRefFactures FROM O_PATIENT OP WHERE REF(OP)=refPatient20) SELECT REF(OFA) FROM O_FACTURE OFA WHERE OFA.refPatient = refPatient20;
        
        
        -- INSERTION DES EXAMENS	
        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(1, refConsultation3, 'Blood Test', TO_DATE('28/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen1;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(2, refConsultation1, 'X-Ray Examination', TO_DATE('29/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen2;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(3, refConsultation2, 'MRI Scan', TO_DATE('30/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen3;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(4, refConsultation4, 'Ultrasound', TO_DATE('31/01/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen4;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(5, refConsultation5, 'Echocardiogram', TO_DATE('01/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen5;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(6, refConsultation6, 'CT Scan', TO_DATE('02/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen6;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(7, refConsultation7, 'Endoscopy', TO_DATE('03/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen7;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(8, refConsultation8, 'Colonoscopy', TO_DATE('04/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen8;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(9, refConsultation9, 'Electrocardiogram (ECG)', TO_DATE('05/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen9;

        INSERT INTO O_EXAMEN OE VALUES(EXAMEN_T(10, refConsultation10, 'Liver Function Test', TO_DATE('06/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OE) INTO refExamen10;
        
        -- MISE A JOUR DES LISTES DES EXAMENS
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation1) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation1;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation2) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation2;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation3) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation3;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation4) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation4;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation5) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation5;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation6) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation6;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation7) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation7;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation8) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation8;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation9) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation9;
        INSERT INTO TABLE(SELECT OC.pListRefExamens FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation10) SELECT REF(OE) FROM O_EXAMEN OE WHERE OE.refConsultation = refConsultation10;
        
    
        -- INSERTION DES PRESCRIPTIONS	
        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(1, refConsultation1, 'Take 1 tablet of Aspirin daily', TO_DATE('01/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription1;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(2, refConsultation2, 'Apply ointment twice daily', TO_DATE('02/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription2;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(3, refConsultation3, 'Rest and avoid strenuous activities', TO_DATE('03/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription3;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(4, refConsultation4, 'Take 2 tablets of Amoxicillin every 8 hours', TO_DATE('04/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription4;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(5, refConsultation5, 'Use inhaler as needed', TO_DATE('05/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription5;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(6, refConsultation6, 'Follow a low-sodium diet', TO_DATE('06/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription6;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(7, refConsultation7, 'Wear compression stockings', TO_DATE('07/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription7;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(8, refConsultation8, 'Take 1 tablet of Metformin with breakfast', TO_DATE('08/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription8;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(9, refConsultation9, 'Apply ice pack to the affected area twice daily', TO_DATE('09/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription9;

        INSERT INTO O_PRESCRIPTION OPR VALUES(PRESCRIPTION_T(10, refConsultation10, 'Avoid alcohol consumption', TO_DATE('10/02/2024', 'DD/MM/YYYY')))
        RETURNING REF(OPR) INTO refPrescription10;
        
        -- MISE A JOUR DES LISTES DES PRESCRIPTIONS
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation1) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation1;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation2) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation2;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation3) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation3;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation4) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation4;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation5) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation5;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation6) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation6;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation7) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation7;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation8) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation8;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation9) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation9;
        INSERT INTO TABLE(SELECT OC.pListRefPrescriptions FROM O_CONSULTATION OC WHERE REF(OC)=refConsultation10) SELECT REF(OP) FROM O_PRESCRIPTION OP WHERE OP.refConsultation = refConsultation10;	
    END;
    /

    COMMIT;
-- <réponses et trace ici>
    -- 0 rows deleted.
    -- 0 rows deleted.
    -- 0 rows deleted.
    -- 0 rows deleted.
    -- 0 rows deleted.
    -- 0 rows deleted.
    -- 0 rows deleted.
    -- Commit complete.
    -- PL/SQL procedure successfully completed.
    -- Commit complete.



-- 4.2  Chargement  des  données  avec  Sqlloader  (voir  le  chap.  7  du  cours 
-- DBA1) 
 
-- Ecrire un script (fichier de contrôle SQLLOADER) qui permet de charger les lignes 
-- contenues dans un fichier CSV (ligne à construire dans EXCEL) vers une ou plusieurs de vos 
-- tables.  Les  données  sont  à  préparer  auparavant.  Vous  pouvez  vous  appuyez  sur  des  sites  de 
-- génération automatique des données. 
-- <réponses et trace ici>

    sqlldr hopital/pass123$@hopital control=C:\Users\pbobc\Documents\PATIENT.ctl

    -- control file SCRIPT
/*
    LOAD DATA
    INFILE 'C:\workspaceSQL\patient_data.csv'
    BADFILE 'C:\workspaceSQL\PATIENT.BAD'
    APPEND INTO TABLE PATIENT
    Fields terminated by "#" Optionally enclosed by '"'
    (
    ID_PATIENT_ NULLIF (ID_PATIENT_="NULL"),
    NOM,
    PRENOM,
    ADRESSE,
    EMAIL,
    DATE_NAISSAINCE DATE "MM/DD/YYYY HH24:MI:SS" NULLIF (DATE_NAISSAINCE="NULL")
    )
*/
    -- Patients csv data loaded.

/*
    1#"Dubois"#"Alice"#"123 Rue de la Paix"#"alice.dubois@email.com"#"05/15/1990 00:00:00"
    2#"Leclerc"#"Thomas"#"456 Avenue des Roses"#"thomas.leclerc@email.com"#"08/22/1985 00:00:00"
    3#"Moreau"#"Sophie"#"789 Boulevard du Soleil"#"sophie.moreau@email.com"#"02/10/1995 00:00:00"
    4#"Leroy"#"Jean"#"101 Rue de la Lune"#"jean.leroy@email.com"#"12/01/1980 00:00:00"
    5#"Girard"#"Isabelle"#"202 Avenue des ?toiles"#"isabelle.girard@email.com"#"09/18/1992 00:00:00"
    6#"Bertrand"#"Luc"#"303 Boulevard de la Galaxie"#"luc.bertrand@email.com"#"04/25/1987 00:00:00"
    7#"Lemoine"#"Sophie"#"404 Rue des Plan?tes"#"sophie.lemoine@email.com"#"07/03/1998 00:00:00"
    8#"Roy"#"Pierre"#"505 Avenue de la Voie Lact?e"#"pierre.roy@email.com"#"10/12/1983 00:00:00"
    9#"Moulin"#"Caroline"#"606 Boulevard des Com?tes"#"caroline.moulin@email.com"#"03/28/1994 00:00:00"
    10#"Marchand"#"Alexandre"#"707 Rue des Ast?ro?des"#"alexandre.marchand@email.com"#"06/15/1988 00:00:00"
    11#"Dubois"#"Sophie"#"123 Rue de la Paix"#"sophie.dubois@email.com"#"03/22/1990 00:00:00"
    12#"Lefebvre"#"Pierre"#"456 Avenue des Champs-lys‚es"#"pierre.lefebvre@email.com"#"11/10/1985 00:00:00"
    13#"Martin"#"Charlotte"#"789 Boulevard Voltaire"#"charlotte.martin@email.com"#"09/28/1995 00:00:00"
    14#"Thomas"#"Luc"#"1010 Rue de Rivoli"#"luc.thomas@email.com"#"07/17/1977 00:00:00"
    15#"Garcia"#"Maria"#"222 Rue du Faubourg Saint-Honor‚"#"maria.garcia@email.com"#"12/03/1983 00:00:00"
    16#"Legrand"#"Jean"#"333 Avenue Montaigne"#"jean.legrand@email.com"#"05/20/1992 00:00:00"
    17#"Moreau"#"Isabelle"#"444 Boulevard Haussmann"#"isabelle.moreau@email.com"#"08/12/1979 00:00:00"
    18#"Petit"#"Philippe"#"555 Rue de la Libert‚"#"philippe.petit@email.com"#"04/25/1989 00:00:00"
    19#"Sanchez"#"Carlos"#"666 Avenue Foch"#"carlos.sanchez@email.com"#"02/09/1980 00:00:00"
    20#"Robert"#"milie"#"777 Boulevard des Capucines"#"emilie.robert@email.com"#"10/15/1993 00:00:00"
*/

 -- resultat du script SQLLOADER lance. 
 /*
    Microsoft Windows [Version 10.0.26100.2033]
    (c) Microsoft Corporation. All rights reserved.

    C:\Users\pbobc>
    C:\Users\pbobc>sqlldr hopital/pass123$@xepdb1 control=C:\workspaceSQL\patient.ctl log=C:\workspaceSQL\patient.log

    SQL*Loader: Release 18.0.0.0.0 - Production on Tue Oct 22 18:08:17 2024
    Version 18.4.0.0.0

    Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

    Path used:      Conventional
    Commit point reached - logical record count 20

    Table PATIENT:
    20 Rows successfully loaded.

    Check the log file:
    C:\workspaceSQL\patient.log
    for more information about the load.
*/


-- 4.3  Divers requêtes d’administration 
    -- 1) Ecrire une requête  SQL  qui  permet  de  visualiser  l’ensemble  des  fichiers  qui 
    -- composent votre base 
    -- <réponses et trace ici>

    -- Data files
    SET PAGESIZE 2000
    SET LINES 700
    COL FILE_TYPE FORMAT A15
    COL FFILE_NAME FORMAT A100
    SELECT 'Data File' AS file_type, name AS file_name
    FROM v$datafile
    UNION
    -- Control files
    SELECT 'Control File' AS file_type, name AS file_name
    FROM v$controlfile
    UNION
    -- Redo log files
    SELECT 'Redo Log File' AS file_type, member AS file_name
    FROM v$logfile
    UNION
    -- Temporary files
    SELECT 'Temp File' AS file_type, name AS file_name
    FROM v$tempfile;

    -- <réponses et trace ici>
    -- FILE_TYPE       FILE_NAME                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    -- --------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Control File    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\CONTROL01.CTL                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    -- Control File    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\CONTROL02.CTL                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
    -- Data File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_DATA_TS.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                           
    -- Data File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_INDEX_TS.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    -- Data File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSAUX01.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    -- Data File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSTEM01.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    -- Data File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\UNDOTBS01.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    -- Data File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\USERS01.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
    -- Redo Log File   C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO01.LOG                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    -- Redo Log File   C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO02.LOG                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    -- Redo Log File   C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO03.LOG                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    -- Temp File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\TEMP012023-01-19_18-09-42-490-PM.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                           
    -- Temp File       C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\TEMPFILE_TEMP_TS.DBF                                                                                                                                                                                                                                                                                                                                                                                                                                                           

    -- 13 rows selected.

    -- 2)Ecrire  une  requête  SQL  qui  permet  de  lister  en  une  requête  l’ensembles  des 
    -- tablespaces avec leur fichiers. La taille de chaque fichier doit apparaître,  le volume 
    -- total de l’espace occupé par fichier ainsi que le volume total de l’espace libre par 
    -- fichier 

    /* Formatted on 03/10/2024 12:14:30 (QP5 v5.360) */
    SET PAGESIZE 500
    SET LINESIZE 600
    COL tablespace_name FORMAT A15
    COL FFILE_NAME FORMAT A30
    COL file_size_mb FORMAT A15
    COL used_space_mb FORMAT A15
    COL free_space_mb FORMAT A15
    SELECT df.tablespace_name,
            df.file_name,
            df.bytes / 1024 / 1024                               AS file_size_mb,
            (df.bytes - NVL (fs.free_bytes, 0)) / 1024 / 1024    AS used_space_mb,
            NVL (fs.free_bytes, 0) / 1024 / 1024                 AS free_space_mb
        FROM dba_data_files df
            LEFT JOIN (  SELECT file_id, SUM (bytes) AS free_bytes
                            FROM dba_free_space
                        GROUP BY file_id) fs
                ON df.file_id = fs.file_id
    ORDER BY df.tablespace_name, df.file_name;

    --     TABLESPACE_NAME FILE_NAME                                                                     FILE_SIZE_MB   USED_SPACE_MB   FREE_SPACE_MB
    -- --------------- ---------------------------------------------------------------------------- --------------- --------------- ---------------
    -- DATA_TS         C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_DATA_TS.DBF        		100         10.1875         89.8125
    -- INDEX_TS        C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_INDEX_TS.DBF             100               1              99
    -- SYSAUX          C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSAUX01.DBF                      400        376.3125         23.6875
    -- SYSTEM          C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSTEM01.DBF                      260        256.3125          3.6875
    -- UNDOTBS1        C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\UNDOTBS01.DBF                     100          49.125          50.875
    -- USERS           C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\USERS01.DBF                         5             1.5             3.5

    -- 6 rows selected.



    
    --     3) Ecrire  une  requête  SQL  qui  permet  de  lister  les  segments  et  leurs  extensions  de 
    -- chacun des segments (tables ou indexes) de votre utilisateur 
    -- <réponses et trace ici>

    /* Formatted on 03/10/2024 12:03:32 (QP5 v5.360) */
    SET PAGESIZE 500
    SET LINESIZE 300
    SELECT s.segment_name,
            s.segment_type,
            s.tablespace_name,
            e.extent_id,
            e.file_id,
            e.block_id,
            e.bytes / 1024 / 1024     AS extent_size_mb
        FROM dba_segments s
            JOIN dba_extents e
                ON s.segment_name = e.segment_name AND s.owner = e.owner
    WHERE s.owner = UPPER ('Hopital')
    ORDER BY s.segment_name, e.extent_id;

        
    -- SEGMENT_NAME                                                                                                                     SEGMENT_TYPE       TABLESPACE_NAME                 EXTENT_ID    FILE_ID   BLOCK_ID EXTENT_SIZE_MB
    -- -------------------------------------------------------------------------------------------------------------------------------- ------------------ ------------------------------ ---------- ---------- ---------- --------------
    -- IDX_O_CONSULTATION_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                                                                           INDEX              USERS                                   0         16        168          .0625
    -- IDX_O_FACTURE_MONTANT_TOTAL                                                                                                      INDEX              USERS                                   0         16        176          .0625
    -- IDX_O_MEDECIN_EMAIL_UNIQUE                                                                                                       INDEX              USERS                                   0         16        160          .0625
    -- IDX_O_MEDECIN_NUM_SEC_SOCIAL_UNIQUE                                                                                              INDEX              USERS                                   0         16        152          .0625
    -- IDX_O_MEDECIN_SPECIALITE                                                                                                         INDEX              USERS                                   0         16        144          .0625
    -- IDX_O_PATIENT_EMAIL_UNIQUE                                                                                                       INDEX              USERS                                   0         16        136          .0625
    -- IDX_O_PATIENT_NUM_SEC_SOCIAL_UNIQUE                                                                                              INDEX              USERS                                   0         16        128          .0625
    -- IDX_TABLE_PLISTREFPRESCRIPTIONS_NESTED_TABLE_ID_COLUMN_VALUE                                                                     INDEX              USERS                                   0         16        184          .0625
    -- O_CONSULTATION                                                                                                                   TABLE              DATA_TS                                 0         19        640              1
    -- O_CONSULTATION                                                                                                                   TABLE              DATA_TS                                 1         19        768              1
    -- O_CONSULTATION                                                                                                                   TABLE              DATA_TS                                 2         19        896              1
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 0         19       1032          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 1         19       1040          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 2         19       1048          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 3         19       1056          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 4         19       1064          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 5         19       1072          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 6         19       1080          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 7         19       1088          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 8         19       1096          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 9         19       1104          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                10         19       1112          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                11         19       1120          .0625
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                12         19       1128          .0625
    -- O_FACTURE                                                                                                                        TABLE              DATA_TS                                 0         19        584          .0625
    -- O_FACTURE                                                                                                                        TABLE              DATA_TS                                 1         19        592          .0625
    -- O_FACTURE                                                                                                                        TABLE              DATA_TS                                 2         19        600          .0625
    -- O_FACTURE                                                                                                                        TABLE              DATA_TS                                 3         19        608          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 0         19        240          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 1         19        248          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 2         19        256          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 3         19        264          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 4         19        272          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 5         19        280          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 6         19        288          .0625
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                 7         19        296          .0625
    -- O_MEDECIN_TABLE_PLISTREFCONSULTATIONS                                                                                            NESTED TABLE       DATA_TS                                 0         19        568          .0625
    -- O_MEDECIN_TABLE_PLISTREFRENDEZVOUS                                                                                               NESTED TABLE       DATA_TS                                 0         19        504          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 0         19        128          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 1         19        136          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 2         19        144          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 3         19        152          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 4         19        160          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 5         19        168          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 6         19        176          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 7         19        184          .0625
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                 8         19        192          .0625
    -- O_PATIENT_TABLE_PLISTREFCONSULTATIONS                                                                                            NESTED TABLE       DATA_TS                                 0         19        552          .0625
    -- O_PATIENT_TABLE_PLISTREFFACTURES                                                                                                 NESTED TABLE       DATA_TS                                 0         19        632          .0625
    -- O_PATIENT_TABLE_PLISTREFRENDEZVOUS                                                                                               NESTED TABLE       DATA_TS                                 0         19        488          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 0         19       1168          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 1         19       1176          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 2         19       1184          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 3         19       1192          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 4         19       1200          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 5         19       1208          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 6         19       1216          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 7         19       1224          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 8         19       1232          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 9         19       1240          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                10         19       1248          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                11         19       1256          .0625
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                12         19       1264          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 0         19        360          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 1         19        368          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 2         19        376          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 3         19        384          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 4         19        392          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 5         19        400          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 6         19        408          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 7         19        416          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 8         19        424          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 9         19        432          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                10         19        440          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                11         19        448          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                12         19        456          .0625
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                13         19        464          .0625
    -- PK_O_CONSULTATION_ID_CONSULTATION                                                                                                INDEX              DATA_TS                                 0         19        544          .0625
    -- PK_O_EXAMEN_ID_EXAMEN                                                                                                            INDEX              DATA_TS                                 0         19       1144          .0625
    -- PK_O_FACTURE_ID_FACTURE                                                                                                          INDEX              DATA_TS                                 0         19        624          .0625
    -- PK_O_MEDECIN_ID_PERSONNE                                                                                                         INDEX              DATA_TS                                 0         19        328          .0625
    -- PK_O_PATIENT_ID_PERSONNE                                                                                                         INDEX              DATA_TS                                 0         19        232          .0625
    -- PK_O_PRESCRIPTION_ID_PRESCRIPTION                                                                                                INDEX              DATA_TS                                 0         19       1280          .0625
    -- PK_O_RENDEZ_VOUS_ID_RENDEZ_VOUS                                                                                                  INDEX              DATA_TS                                 0         19        480          .0625
    -- STORECV                                                                                                                          LOBSEGMENT         DATA_TS                                 0         19        336           .125
    -- SYS_C007459                                                                                                                      INDEX              DATA_TS                                 0         19        224          .0625
    -- SYS_C007460                                                                                                                      INDEX              DATA_TS                                 0         19        216          .0625
    -- SYS_C007461                                                                                                                      INDEX              DATA_TS                                 0         19        208          .0625
    -- SYS_C007462                                                                                                                      INDEX              DATA_TS                                 0         19        200          .0625
    -- SYS_C007472                                                                                                                      INDEX              DATA_TS                                 0         19        320          .0625
    -- SYS_C007473                                                                                                                      INDEX              DATA_TS                                 0         19        312          .0625
    -- SYS_C007474                                                                                                                      INDEX              DATA_TS                                 0         19        304          .0625
    -- SYS_C007479                                                                                                                      INDEX              DATA_TS                                 0         19       1136          .0625
    -- SYS_C007484                                                                                                                      INDEX              DATA_TS                                 0         19       1272          .0625
    -- SYS_C007490                                                                                                                      INDEX              DATA_TS                                 0         19        616          .0625
    -- SYS_C007496                                                                                                                      INDEX              DATA_TS                                 0         19        472          .0625
    -- SYS_C007502                                                                                                                      INDEX              DATA_TS                                 0         19        536          .0625
    -- SYS_C007503                                                                                                                      INDEX              DATA_TS                                 0         19        528          .0625
    -- SYS_C007504                                                                                                                      INDEX              DATA_TS                                 0         19        520          .0625
    -- SYS_FK0000073626N00018$                                                                                                          INDEX              DATA_TS                                 0         19        496          .0625
    -- SYS_FK0000073626N00020$                                                                                                          INDEX              DATA_TS                                 0         19        560          .0625
    -- SYS_FK0000073626N00022$                                                                                                          INDEX              DATA_TS                                 0         19       1024          .0625
    -- SYS_FK0000073638N00018$                                                                                                          INDEX              DATA_TS                                 0         19        512          .0625
    -- SYS_FK0000073638N00020$                                                                                                          INDEX              DATA_TS                                 0         19        576          .0625
    -- SYS_FK0000073661N00009$                                                                                                          INDEX              DATA_TS                                 0         19       1160          .0625
    -- SYS_FK0000073661N00011$                                                                                                          INDEX              DATA_TS                                 0         19       1296          .0625
    -- SYS_IL0000073638C00017$$                                                                                                         LOBINDEX           DATA_TS                                 0         19        352          .0625
    -- TABLE_PLISTREFEXAMENS                                                                                                            NESTED TABLE       DATA_TS                                 0         19       1152          .0625
    -- TABLE_PLISTREFPRESCRIPTIONS                                                                                                      NESTED TABLE       DATA_TS                                 0         19       1288          .0625

    -- 109 rows selected.


    --     4) Ecrire  une  requête  qui  permet  pour  chacun  de  vos  segments  de  donner  le  nombre 
    -- total de blocs du segment, le nombre  de blocs utilisés et le nombre de blocs libres 
    -- <réponses et trace ici>

        /* Formatted on 03/10/2024 12:25:00 (QP5 v5.360) */
    SET PAGESIZE 500
    SET LINESIZE 300
    SELECT s.segment_name,
            s.segment_type,
            s.tablespace_name,
            s.blocks                        AS total_blocks,
            SUM (e.blocks)                  AS used_blocks,
            (s.blocks - SUM (e.blocks))     AS free_blocks
        FROM dba_segments s
            JOIN dba_extents e
                ON s.segment_name = e.segment_name AND s.owner = e.owner
    WHERE s.owner = UPPER ('Hopital')
    GROUP BY s.segment_name,
            s.segment_type,
            s.tablespace_name,
            s.blocks
    ORDER BY s.segment_name;

    
    -- SEGMENT_NAME                                                                                                                     SEGMENT_TYPE       TABLESPACE_NAME                TOTAL_BLOCKS USED_BLOCKS FREE_BLOCKS
    -- -------------------------------------------------------------------------------------------------------------------------------- ------------------ ------------------------------ ------------ ----------- -----------
    -- IDX_O_CONSULTATION_REF_PATIENT_REF_MEDECIN_DATE_UNIQUE                                                                           INDEX              USERS                                     8           8           0
    -- IDX_O_FACTURE_MONTANT_TOTAL                                                                                                      INDEX              USERS                                     8           8           0
    -- IDX_O_MEDECIN_EMAIL_UNIQUE                                                                                                       INDEX              USERS                                     8           8           0
    -- IDX_O_MEDECIN_NUM_SEC_SOCIAL_UNIQUE                                                                                              INDEX              USERS                                     8           8           0
    -- IDX_O_MEDECIN_SPECIALITE                                                                                                         INDEX              USERS                                     8           8           0
    -- IDX_O_PATIENT_EMAIL_UNIQUE                                                                                                       INDEX              USERS                                     8           8           0
    -- IDX_O_PATIENT_NUM_SEC_SOCIAL_UNIQUE                                                                                              INDEX              USERS                                     8           8           0
    -- IDX_TABLE_PLISTREFPRESCRIPTIONS_NESTED_TABLE_ID_COLUMN_VALUE                                                                     INDEX              USERS                                     8           8           0
    -- O_CONSULTATION                                                                                                                   TABLE              DATA_TS                                 384         384           0
    -- O_EXAMEN                                                                                                                         TABLE              DATA_TS                                 104         104           0
    -- O_FACTURE                                                                                                                        TABLE              DATA_TS                                  32          32           0
    -- O_MEDECIN                                                                                                                        TABLE              DATA_TS                                  64          64           0
    -- O_MEDECIN_TABLE_PLISTREFCONSULTATIONS                                                                                            NESTED TABLE       DATA_TS                                   8           8           0
    -- O_MEDECIN_TABLE_PLISTREFRENDEZVOUS                                                                                               NESTED TABLE       DATA_TS                                   8           8           0
    -- O_PATIENT                                                                                                                        TABLE              DATA_TS                                  72          72           0
    -- O_PATIENT_TABLE_PLISTREFCONSULTATIONS                                                                                            NESTED TABLE       DATA_TS                                   8           8           0
    -- O_PATIENT_TABLE_PLISTREFFACTURES                                                                                                 NESTED TABLE       DATA_TS                                   8           8           0
    -- O_PATIENT_TABLE_PLISTREFRENDEZVOUS                                                                                               NESTED TABLE       DATA_TS                                   8           8           0
    -- O_PRESCRIPTION                                                                                                                   TABLE              DATA_TS                                 104         104           0
    -- O_RENDEZ_VOUS                                                                                                                    TABLE              DATA_TS                                 112         112           0
    -- PK_O_CONSULTATION_ID_CONSULTATION                                                                                                INDEX              DATA_TS                                   8           8           0
    -- PK_O_EXAMEN_ID_EXAMEN                                                                                                            INDEX              DATA_TS                                   8           8           0
    -- PK_O_FACTURE_ID_FACTURE                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- PK_O_MEDECIN_ID_PERSONNE                                                                                                         INDEX              DATA_TS                                   8           8           0
    -- PK_O_PATIENT_ID_PERSONNE                                                                                                         INDEX              DATA_TS                                   8           8           0
    -- PK_O_PRESCRIPTION_ID_PRESCRIPTION                                                                                                INDEX              DATA_TS                                   8           8           0
    -- PK_O_RENDEZ_VOUS_ID_RENDEZ_VOUS                                                                                                  INDEX              DATA_TS                                   8           8           0
    -- STORECV                                                                                                                          LOBSEGMENT         DATA_TS                                  16          16           0
    -- SYS_C007459                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007460                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007461                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007462                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007472                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007473                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007474                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007479                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007484                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007490                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007496                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007502                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007503                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_C007504                                                                                                                      INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073626N00018$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073626N00020$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073626N00022$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073638N00018$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073638N00020$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073661N00009$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_FK0000073661N00011$                                                                                                          INDEX              DATA_TS                                   8           8           0
    -- SYS_IL0000073638C00017$$                                                                                                         LOBINDEX           DATA_TS                                   8           8           0
    -- TABLE_PLISTREFEXAMENS                                                                                                            NESTED TABLE       DATA_TS                                   8           8           0
    -- TABLE_PLISTREFPRESCRIPTIONS                                                                                                      NESTED TABLE       DATA_TS                                   8           8           0

    -- 52 rows selected.



    --     5) Ecrire une requête SQL qui permet de compacter et réduire un segment 
    -- <réponses et trace ici>

    ALTER TABLE NOM_TABLE ENABLE ROW MOUVEMENT;
    ALTER TABLE NOM_TABLE SHRINK SPACE;


    --     6) Ecrire une requête qui permet d’afficher l’ensemble des utilisateurs de votre base et 
    -- leurs droits 
    -- <réponses et trace ici> 
    SET PAGESIZE 500
    SET LINESIZE 300
        SELECT GRANTEE, PRIVILEGE
            FROM DBA_SYS_PRIVS
    ORDER BY GRANTEE;

    

    --     7)Proposer  trois  requêtes libres au choix de recherche d’objets dans le dictionnaire 
    -- Oracle 
    -- <réponses et trace ici> 

    -- Affichier toutes les tables  d'un utilisateur
    SET PAGESIZE 200
    SET LINESIZE 300
    COL table_name FORMAT A30
        SELECT table_name
            FROM dba_tables
    WHERE owner = 'HOPITAL';

    -- <réponses et trace ici>

    -- TABLE_NAME                    
    -- ------------------------------
    -- O_PATIENT_TABLE_PLISTREFRENDEZ
                            
                                                                                                                                                                                                                                                                                                                
    -- O_PATIENT_TABLE_PLISTREFCONSUL
                        
                                                                                                                                                                                                                                                                                                                
    -- O_PATIENT_TABLE_PLISTREFFACTUR
                                
                                                                                                                                                                                                                                                                                                                
    -- O_MEDECIN_TABLE_PLISTREFRENDEZ
                            
                                                                                                                                                                                                                                                                                                                
    -- O_MEDECIN_TABLE_PLISTREFCONSUL
                        
                                                                                                                                                                                                                                                                                                                
    -- TABLE_PLISTREFEXAMENS         
    -- TABLE_PLISTREFPRESCRIPTIONS   

    -- 7 rows selected.


    -- Afficher tous les indexes 
        SELECT index_name, table_name, owner
            FROM dba_indexes
    ORDER BY owner, table_name;

    -- Afficher tous les vues
        SELECT view_name, owner
            FROM dba_views
    ORDER BY owner, view_name;


    -- 4.4  Mise  en  place  d'une  stratégie  de  sauvegarde  et  restauration 
    -- (voir le chap. 6 du cours ADB1) 
    -- Mettez  en  place  une  stratégie  de  sauvegarde  et  restauration,  basée  sur  le  mode avec 
    -- archives. Votre stratégie doit décrire la politique de sauvegarde et restauration des fichiers 
    -- suivant  leur  type(périodicité  des  backups  des  fichiers  de  données  /  du  spfile  /  des  fichiers 
    -- d’archives / du fichier de contrôle, duplications des fichiers de contrôles ou rédo, etc). 
    -- Utililser l’outil Oracle Recovery Manager pour la mettre en œuvre. 
    
    -- Ecrirte pour cela un script de sauvegarde qui permet sous RMAN : 
    -- - D’arrêter la base 
    -- - De sauvegarder les fichiers de données 
    -- - De sauvergarder les fichiers d’archives 
    -- - De sauvegarder le SPFILE 
    -- - De sauvegarder les fichiers de contrôle 
    -- <réponses et trace ici>


    -- 1. Stratégie de Sauvegarde
        -- a. Fichiers de données : Sauvegardes incrémentales quotidiennes, sauvegarde complète hebdomadaire.
        -- b. Fichiers d’archives (redo logs archivés) : Sauvegarde quotidienne avec suppression automatique après la sauvegarde.
        -- c. SPFILE : Sauvegarde automatique avec la sauvegarde complète.
        -- d. Fichiers de contrôle : Sauvegarde quotidienne et multiplexage sur plusieurs disques.
        -- e. Redo logs : Multiplexés sur plusieurs disques.

        
       -- Script RMAN pour la sauvegarde et l'arrêt

        -- Connectez-vous à RMAN
        RMAN TARGET /

        -- Étape 1: Arrêter la base de données
        SHUTDOWN IMMEDIATE;

        -- Étape 2: Demarrez la base de données en mode montage(mount) pour effectuer une sauvegarde(backup)

        STARTUP MOUNT;

        -- Étape 3: Sauvegarder la base de données (fichiers de données, journaux d'archives, fichier de contrôle, SPFILE)

        RUN {
            -- Sauvegarder les fichiers de données et les journaux redo archivés
            BACKUP DATABASE PLUS ARCHIVELOG;

            -- Sauvegardez le SPFILE
            BACKUP SPFILE;

            -- Sauvegardez le fichier de contrôle
            BACKUP CURRENT CONTROLFILE;
        }

        -- Étape 4 : Ouvrez la base de données après la sauvegarde
        ALTER DATABASE OPEN;

        -- Étape 5 : Répertorier les sauvegardes (facultatif)
        LIST BACKUP;

        -- Étape 6 : Quitter RMAN
        EXIT;
        
        -- <réponses et trace ici>  

        /*
            Microsoft Windows [Version 10.0.26100.2033]
        (c) Microsoft Corporation. All rights reserved.

        C:\Users\pbobc>rman target /

        Recovery Manager: Release 18.0.0.0.0 - Production on Thu Oct 17 16:17:13 2024
        Version 18.4.0.0.0

        Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

        connected to target database: XE (DBID=3007669234)

        RMAN> shutdown immediate;

        using target database control file instead of recovery catalog
        database closed
        database dismounted
        Oracle instance shut down

        RMAN> startup mount;

        connected to target database (not started)
        Oracle instance started
        database mounted

        Total System Global Area    1610610664 bytes

        Fixed Size                     9029608 bytes
        Variable Size                788529152 bytes
        Database Buffers             805306368 bytes
        Redo Buffers                   7745536 bytes

        RMAN> run{ backup database plus archivelog; backup spifile; backup current controlfile; }

        RMAN-00571: ===========================================================
        RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
        RMAN-00571: ===========================================================
        RMAN-00558: error encountered while parsing input commands
        RMAN-01009: syntax error: found "identifier": expecting one of: "archivelog, as, auxiliary, backuppiece, backupset, backup, channel, check, controlfilecopy, copies, copy, cumulative, current, database, database root, datafilecopy, datafile, datapump, db_file_name_convert, db_recovery_file_dest, device, diskratio, duration, filesperset, force, format, for, from, full, incremental, keep, maxsetsize, nochecksum, noexclude, nokeep, not, passwordfile, pluggable, pool, proxy, recovery, reuse, section, skip readonly, skip, spfile, tablespace, tag, to, validate, ("
        RMAN-01008: the bad identifier was: spifile
        RMAN-01007: at line 1 column 46 file: standard input

        RMAN> run{ backup database plus archivelog; backup spfile; backup current controlfile; }


        Starting backup at 17-OCT-24
        allocated channel: ORA_DISK_1
        channel ORA_DISK_1: SID=614 device type=DISK
        channel ORA_DISK_1: starting archived log backup set
        channel ORA_DISK_1: specifying archived log(s) in backup set
        input archived log thread=1 sequence=333 RECID=134 STAMP=1180441560
        input archived log thread=1 sequence=334 RECID=135 STAMP=1180724745
        input archived log thread=1 sequence=335 RECID=136 STAMP=1180873176
        input archived log thread=1 sequence=336 RECID=137 STAMP=1180894702
        input archived log thread=1 sequence=337 RECID=138 STAMP=1180955340
        input archived log thread=1 sequence=338 RECID=139 STAMP=1180972404
        input archived log thread=1 sequence=339 RECID=140 STAMP=1180991660
        input archived log thread=1 sequence=340 RECID=141 STAMP=1181343641
        input archived log thread=1 sequence=341 RECID=142 STAMP=1181386402
        input archived log thread=1 sequence=342 RECID=143 STAMP=1181507143
        input archived log thread=1 sequence=343 RECID=144 STAMP=1181507907
        input archived log thread=1 sequence=344 RECID=145 STAMP=1181575970
        input archived log thread=1 sequence=345 RECID=146 STAMP=1181592520
        input archived log thread=1 sequence=346 RECID=147 STAMP=1181765687
        input archived log thread=1 sequence=347 RECID=148 STAMP=1182103231
        input archived log thread=1 sequence=348 RECID=149 STAMP=1182182424
        input archived log thread=1 sequence=349 RECID=150 STAMP=1182197426
        input archived log thread=1 sequence=350 RECID=151 STAMP=1182201717
        input archived log thread=1 sequence=351 RECID=152 STAMP=1182205852
        input archived log thread=1 sequence=352 RECID=153 STAMP=1182272083
        input archived log thread=1 sequence=353 RECID=154 STAMP=1182284046
        input archived log thread=1 sequence=354 RECID=155 STAMP=1182289622
        input archived log thread=1 sequence=355 RECID=156 STAMP=1182335382
        input archived log thread=1 sequence=356 RECID=157 STAMP=1182433676
        input archived log thread=1 sequence=357 RECID=158 STAMP=1182440545
        input archived log thread=1 sequence=358 RECID=159 STAMP=1182441418
        input archived log thread=1 sequence=359 RECID=160 STAMP=1182441656
        input archived log thread=1 sequence=360 RECID=161 STAMP=1182507808
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0A37QIAL_1_1 tag=TAG20241017T162453 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
        Finished backup at 17-OCT-24

        Starting backup at 17-OCT-24
        using channel ORA_DISK_1
        channel ORA_DISK_1: starting full datafile backup set
        channel ORA_DISK_1: specifying datafile(s) in backup set
        input datafile file number=00001 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\SYSTEM01.DBF
        input datafile file number=00003 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\SYSAUX01.DBF
        input datafile file number=00004 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\UNDOTBS01.DBF
        input datafile file number=00007 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\USERS01.DBF
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0B37QIAV_1_1 tag=TAG20241017T162502 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
        channel ORA_DISK_1: starting full datafile backup set
        channel ORA_DISK_1: specifying datafile(s) in backup set
        input datafile file number=00014 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSAUX01.DBF
        input datafile file number=00013 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSTEM01.DBF
        input datafile file number=00015 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\UNDOTBS01.DBF
        input datafile file number=00019 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_DATA_TS.DBF
        input datafile file number=00020 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_INDEX_TS.DBF
        input datafile file number=00016 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\USERS01.DBF
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0C37QIB2_1_1 tag=TAG20241017T162502 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:04
        channel ORA_DISK_1: starting full datafile backup set
        channel ORA_DISK_1: specifying datafile(s) in backup set
        input datafile file number=00010 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\SYSAUX01.DBF
        input datafile file number=00009 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\SYSTEM01.DBF
        input datafile file number=00011 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\UNDOTBS01.DBF
        input datafile file number=00012 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\USERS01.DBF
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0D37QIB6_1_1 tag=TAG20241017T162502 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
        channel ORA_DISK_1: starting full datafile backup set
        channel ORA_DISK_1: specifying datafile(s) in backup set
        input datafile file number=00006 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\SYSAUX01.DBF
        input datafile file number=00005 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\SYSTEM01.DBF
        input datafile file number=00008 name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\UNDOTBS01.DBF
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0E37QIB9_1_1 tag=TAG20241017T162502 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
        Finished backup at 17-OCT-24

        Starting backup at 17-OCT-24
        using channel ORA_DISK_1
        specification does not match any archived log in the repository
        backup cancelled because there are no files to backup
        Finished backup at 17-OCT-24

        Starting backup at 17-OCT-24
        using channel ORA_DISK_1
        channel ORA_DISK_1: starting full datafile backup set
        channel ORA_DISK_1: specifying datafile(s) in backup set
        including current SPFILE in backup set
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0F37QIBD_1_1 tag=TAG20241017T162517 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
        Finished backup at 17-OCT-24

        Starting backup at 17-OCT-24
        using channel ORA_DISK_1
        channel ORA_DISK_1: starting full datafile backup set
        channel ORA_DISK_1: specifying datafile(s) in backup set
        including current control file in backup set
        channel ORA_DISK_1: starting piece 1 at 17-OCT-24
        channel ORA_DISK_1: finished piece 1 at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0G37QIBE_1_1 tag=TAG20241017T162518 comment=NONE
        channel ORA_DISK_1: backup set complete, elapsed time: 00:00:01
        Finished backup at 17-OCT-24

        Starting Control File and SPFILE Autobackup at 17-OCT-24
        piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241017-00 comment=NONE
        Finished Control File and SPFILE Autobackup at 17-OCT-24

        RMAN> alter database open;

        Statement processed

        RMAN> list backup;


        List of Backup Sets
        ===================


        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        1       Full    1.26G      DISK        00:00:04     03-FEB-24
                BP Key: 1   Status: AVAILABLE  Compressed: NO  Tag: TAG20240203T135004
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\012I7F0D_1_1
        List of Datafiles in backup set 1
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        1       Full 19039777   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\SYSTEM01.DBF
        3       Full 19039777   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\SYSAUX01.DBF
        4       Full 19039777   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\UNDOTBS01.DBF
        7       Full 19039777   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\USERS01.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        2       Full    620.14M    DISK        00:00:02     03-FEB-24
                BP Key: 2   Status: AVAILABLE  Compressed: NO  Tag: TAG20240203T135004
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\022I7F0L_1_1
        List of Datafiles in backup set 2
        Container ID: 3, PDB Name: XEPDB1
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        9       Full 19037716   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\SYSTEM01.DBF
        10      Full 19037716   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\SYSAUX01.DBF
        11      Full 19037716   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\UNDOTBS01.DBF
        12      Full 19037716   03-FEB-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\USERS01.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        3       Full    524.18M    DISK        00:00:02     03-FEB-24
                BP Key: 3   Status: AVAILABLE  Compressed: NO  Tag: TAG20240203T135004
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\032I7F0O_1_1
        List of Datafiles in backup set 3
        Container ID: 2, PDB Name: PDB$SEED
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        5       Full 1448570    19-JAN-23              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\SYSTEM01.DBF
        6       Full 1448570    19-JAN-23              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\SYSAUX01.DBF
        8       Full 1448570    19-JAN-23              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\UNDOTBS01.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        4       Full    17.95M     DISK        00:00:01     03-FEB-24
                BP Key: 4   Status: AVAILABLE  Compressed: NO  Tag: TAG20240203T135019
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20240203-00
        SPFILE Included: Modification time: 03-FEB-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 19039777     Ckp time: 03-FEB-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        5       Full    17.95M     DISK        00:00:01     12-OCT-24
                BP Key: 5   Status: AVAILABLE  Compressed: NO  Tag: TAG20241012T143006
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241012-00
        SPFILE Included: Modification time: 12-OCT-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 34603474     Ckp time: 12-OCT-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        6       Full    17.95M     DISK        00:00:01     13-OCT-24
                BP Key: 6   Status: AVAILABLE  Compressed: NO  Tag: TAG20241013T175439
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241013-00
        SPFILE Included: Modification time: 13-OCT-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 35082681     Ckp time: 13-OCT-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        7       Full    17.95M     DISK        00:00:01     13-OCT-24
                BP Key: 7   Status: AVAILABLE  Compressed: NO  Tag: TAG20241013T181943
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241013-01
        SPFILE Included: Modification time: 13-OCT-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 35084053     Ckp time: 13-OCT-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        8       Full    17.95M     DISK        00:00:01     13-OCT-24
                BP Key: 8   Status: AVAILABLE  Compressed: NO  Tag: TAG20241013T190952
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241013-02
        SPFILE Included: Modification time: 13-OCT-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 35094135     Ckp time: 13-OCT-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        9       Full    17.95M     DISK        00:00:05     13-OCT-24
                BP Key: 9   Status: AVAILABLE  Compressed: NO  Tag: TAG20241013T191954
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241013-03
        SPFILE Included: Modification time: 13-OCT-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 35095710     Ckp time: 13-OCT-24

        BS Key  Size       Device Type Elapsed Time Completion Time
        ------- ---------- ----------- ------------ ---------------
        10      2.45G      DISK        00:00:07     17-OCT-24
                BP Key: 10   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162453
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0A37QIAL_1_1

        List of Archived Logs in backup set 10
        Thrd Seq     Low SCN    Low Time  Next SCN   Next Time
        ---- ------- ---------- --------- ---------- ---------
        1    333     32971883   22-SEP-24 33090608   23-SEP-24
        1    334     33090608   23-SEP-24 33293994   26-SEP-24
        1    335     33293994   26-SEP-24 33382351   28-SEP-24
        1    336     33382351   28-SEP-24 33445813   28-SEP-24
        1    337     33445813   28-SEP-24 33604515   29-SEP-24
        1    338     33604515   29-SEP-24 33671248   29-SEP-24
        1    339     33671248   29-SEP-24 33735433   29-SEP-24
        1    340     33735433   29-SEP-24 33851686   02-OCT-24
        1    341     33851686   02-OCT-24 33959799   03-OCT-24
        1    342     33959799   03-OCT-24 34146235   04-OCT-24
        1    343     34146235   04-OCT-24 34247433   04-OCT-24
        1    344     34247433   04-OCT-24 34348618   05-OCT-24
        1    345     34348618   05-OCT-24 34407719   05-OCT-24
        1    346     34407719   05-OCT-24 34488001   07-OCT-24
        1    347     34488001   07-OCT-24 34558178   11-OCT-24
        1    348     34558178   11-OCT-24 34626616   12-OCT-24
        1    349     34626616   12-OCT-24 34687317   12-OCT-24
        1    350     34687317   12-OCT-24 34798306   12-OCT-24
        1    351     34798306   12-OCT-24 34899911   12-OCT-24
        1    352     34899911   12-OCT-24 35048259   13-OCT-24
        1    353     35048259   13-OCT-24 35110273   13-OCT-24
        1    354     35110273   13-OCT-24 35228244   13-OCT-24
        1    355     35228244   13-OCT-24 35328437   14-OCT-24
        1    356     35328437   14-OCT-24 35468610   15-OCT-24
        1    357     35468610   15-OCT-24 35574484   15-OCT-24
        1    358     35574484   15-OCT-24 35676101   15-OCT-24
        1    359     35676101   15-OCT-24 35777413   15-OCT-24
        1    360     35777413   15-OCT-24 35895962   16-OCT-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        11      Full    1.28G      DISK        00:00:03     17-OCT-24
                BP Key: 11   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162502
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0B37QIAV_1_1
        List of Datafiles in backup set 11
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        1       Full 36165759   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\SYSTEM01.DBF
        3       Full 36165759   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\SYSAUX01.DBF
        4       Full 36165759   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\UNDOTBS01.DBF
        7       Full 36165759   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\USERS01.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        12      Full    524.13M    DISK        00:00:02     17-OCT-24
                BP Key: 12   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162502
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0C37QIB2_1_1
        List of Datafiles in backup set 12
        Container ID: 4, PDB Name: HOPITALPDB
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        13      Full 36165646   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSTEM01.DBF
        14      Full 36165646   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSAUX01.DBF
        15      Full 36165646   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\UNDOTBS01.DBF
        16      Full 36165646   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\USERS01.DBF
        19      Full 36165646   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_DATA_TS.DBF
        20      Full 36165646   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_INDEX_TS.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        13      Full    646.12M    DISK        00:00:02     17-OCT-24
                BP Key: 13   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162502
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0D37QIB6_1_1
        List of Datafiles in backup set 13
        Container ID: 3, PDB Name: XEPDB1
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        9       Full 36165638   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\SYSTEM01.DBF
        10      Full 36165638   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\SYSAUX01.DBF
        11      Full 36165638   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\UNDOTBS01.DBF
        12      Full 36165638   17-OCT-24              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\XEPDB1\USERS01.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        14      Full    524.18M    DISK        00:00:01     17-OCT-24
                BP Key: 14   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162502
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0E37QIB9_1_1
        List of Datafiles in backup set 14
        Container ID: 2, PDB Name: PDB$SEED
        File LV Type Ckp SCN    Ckp Time  Abs Fuz SCN Sparse Name
        ---- -- ---- ---------- --------- ----------- ------ ----
        5       Full 1448570    19-JAN-23              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\SYSTEM01.DBF
        6       Full 1448570    19-JAN-23              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\SYSAUX01.DBF
        8       Full 1448570    19-JAN-23              NO    C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\PDBSEED\UNDOTBS01.DBF

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        15      Full    96.00K     DISK        00:00:00     17-OCT-24
                BP Key: 15   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162517
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0F37QIBD_1_1
        SPFILE Included: Modification time: 17-OCT-24
        SPFILE db_unique_name: XE

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        16      Full    17.92M     DISK        00:00:01     17-OCT-24
                BP Key: 16   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162518
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0G37QIBE_1_1
        Control File Included: Ckp SCN: 36165759     Ckp time: 17-OCT-24

        BS Key  Type LV Size       Device Type Elapsed Time Completion Time
        ------- ---- -- ---------- ----------- ------------ ---------------
        17      Full    17.95M     DISK        00:00:01     17-OCT-24
                BP Key: 17   Status: AVAILABLE  Compressed: NO  Tag: TAG20241017T162520
                Piece Name: C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\C-3007669234-20241017-00
        SPFILE Included: Modification time: 17-OCT-24
        SPFILE db_unique_name: XE
        Control File Included: Ckp SCN: 36165759     Ckp time: 17-OCT-24

        RMAN> exit;


        Recovery Manager complete.
        */


    -- 4.5  Provoquer au moins deux pannes et procéder à la réparation 
    -- Provoquer  deux  pannes  au  moins  et  y  remedier  grâce  à  votre  stratégie  de  sauvegarde.  Les 
    -- pannes peuvent être : 
    -- - La perte de fichiers de données 
    -- - La perte de fichiers de contrôles. 
    -- - Perte d’un fichier Redolog 
    -- - Perte d’un groupe de fichiers redolog 
    
    -- <réponses et trace ici>

    -- A- La perte de fichiers de données 
        /*    
                Connected to:
            Oracle Database 18c Express Edition Release 18.0.0.0.0 - Production
            Version 18.4.0.0.0

            SQL> alter pluggable database hopitalpdb open;
            alter pluggable database hopitalpdb open
            *
            ERROR at line 1:
            ORA-01157: cannot identify/lock data file 19 - see DBWR trace file
            ORA-01110: data file 19:
            'C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_DATA_TS.DBF'

            SQL>
        */

        rman target hopital@hopital/pass123$
        run{restore database; recover database;}

        /*
                C:\Users\pbobc> rman target hopital@hopital/pass123$

            Recovery Manager: Release 18.0.0.0.0 - Production on Sat Oct 19 13:06:00 2024
            Version 18.4.0.0.0

            Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

            connected to target database: XE:HOPITALPDB (DBID=4131533925, not open)

            RMAN> run{restore database; recover database;}

            Starting restore at 19-OCT-24
            using target database control file instead of recovery catalog
            allocated channel: ORA_DISK_1
            channel ORA_DISK_1: SID=252 device type=DISK

            channel ORA_DISK_1: starting datafile backup set restore
            channel ORA_DISK_1: specifying datafile(s) to restore from backup set
            channel ORA_DISK_1: restoring datafile 00013 to C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSTEM01.DBF
            channel ORA_DISK_1: restoring datafile 00014 to C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\SYSAUX01.DBF
            channel ORA_DISK_1: restoring datafile 00015 to C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\UNDOTBS01.DBF
            channel ORA_DISK_1: restoring datafile 00016 to C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\USERS01.DBF
            channel ORA_DISK_1: restoring datafile 00019 to C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_DATA_TS.DBF
            channel ORA_DISK_1: restoring datafile 00020 to C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\HOPITALPDB\DATAFILE_INDEX_TS.DBF
            channel ORA_DISK_1: reading from backup piece C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0C37QIB2_1_1
            channel ORA_DISK_1: piece handle=C:\APP\PBOBC\PRODUCT\18.0.0\DBHOMEXE\DATABASE\0C37QIB2_1_1 tag=TAG20241017T162502
            channel ORA_DISK_1: restored backup piece 1
            channel ORA_DISK_1: restore complete, elapsed time: 00:00:03
            Finished restore at 19-OCT-24

            Starting recover at 19-OCT-24
            using channel ORA_DISK_1

            starting media recovery
            media recovery complete, elapsed time: 00:00:04

            Finished recover at 19-OCT-24

            RMAN>

        */

        -- La perte de fichiers de contrôles. 
        -- <réponses et trace ici>

        RMAN> SET DBID 3007669234;
        RUN {
        RESTORE CONTROLFILE FROM AUTOBACKUP;
        ALTER DATABASE MOUNT;
        RECOVER DATABASE;
        ALTER DATABASE OPEN RESETLOGS;
        }

    /* 
        Microsoft Windows [Version 10.0.26100.2033]
        (c) Microsoft Corporation. All rights reserved.

        C:\Users\pbobc>sqlplus / as sysdba

        SQL*Plus: Release 18.0.0.0.0 - Production on Sat Oct 19 15:47:43 2024
        Version 18.4.0.0.0

        Copyright (c) 1982, 2018, Oracle.  All rights reserved.


        Connected to:
        Oracle Database 18c Express Edition Release 18.0.0.0.0 - Production
        Version 18.4.0.0.0

        SQL> conn hopital/pass123$@hopital
        ERROR:
        ORA-12514: TNS:listener does not currently know of service requested in connect
        descriptor


        Warning: You are no longer connected to ORACLE.
        SQL> select * from v$database;
        SP2-0640: Not connected
        SQL> show pdbs;
        SP2-0640: Not connected
        SP2-0641: "SHOW PDBS" requires connection to server
        SQL> rman target /
        SP2-0734: unknown command beginning "rman targe..." - rest of line ignored.
        SQL> exit

        C:\Users\pbobc>rman target /

        Recovery Manager: Release 18.0.0.0.0 - Production on Sat Oct 19 15:51:21 2024
        Version 18.4.0.0.0

        Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

        connected to target database: XE (not mounted)

        RMAN> exit


        Recovery Manager complete.

        C:\Users\pbobc>rman

        Recovery Manager: Release 18.0.0.0.0 - Production on Sat Oct 19 15:55:50 2024
        Version 18.4.0.0.0

        Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

        RMAN> connect target /

        connected to target database: XE (not mounted)

        RMAN>  RUN{ RESTORE CONTROLFILE FROM AUTOBACKUP; RECOVER DATABASE; ALTER DATABASE OPEN RESETLOGS; }

        Starting restore at 19-OCT-24
        using target database control file instead of recovery catalog
        allocated channel: ORA_DISK_1
        channel ORA_DISK_1: SID=1101 device type=DISK

        RMAN-00571: ===========================================================
        RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
        RMAN-00571: ===========================================================
        RMAN-03002: failure of restore command at 10/19/2024 15:56:26
        RMAN-06495: must explicitly specify DBID with SET DBID command

        RMAN> list backup of controlfile;

        RMAN-00571: ===========================================================
        RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
        RMAN-00571: ===========================================================
        RMAN-03002: failure of list command at 10/19/2024 15:57:51
        ORA-01507: database not mounted

        RMAN> SET DBID 3007669234;

        executing command: SET DBID

        RMAN> STARTUP NOMOUNT;

        database is already started

        RMAN> RUN {
        2>    RESTORE CONTROLFILE FROM AUTOBACKUP;
        3>    ALTER DATABASE MOUNT;
        4>    RECOVER DATABASE;
        5>    ALTER DATABASE OPEN RESETLOGS;
        6> }

        Starting restore at 19-OCT-24
        using channel ORA_DISK_1

        channel ORA_DISK_1: looking for AUTOBACKUP on day: 20241019
        channel ORA_DISK_1: looking for AUTOBACKUP on day: 20241018
        channel ORA_DISK_1: AUTOBACKUP found: c-3007669234-20241018-00
        channel ORA_DISK_1: restoring control file from AUTOBACKUP c-3007669234-20241018-00
        channel ORA_DISK_1: control file restore from AUTOBACKUP complete
        output file name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\CONTROL01.CTL
        output file name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\CONTROL02.CTL
        Finished restore at 19-OCT-24

        released channel: ORA_DISK_1
        Statement processed

        Starting recover at 19-OCT-24
        allocated channel: ORA_DISK_1
        channel ORA_DISK_1: SID=2 device type=DISK

        starting media recovery

        archived log for thread 1 with sequence 362 is already on disk as file C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO02.LOG
        archived log for thread 1 with sequence 363 is already on disk as file C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO03.LOG
        archived log file name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO02.LOG thread=1 sequence=362
        archived log file name=C:\APP\PBOBC\PRODUCT\18.0.0\ORADATA\XE\REDO03.LOG thread=1 sequence=363
        media recovery complete, elapsed time: 00:00:01
        Finished recover at 19-OCT-24

        Statement processed

        RMAN>
    */



    --    4.6  Export / import (voir le chap. 7 du cours ADB1) 
    -- Vous devez transporter les données d’un de vos utilisateurs d’une base vers une autre. Les 
    -- deux bases peuvent être la même. Faire le nécessaire en utilisant export et import afin que cela 
    -- fonctionne     

    -- <réponses et trace ici> 

    -- CREATE DIRECTORY
    create directory dump_dir as 'C:\oracle_export';

    -- Directory created.

    -- EXPORT SCRIPT
    expdp hopital/pass123$@hopital schemas=hopital directory=dump_dir dumpfile=hopital_exp%U.dmp logfile=hopital_exp.log
        /*
        C:\Windows\System32>expdp hopital/pass123$@hopital schemas=hopital directory=dump_dir dumpfile=hopital_exp%U.dmp logfile=hopital_exp.log

        Export: Release 18.0.0.0.0 - Production on Fri Oct 18 20:43:15 2024
        Version 18.4.0.0.0

        Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

        Connected to: Oracle Database 18c Express Edition Release 18.0.0.0.0 - Production
        Starting "HOPITAL"."SYS_EXPORT_SCHEMA_01":  hopital/********@hopital schemas=hopital directory=dump_dir dumpfile=hopital_exp%U.dmp logfile=hopital_exp.log
        Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
        Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
        Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
        Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
        Processing object type SCHEMA_EXPORT/USER
        Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
        Processing object type SCHEMA_EXPORT/ROLE_GRANT
        Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
        Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
        Processing object type SCHEMA_EXPORT/TYPE/INC_TYPE
        Processing object type SCHEMA_EXPORT/TYPE/TYPE_SPEC
        Processing object type SCHEMA_EXPORT/TABLE/TABLE
        Processing object type SCHEMA_EXPORT/TABLE/COMMENT
        Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
        Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
        . . exported "HOPITAL"."TABLE_PLISTREFEXAMENS"           5.851 KB      10 rows
        . . exported "HOPITAL"."O_CONSULTATION"                  11.43 KB      10 rows
        . . exported "HOPITAL"."TABLE_PLISTREFPRESCRIPTIONS"     5.859 KB      10 rows
        . . exported "HOPITAL"."O_EXAMEN"                        8.109 KB      10 rows
        . . exported "HOPITAL"."O_FACTURE"                       8.648 KB      10 rows
        . . exported "HOPITAL"."O_MEDECIN_TABLE_PLISTREFCONSULTATIONS"  5.867 KB      10 rows
        . . exported "HOPITAL"."O_MEDECIN"                       17.39 KB      10 rows
        . . exported "HOPITAL"."O_MEDECIN_TABLE_PLISTREFRENDEZVOUS"  5.867 KB      10 rows
        . . exported "HOPITAL"."O_PATIENT_TABLE_PLISTREFFACTURES"  5.867 KB      10 rows
        . . exported "HOPITAL"."O_PATIENT_TABLE_PLISTREFRENDEZVOUS"  5.867 KB      10 rows
        . . exported "HOPITAL"."O_PATIENT"                       20.79 KB      20 rows
        . . exported "HOPITAL"."O_PATIENT_TABLE_PLISTREFCONSULTATIONS"  5.867 KB      10 rows
        . . exported "HOPITAL"."O_PRESCRIPTION"                  8.320 KB      10 rows
        . . exported "HOPITAL"."O_RENDEZ_VOUS"                   8.804 KB      10 rows
        Master table "HOPITAL"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
        ******************************************************************************
        Dump file set for HOPITAL.SYS_EXPORT_SCHEMA_01 is:
        C:\ORACLE_EXPORT\HOPITAL_EXP01.DMP
        Job "HOPITAL"."SYS_EXPORT_SCHEMA_01" successfully completed at Fri Oct 18 20:43:59 2024 elapsed 0 00:00:41
        */
        */

    -- Directory created.
    create directory dump_dir as 'C:\oracle_import';
    -- Directory created.
    
    -- IMPORTATION SCRIPT
    impdp hopital/pass123$@XEPDB1 schemas=hopital directory=dump_dir dumpfile=HOPITAL_EXP01.DMP logfile=hopital_imp.log

        /*   
        C:\Windows\System32>impdp hopital/pass123$@XEPDB1 schemas=hopital directory=dump_dir dumpfile=HOPITAL_EXP01.DMP logfile=hopital_imp.log

        Import: Release 18.0.0.0.0 - Production on Fri Oct 18 22:39:34 2024
        Version 18.4.0.0.0

        Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

        Connected to: Oracle Database 18c Express Edition Release 18.0.0.0.0 - Production
        Master table "HOPITAL"."SYS_IMPORT_SCHEMA_01" successfully loaded/unloaded
        Starting "HOPITAL"."SYS_IMPORT_SCHEMA_01":  hopital/********@XEPDB1 schemas=hopital directory=dump_dir dumpfile=HOPITAL_EXP01.DMP logfile=hopital_imp.log
        Processing object type SCHEMA_EXPORT/USER
        ORA-31684: Object type USER:"HOPITAL" already exists

        Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
        Processing object type SCHEMA_EXPORT/ROLE_GRANT
        Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
        Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
        Processing object type SCHEMA_EXPORT/TYPE/INC_TYPE
        Processing object type SCHEMA_EXPORT/TYPE/TYPE_SPEC
        Processing object type SCHEMA_EXPORT/TABLE/TABLE
        Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
        . . imported "HOPITAL"."TABLE_PLISTREFEXAMENS"           5.851 KB      10 rows
        . . imported "HOPITAL"."O_CONSULTATION"                  11.43 KB      10 rows
        . . imported "HOPITAL"."TABLE_PLISTREFPRESCRIPTIONS"     5.859 KB      10 rows
        . . imported "HOPITAL"."O_EXAMEN"                        8.109 KB      10 rows
        . . imported "HOPITAL"."O_FACTURE"                       8.648 KB      10 rows
        . . imported "HOPITAL"."O_MEDECIN_TABLE_PLISTREFCONSULTATIONS"  5.867 KB      10 rows
        . . imported "HOPITAL"."O_MEDECIN"                       17.39 KB      10 rows
        . . imported "HOPITAL"."O_MEDECIN_TABLE_PLISTREFRENDEZVOUS"  5.867 KB      10 rows
        . . imported "HOPITAL"."O_PATIENT_TABLE_PLISTREFFACTURES"  5.867 KB      10 rows
        . . imported "HOPITAL"."O_PATIENT_TABLE_PLISTREFRENDEZVOUS"  5.867 KB      10 rows
        . . imported "HOPITAL"."O_PATIENT"                       20.79 KB      20 rows
        . . imported "HOPITAL"."O_PATIENT_TABLE_PLISTREFCONSULTATIONS"  5.867 KB      10 rows
        . . imported "HOPITAL"."O_PRESCRIPTION"                  8.320 KB      10 rows
        . . imported "HOPITAL"."O_RENDEZ_VOUS"                   8.804 KB      10 rows
        Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
        Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
        Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
        Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
        Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
        Job "HOPITAL"."SYS_IMPORT_SCHEMA_01" completed with 1 error(s) at Fri Oct 18 22:40:08 2024 elapsed 0 00:00:33


        C:\Windows\System32>

        */
        */