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

