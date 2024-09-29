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
    DATAFILE 'datafile_data_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    AUTOALLOCATE;

-- 2. Tablespaces pour stocker les données d’indexes
--     Création :

    CREATE TABLESPACE INDEX_TS
    DATAFILE 'datafile_index_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    AUTOALLOCATE;

-- 3. Tablespace pour stocker les segments temporaires
--     Création :

    CREATE TEMPORARY TABLESPACE TEMP_TS
    TEMPFILE 'tempfile_temp_ts.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
    EXTENT MANAGEMENT LOCAL
    AUTOALLOCATE;

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
    CREATE USER Hopital IDENTIFIED BY PASS123;
    DEFAULT TABLESPACE data_ts
    TEMPORARY TABLESPACE temp_ts
    QUOTA UNLIMITED ON data_ts;

-- 2. Attribution des droits
   /* GRANT CONNECT, RESOURCE TO Hopital;
    GRANT CREATE SESSION TO Hopital;
    GRANT CREATE TABLE TO Hopital;
    GRANT CREATE INDEX TO Hopital;
    GRANT CREATE VIEW TO Hopital;
    GRANT CREATE PROCEDURE TO Hopital;
    GRANT CREATE SEQUENCE TO Hopital;
    GRANT CREATE TRIGGER TO Hopital;
    GRANT CREATE SYNONYM TO Hopital;
    GRANT CREATE TYPE TO Hopital;*/
    GRANT ALL PRIVILEGES TO Hopital;

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

    -- used bytes =  516096 bytes
    -- allocated bytes = 524288 bytes

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
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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

    CREATE TABLE O_EXAMEN OF EXAMEN_T(
	CONSTRAINT pk_o_examen_id_examen PRIMARY KEY(Id_Examen),
	refConsultation CONSTRAINT o_examen_ref_consultation_not_null NOT NULL,
	Details_Examen CONSTRAINT details_examen_not_null NOT NULL,
	Date_Examen CONSTRAINT date_examen_not_null NOT NULL
    )
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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

    CREATE TABLE O_PRESCRIPTION OF PRESCRIPTION_T(
	CONSTRAINT pk_o_prescription_id_prescription PRIMARY KEY(Id_Prescription),
	refConsultation CONSTRAINT o_prescription_ref_consultation_not_null NOT NULL,
	Details_Prescription CONSTRAINT details_prescription_not_null NOT NULL,
	Date_Prescription CONSTRAINT date_prescription_not_null NOT NULL
    )
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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

    CREATE TABLE O_FACTURE OF FACTURE_T(	
	CONSTRAINT pk_o_facture_id_facture PRIMARY KEY(Id_Facture),
	refPatient CONSTRAINT o_facture_ref_patient_not_null NOT NULL,
	refConsultation CONSTRAINT o_facture_ref_consultation_not_null NOT NULL,
	Montant_Total CONSTRAINT montant_total_not_null NOT NULL,
	Date_Facture CONSTRAINT date_facture_not_null NOT NULL
    )
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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

    CREATE TABLE O_RENDEZ_VOUS OF RENDEZ_VOUS_T(
	CONSTRAINT pk_o_rendez_vous_id_rendez_vous PRIMARY KEY(Id_Rendez_Vous),
	refPatient CONSTRAINT o_rendez_vous_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_rendez_vous_ref_medecin_not_null NOT NULL,
	Date_Rendez_Vous CONSTRAINT date_rendez_vous_not_null NOT NULL,
	Motif CONSTRAINT motif_not_null NOT NULL
    )
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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

    CREATE TABLE O_CONSULTATION OF CONSULTATION_T(
	CONSTRAINT pk_o_consultation_id_consultation PRIMARY KEY(Id_Consultation),
	refPatient CONSTRAINT o_consultation_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_consultation_ref_medecin_not_null NOT NULL,
	Raison CONSTRAINT raison_not_null NOT NULL,
	Date_Consultation CONSTRAINT date_consultation_not_null NOT NULL
    ) 
    NESTED TABLE pListRefExamens STORE AS table_pListRefExamens
    NESTED TABLE pListRefPrescriptions STORE AS table_pListRefPrescriptions
    TABLESPACE DATA_TS
    SEGMENT CREATION IMMEDIATE
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
                'CREATE UNIQUE INDEX idx_o_patient_num_sec_social_unique ON O_PATIENT(Numero_Securite_Sociale);',
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
    TABLESPACE INDEX_TS;
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




