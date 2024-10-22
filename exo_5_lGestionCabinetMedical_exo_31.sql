 set serveroutput on
 
 set timing on
 
 
 set arraysize 5000
 
 
 
 -- 1. Capture en parralèle des statistiques pour AWR : 1er cliché
 
 -- Connexion au niveau CDB pour prendre un cliché AWR
 -- verifier qu'on a une connexion au niveau du CDB
 show con_name;

 set arraysize 5000
 set serveroutput on
 declare
    snapid1 number;
    begin
   snapid1:=dbms_workload_repository.create_snapshot;
    dbms_output.put_line('Snapid1='|| snapid1);
    end;
    /
 
  -- ReConnexion au niveau PDB.
 connect hopital@hopital/pass123$;

 set arraysize 5000
 -- activation de la trace afin de pouvoir par la suite utiliser TKPROF
 -- Voir les indications à la fin de ce fichier.
 execute dbms_session.set_sql_trace(true);
 
 
  -- 2. Provoquer l'activité sur la base de données
 
 -- Nous allons volontairement provoquer de l'activité dans la base.
 -- Cela permettra de capturer des clichés de statistiques significatifs
 -- Une première activité va consister à créer un utilisateur appelé MYPDBUSER
 -- Des données seront créées  dans son schéma et des requêtes lancées sur
 -- ces données.
 -- Cinq applications qui font la même chose seront installées :
 	     -- la 1ère écrite en objet relationnel les tables du Gestion Cabinet Medical
 	     -- La 2ème écrite en relationnel les tables du Gestion Cabinet Medical
 	     -- La 3ème écrite en relationnel les tables sont organisees dans des segments séparés
 	     -- La 4ème écrite en relationnel mais les tables sont organisées dans un cluster indexé (ex: IEXAMEN, ICONSULTATION)
 	     -- La 5ème écrite en relationnel mais les tables sont organisées dans un cluster haché (ex: HEXAMEN, HCONSULTATION)
 -- Plusieurs requêtes sur ces applications sont ensuites lancées.
 
 -- On pourra ainsi profiter pour comparer les performances des différentes
 -- approches.
 
 -- Fixer le format de date et langue
 alter session set nls_date_format='DD-MON-YYYY';
 
 alter session set nls_language=american;
 
 
 
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 -- la 1ère écrite en objet relationnel (table objet: O_EXAMEN, O_CONSULTATION) --------------------------------------
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 
 -- Suppression des tables et des types objets s'ils existent déjà
 
 
-- SUPPRESSION DES TABLES OBJETS
DROP TABLE O_EXAMEN CASCADE CONSTRAINTS;
DROP TABLE O_CONSULTATION CASCADE CONSTRAINTS;
DROP TABLE O_PRESCRIPTION CASCADE CONSTRAINTS;
DROP TABLE O_FACTURE CASCADE CONSTRAINTS;
DROP TABLE O_RENDEZ_VOUS CASCADE CONSTRAINTS;
DROP TABLE O_MEDECIN CASCADE CONSTRAINTS;
DROP TABLE O_PATIENT CASCADE CONSTRAINTS;

-- SUPPRESSION DES TYPES
DROP TYPE setCONSULTATIONS_T FORCE;
DROP TYPE setFACTURES_T FORCE;
DROP TYPE setPATIENTS_T FORCE;
DROP TYPE setRENDEZ_VOUS_T FORCE;
DROP TYPE ADRESSE_T FORCE;
DROP TYPE LIST_PRENOMS_T FORCE;
DROP TYPE LIST_TELEPHONES_T FORCE;
DROP TYPE ListRefConsultations_t FORCE;
DROP TYPE ListRefRendezVous_t FORCE;
DROP TYPE ListRefFactures_t FORCE;
DROP TYPE ListRefExamens_t FORCE;
DROP TYPE ListRefPrescriptions_t FORCE;
DROP TYPE PERSONNE_T FORCE;
DROP TYPE EXAMEN_T FORCE;
DROP TYPE PATIENT_T FORCE;
DROP TYPE MEDECIN_T FORCE;
DROP TYPE PRESCRIPTION_T FORCE;
DROP TYPE FACTURE_T FORCE;
DROP TYPE CONSULTATION_T FORCE;
DROP TYPE RENDEZ_VOUS_T FORCE;
DROP TYPE SETEXAMEN_T FORCE;
DROP TYPE SETPRESCRIPTION_T FORCE;


-- CREATION DES TYPES 
CREATE OR REPLACE TYPE ADRESSE_T AS OBJECT (
	 NUMERO NUMBER(4),
	 RUE VARCHAR2(40),
	 CODE_POSTAL NUMBER(5),
	 VILLE VARCHAR2(30)
)
/

CREATE OR REPLACE TYPE LIST_PRENOMS_T AS VARRAY(3) OF VARCHAR2(30)
/

CREATE OR REPLACE TYPE LIST_TELEPHONES_T AS VARRAY(3) OF VARCHAR2(30)
/

CREATE OR REPLACE TYPE RENDEZ_VOUS_T
/

CREATE OR REPLACE TYPE ListRefRendezVous_t AS TABLE OF REF RENDEZ_VOUS_T
/

CREATE OR REPLACE TYPE CONSULTATION_T
/

CREATE OR REPLACE TYPE ListRefConsultations_t AS TABLE OF REF CONSULTATION_T
/

CREATE OR REPLACE TYPE FACTURE_T
/

CREATE OR REPLACE TYPE ListRefFactures_t AS TABLE OF REF FACTURE_T
/

CREATE OR REPLACE TYPE EXAMEN_T
/

CREATE OR REPLACE TYPE ListRefExamens_t AS TABLE OF REF EXAMEN_T
/

CREATE OR REPLACE TYPE PRESCRIPTION_T
/

CREATE OR REPLACE TYPE ListRefPrescriptions_t AS TABLE OF REF PRESCRIPTION_T
/  

CREATE OR REPLACE TYPE PATIENT_T
/

CREATE OR REPLACE TYPE MEDECIN_T
/

-- Declarer le Type RENDEZ_VOUS_T
CREATE OR REPLACE TYPE RENDEZ_VOUS_T AS OBJECT(
    Id_Rendez_Vous NUMBER(8),
    refPatient REF PATIENT_T,
    refMedecin REF MEDECIN_T,
    Date_Rendez_Vous DATE,
    Motif VARCHAR2(200),

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION getDate RETURN DATE,
    -- Méthode d'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE, 
    -- Gestion des liens
    MEMBER PROCEDURE linkToPatient(p REF PATIENT_T),
    -- Gestion des liens
    MEMBER PROCEDURE linkToMedecin(m REF MEDECIN_T), 
    -- Consultation
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T, 
    -- Consultation
    MEMBER FUNCTION getRefMedecin RETURN REF MEDECIN_T, 
     -- Méthode CRUD (update)
    MEMBER PROCEDURE updateMotif(newMotif VARCHAR2),
    -- Méthode CRUD (delete)
    MEMBER PROCEDURE deleteRendezVous                 
);
/

CREATE OR REPLACE TYPE setRENDEZ_VOUS_T AS TABLE OF RENDEZ_VOUS_T
/

-- dEclarer le Type EXAMEN_T
CREATE OR REPLACE TYPE EXAMEN_T AS OBJECT(
    Id_Examen NUMBER(8),
    refConsultation REF CONSULTATION_T,
    Details_Examen VARCHAR2(200),
    Date_Examen DATE,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION getDate RETURN DATE,
    -- Méthode d'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE, 
    -- Gestion des liens
    MEMBER PROCEDURE linkToConsultation(c REF CONSULTATION_T), 
    -- Consultation
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T, 
    -- Méthode CRUD (update)
    MEMBER PROCEDURE updateDetails(newDetails VARCHAR2), 
    -- Méthode CRUD (delete)
    MEMBER PROCEDURE deleteExamen                       
);
/

CREATE OR REPLACE TYPE setEXAMEN_T AS TABLE OF EXAMEN_T
/ 

-- Type PRESCRIPTION_T
CREATE OR REPLACE TYPE PRESCRIPTION_T AS OBJECT(
    Id_Prescription NUMBER(8),
    refConsultation REF CONSULTATION_T,
    Details_Prescription VARCHAR2(200),
    Date_Prescription DATE,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION getDate RETURN DATE,
    -- Méthode d'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE, 
    -- Gestion des liens
    MEMBER PROCEDURE linkToConsultation(c REF CONSULTATION_T), 
    -- Méthode de consultation : retourne la référence de la consultation associée
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T, 
    -- Méthode CRUD (update) : met à jour les détails de la prescription
    MEMBER PROCEDURE updateDetails(newDetails VARCHAR2), 
    -- Méthode CRUD (delete) : supprime la prescription
    MEMBER PROCEDURE deletePrescription                   
);
/

CREATE OR REPLACE TYPE setPRESCRIPTION_T AS TABLE OF PRESCRIPTION_T
/ 

-- Type FACTURE_T
CREATE OR REPLACE TYPE FACTURE_T AS OBJECT(
    Id_Facture NUMBER(8),
    refPatient REF PATIENT_T,
    refConsultation REF CONSULTATION_T,
    Montant_Total NUMBER(7,2),
    Date_Facture DATE,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION getDate RETURN DATE,
    -- Méthode d'ordre 
    MAP MEMBER FUNCTION compareDate RETURN DATE, 
    -- Gestion des liens
    MEMBER PROCEDURE linkToPatient(p REF PATIENT_T), 
    -- Gestion des liens
    MEMBER PROCEDURE linkToConsultation(c REF CONSULTATION_T), 
    -- Consultation : retourne LA REFERENCE du patient associé au facture
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T, 
    -- Consultation : retourne LA REFERENCE de la consultation associée au facture
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T, 
     -- Méthode CRUD (update) : met à jour le montant de la facture
    MEMBER PROCEDURE updateMontant(newMontant NUMBER),
    -- Méthode CRUD (delete) : supprime la facture
    MEMBER PROCEDURE deleteFacture                     
);
/

CREATE OR REPLACE TYPE setFACTURES_T AS TABLE OF FACTURE_T
/ 

-- Type CONSULTATION_T
CREATE OR REPLACE TYPE CONSULTATION_T AS OBJECT(
    Id_Consultation NUMBER(8),
    refPatient REF PATIENT_T,
    refMedecin REF MEDECIN_T,
    Raison VARCHAR2(200),
    Diagnostic VARCHAR2(200),
    Date_Consultation DATE,
    pListRefExamens ListRefExamens_t,
    pListRefPrescriptions ListRefPrescriptions_t,

    -- Méthodes
    static FUNCTION getConsultation(idConsultation in NUMBER) RETURN CONSULTATION_T,
    static FUNCTION getExamenInfo (idConsultation in NUMBER) RETURN setEXAMEN_T,
    static FUNCTION getPrescriptionInfo (idConsultation in NUMBER) RETURN setPRESCRIPTION_T,
    member PROCEDURE addLinkListeExamen(refExamen1 REF EXAMEN_T),
    member PROCEDURE deleteLinkListeExamen(refExamen1 REF EXAMEN_T),
    member PROCEDURE updateLinkListeExamen(refExamen1 REF EXAMEN_T, refExamen2 REF EXAMEN_T),
    member PROCEDURE addLinkListePrescription(refPrescription1 REF PRESCRIPTION_T),
    member PROCEDURE deleteLinkListePrescription(refPrescription1 REF PRESCRIPTION_T),
    member PROCEDURE updateLinkListePrescription(refPrescription1 REF PRESCRIPTION_T, refPrescription2 REF PRESCRIPTION_T),
    MAP MEMBER FUNCTION compareDate RETURN DATE                  
);
/

CREATE OR REPLACE TYPE setCONSULTATIONS_T AS TABLE OF CONSULTATION_T
/ 

-- Type PERSONNE_T
CREATE OR REPLACE TYPE PERSONNE_T AS OBJECT(
    ID_PERSONNE NUMBER(8),
    NUMERO_SECURITE_SOCIALE VARCHAR2(12),
    NOM VARCHAR2(12),
    EMAIL VARCHAR2(30),
    ADRESSE ADRESSE_T,
    SEXE VARCHAR2(10),
    DATE_NAISSANCE DATE,
    LIST_TELEPHONES LIST_TELEPHONES_T,
    LIST_PRENOMS LIST_PRENOMS_T,
     -- Méthode d'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE
) NOT INSTANTIABLE NOT FINAL;
/


-- Type PATIENT_T
CREATE OR REPLACE TYPE PATIENT_T UNDER PERSONNE_T(
    POIDS NUMBER(3),
    HAUTEUR NUMBER(3),
    pListRefRendezVous ListRefRendezVous_t,
    pListRefConsultations ListRefConsultations_t,
    pListRefFactures ListRefFactures_t,

    -- Méthodes
    STATIC FUNCTION  getPatient(idPersonne in number) RETURN PATIENT_T,
    STATIC FUNCTION  getFActureInfo(idPersonne in number) RETURN setFACTURES_T,
    STATIC FUNCTION  getConsultationInfo(idPersonne in number) RETURN setCONSULTATIONS_T,
    member PROCEDURE addLinkListeRendezVous(refRendezVous1 REF RENDEZ_VOUS_T),
    member PROCEDURE deleteLinkListeRendezVous(refRendezVous1 REF RENDEZ_VOUS_T),
    member PROCEDURE updateLinkListeRendezVous(refRendezVous1 REF RENDEZ_VOUS_T, refRendezVous2 REF RENDEZ_VOUS_T),
    member PROCEDURE addLinkListeFactures(refFacture1 REF FACTURE_T),
    member PROCEDURE deleteLinkListeFactures(refFacture1 REF FACTURE_T),
    member PROCEDURE updateLinkListeFactures(refFacture1 REF FACTURE_T, refFacture2 REF FACTURE_T),
    member PROCEDURE addLinkListeConsultations(refConsultation1 REF CONSULTATION_T),
    member PROCEDURE deleteLinkListeConsultations(refConsultation1 REF CONSULTATION_T),
    member PROCEDURE updateLinkListeConsultations(refConsultation1 REF CONSULTATION_T, refConsultation2 REF CONSULTATION_T)                  
);
/

CREATE OR REPLACE TYPE setPATIENTS_T AS TABLE OF PATIENT_T
/

-- Type MEDECIN_T
CREATE OR REPLACE TYPE MEDECIN_T UNDER PERSONNE_T(
    Specialite VARCHAR2(40),
    CV CLOB,
    pListRefRendezVous ListRefRendezVous_t,
    pListRefConsultations ListRefConsultations_t,

    -- Méthodes
    Static FUNCTION getMedecin(idMedecin in NUMBER) RETURN MEDECIN_T,
    static FUNCTION getConsultationInfo(idMedecin in NUMBER) RETURN setCONSULTATIONS_T,
    static FUNCTION getRendezVousInfo(idMedecin in NUMBER) RETURN setRENDEZ_VOUS_T,
    member PROCEDURE addLinkListeRendezVous(refRendezVous1 REF RENDEZ_VOUS_T),
    member PROCEDURE deleteLinkListeRendezVous(refRendezVous1 REF RENDEZ_VOUS_T),
    member PROCEDURE updateLinkListeRendezVous(refRendezVous1 REF RENDEZ_VOUS_T, refRendezVous2 REF RENDEZ_VOUS_T),
    member PROCEDURE addLinkListeConsultations(refConsultation1 REF CONSULTATION_T),
    member PROCEDURE deleteLinkListeConsultations(refConsultation1 REF CONSULTATION_T),
    member PROCEDURE updateLinkListeConsultations(refConsultation1 REF CONSULTATION_T, refConsultation2 REF CONSULTATION_T)                          
);
/


-- CREATION DES TABLES OBJETS A PARTIR DES TYPES 	 
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
/

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
/


CREATE TABLE O_EXAMEN OF EXAMEN_T(
	CONSTRAINT pk_o_examen_id_examen PRIMARY KEY(Id_Examen),
	refConsultation CONSTRAINT o_examen_ref_consultation_not_null NOT NULL,
	Details_Examen CONSTRAINT details_examen_not_null NOT NULL,
	Date_Examen CONSTRAINT date_examen_not_null NOT NULL
)
/

CREATE TABLE O_PRESCRIPTION OF PRESCRIPTION_T(
	CONSTRAINT pk_o_prescription_id_prescription PRIMARY KEY(Id_Prescription),
	refConsultation CONSTRAINT o_prescription_ref_consultation_not_null NOT NULL,
	Details_Prescription CONSTRAINT details_prescription_not_null NOT NULL,
	Date_Prescription CONSTRAINT date_prescription_not_null NOT NULL
)
/

CREATE TABLE O_FACTURE OF FACTURE_T(	
	CONSTRAINT pk_o_facture_id_facture PRIMARY KEY(Id_Facture),
	refPatient CONSTRAINT o_facture_ref_patient_not_null NOT NULL,
	refConsultation CONSTRAINT o_facture_ref_consultation_not_null NOT NULL,
	Montant_Total CONSTRAINT montant_total_not_null NOT NULL,
	Date_Facture CONSTRAINT date_facture_not_null NOT NULL
)
/

CREATE TABLE O_RENDEZ_VOUS OF RENDEZ_VOUS_T(
	CONSTRAINT pk_o_rendez_vous_id_rendez_vous PRIMARY KEY(Id_Rendez_Vous),
	refPatient CONSTRAINT o_rendez_vous_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_rendez_vous_ref_medecin_not_null NOT NULL,
	Date_Rendez_Vous CONSTRAINT date_rendez_vous_not_null NOT NULL,
	Motif CONSTRAINT motif_not_null NOT NULL
)
/

CREATE TABLE O_CONSULTATION OF CONSULTATION_T(
	CONSTRAINT pk_o_consultation_id_consultation PRIMARY KEY(Id_Consultation),
	refPatient CONSTRAINT o_consultation_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_consultation_ref_medecin_not_null NOT NULL,
	Raison CONSTRAINT raison_not_null NOT NULL,
	Date_Consultation CONSTRAINT date_consultation_not_null NOT NULL
) 
NESTED TABLE pListRefExamens STORE AS table_pListRefExamens
NESTED TABLE pListRefPrescriptions STORE AS table_pListRefPrescriptions
/

-- CREATION DES INDEX
DROP INDEX idx_o_patient_email_unique;
CREATE UNIQUE INDEX idx_o_patient_email_unique ON O_PATIENT(Email);

DROP INDEX idx_o_patient_num_sec_social_unique;
CREATE UNIQUE INDEX idx_o_patient_num_sec_social_unique ON O_PATIENT(Numero_Securite_Sociale);

DROP INDEX idx_o_medecin_email_unique;
CREATE UNIQUE INDEX idx_o_medecin_email_unique ON O_MEDECIN(Email);

DROP INDEX idx_o_medecin_num_sec_social_unique;
CREATE UNIQUE INDEX idx_o_medecin_num_sec_social_unique ON O_MEDECIN(Numero_Securite_Sociale);

DROP INDEX idx_o_medecin_specialite;
CREATE INDEX idx_o_medecin_specialite ON O_MEDECIN(Specialite);

DROP INDEX idx_o_facture_montant_total;
CREATE INDEX idx_o_facture_montant_total ON O_FACTURE(Montant_Total);

DROP INDEX IDX_O_RENDEZ_VOUS_refPatient;
ALTER TABLE O_RENDEZ_VOUS ADD (SCOPE FOR (refPatient) IS O_PATIENT);
CREATE INDEX IDX_O_RENDEZ_VOUS_refPatient ON O_RENDEZ_VOUS(refPatient);

DROP INDEX IDX_O_RENDEZ_VOUS_refMedecin;
ALTER TABLE O_RENDEZ_VOUS ADD (SCOPE FOR (refMedecin) IS O_MEDECIN);
CREATE INDEX IDX_O_RENDEZ_VOUS_refMedecin ON O_RENDEZ_VOUS(refMedecin);

DROP INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique;
CREATE UNIQUE INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique ON O_RENDEZ_VOUS(refPatient, refMedecin, Date_Rendez_Vous);

DROP INDEX IDX_O_FACTURE_refPatient;
ALTER TABLE O_FACTURE ADD (SCOPE FOR (refPatient) IS O_PATIENT);
CREATE INDEX IDX_O_FACTURE_refPatient ON O_FACTURE(refPatient);

DROP INDEX IDX_O_CONSULTATION_refPatient;
ALTER TABLE O_CONSULTATION ADD (SCOPE FOR (refPatient) IS O_PATIENT);
CREATE INDEX IDX_O_CONSULTATION_refPatient ON O_CONSULTATION(refPatient);

DROP INDEX IDX_O_CONSULTATION_refMedecin;
ALTER TABLE O_CONSULTATION ADD (SCOPE FOR (refMedecin) IS O_MEDECIN);
CREATE INDEX IDX_O_CONSULTATION_refMedecin ON O_CONSULTATION(refMedecin);

DROP INDEX idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique;
CREATE UNIQUE INDEX idx_O_CONSULTATION_ref_patient_ref_medecin_date_unique ON O_CONSULTATION(refPatient, refMedecin, Date_Consultation);

DROP INDEX IDX_O_FACTURE_refConsultation;
ALTER TABLE O_FACTURE ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
CREATE INDEX IDX_O_FACTURE_refConsultation ON O_FACTURE(refConsultation);

DROP INDEX IDX_O_PRESCRIPTION_refConsultation;
ALTER TABLE O_PRESCRIPTION ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
CREATE INDEX IDX_O_PRESCRIPTION_refConsultation ON O_PRESCRIPTION(refConsultation);

DROP INDEX IDX_O_EXAMEN_refConsultation;
ALTER TABLE O_EXAMEN ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
CREATE INDEX IDX_O_EXAMEN_refConsultation ON O_EXAMEN(refConsultation);

DROP INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value;
ALTER TABLE o_medecin_table_pListRefConsultations ADD (SCOPE FOR (column_value) IS O_CONSULTATION);
CREATE UNIQUE INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value ON o_medecin_table_pListRefConsultations(Nested_table_id, Column_value);

DROP INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value;
ALTER TABLE o_medecin_table_pListRefRendezVous ADD (SCOPE FOR (column_value) IS O_RENDEZ_VOUS);
CREATE UNIQUE INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value ON o_medecin_table_pListRefRendezVous(Nested_table_id, Column_value);

DROP INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value;
ALTER TABLE o_patient_table_pListRefConsultations ADD (SCOPE FOR (column_value) IS O_CONSULTATION);
CREATE UNIQUE INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value ON o_patient_table_pListRefConsultations(Nested_table_id, Column_value);

DROP INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value;
ALTER TABLE o_patient_table_pListRefRendezVous ADD (SCOPE FOR (column_value) IS O_RENDEZ_VOUS);
CREATE UNIQUE INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value ON o_patient_table_pListRefRendezVous(Nested_table_id, Column_value);

DROP INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value;
ALTER TABLE o_patient_table_pListRefFactures ADD (SCOPE FOR (column_value) IS O_FACTURE);
CREATE UNIQUE INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value ON o_patient_table_pListRefFactures(Nested_table_id, Column_value);

DROP INDEX idx_table_pListRefExamens_Nested_table_id_Column_value;
ALTER TABLE table_pListRefExamens ADD (SCOPE FOR (column_value) IS O_EXAMEN);
CREATE UNIQUE INDEX idx_table_pListRefExamens_Nested_table_id_Column_value ON table_pListRefExamens(Nested_table_id, Column_value);

DROP INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value;
ALTER TABLE table_pListRefPrescriptions ADD (SCOPE FOR (column_value) IS O_PRESCRIPTION);
CREATE UNIQUE INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value ON table_pListRefPrescriptions(Nested_table_id, Column_value);


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


 
 
 
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 -- Deuxième application écrite en relationnel  ---------------------
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 
 -- Création des tables relationnelles
 
 
alter table R_CONSULTATION
   drop constraint FK_R_CONSULTA_EFFECTUER_MEDECIN;

alter table R_CONSULTATION
   drop constraint FK_R_CONSULTA_INCLURE_FACTURE;

alter table R_CONSULTATION
   drop constraint FK_R_CONSULTA_PASSER_PATIENT;

alter table R_EXAMEN
   drop constraint FK_R_EXAMEN_CONTENIR__CONSULTA;

alter table R_FACTURE
   drop constraint FK_R_FACTURE_RECEVOIR_PATIENT;

alter table R_PRESCRIPTION
   drop constraint FK_R_PRESCRIP_CONTENIR__CONSULTA;

alter table R_RENDEZ_VOUS
   drop constraint FK_R_RENDEZ_V_RENDEZ_VO_MEDECIN;

alter table R_RENDEZ_VOUS
   drop constraint FK_R_RENDEZ_V_RENDEZ_VO_PATIENT;

drop table R_CONSULTATION cascade constraints;

drop table R_EXAMEN cascade constraints;

drop table R_FACTURE cascade constraints;

drop table R_MEDECIN cascade constraints;

drop table R_PATIENT cascade constraints;

drop table R_PRESCRIPTION cascade constraints;

drop table R_RENDEZ_VOUS cascade constraints;

/*==============================================================*/
/* Table : R_CONSULTATION                                         */
/*==============================================================*/
create table R_CONSULTATION 
(
   ID_CONSULTATION_     INTEGER              not null,
   ID_FACTURE_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   DATE_CONSULTATION    DATE                 not null,
   constraint PK_R_CONSULTATION primary key (ID_CONSULTATION_)
);

/*==============================================================*/
/* Table : R_EXAMEN                                               */
/*==============================================================*/
create table R_EXAMEN 
(
   ID_EXAMEN_           INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_EXAMEN       VARCHAR2(100)        not null,
   DATE_EXAMEN          DATE                 not null,
   constraint PK_R_EXAMEN primary key (ID_EXAMEN_)
);

/*==============================================================*/
/* Table : R_FACTURE                                              */
/*==============================================================*/
create table R_FACTURE 
(
   ID_FACTURE_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   MONTANT_TOTAL        NUMBER(15,2)         not null,
   DATE_FACTURE         DATE                 not null,
   constraint PK_R_FACTURE primary key (ID_FACTURE_)
);

/*==============================================================*/
/* Table : R_MEDECIN                                              */
/*==============================================================*/
create table R_MEDECIN 
(
   ID_MEDECIN_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   SPECIALITE           VARCHAR2(50)         not null,
   TELEPHONE            VARCHAR2(8)          not null,
   EMAIL                VARCHAR2(50)         not null,
   constraint PK_R_MEDECIN primary key (ID_MEDECIN_)
);

/*==============================================================*/
/* Table : R_PATIENT                                              */
/*==============================================================*/
create table R_PATIENT 
(
   ID_PATIENT_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   ADRESSE              VARCHAR2(100),
   EMAIL                VARCHAR2(50),
   DATE_NAISSAINCE      DATE                 not null,
   constraint PK_R_PATIENT primary key (ID_PATIENT_)
);

/*==============================================================*/
/* Table : R_PRESCRIPTION                                         */
/*==============================================================*/
create table R_PRESCRIPTION 
(
   ID_PRESCRIPTION_     INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_PRESCRIPTION VARCHAR2(100)        not null,
   DATE_PRESCRIPTION    DATE                 not null,
   constraint PK_R_PRESCRIPTION primary key (ID_PRESCRIPTION_)
);

/*==============================================================*/
/* Table : R_RENDEZ_VOUS                                          */
/*==============================================================*/
create table R_RENDEZ_VOUS 
(
   ID_PATIENT_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   DATE_RENDEZ_VOUS     DATE                 not null,
   constraint PK_R_RENDEZ_VOUS primary key (ID_PATIENT_, ID_MEDECIN_)
);


alter table R_CONSULTATION
   add constraint FK_R_CONSULTA_EFFECTUER_MEDECIN foreign key (ID_MEDECIN_)
      references R_MEDECIN (ID_MEDECIN_);

alter table R_CONSULTATION
   add constraint FK_R_CONSULTA_INCLURE_FACTURE foreign key (ID_FACTURE_)
      references R_FACTURE (ID_FACTURE_);

alter table R_CONSULTATION
   add constraint FK_R_CONSULTA_PASSER_PATIENT foreign key (ID_PATIENT_)
      references R_PATIENT (ID_PATIENT_);

alter table R_EXAMEN
   add constraint FK_R_EXAMEN_CONTENIR__CONSULTA foreign key (ID_CONSULTATION_)
      references R_CONSULTATION (ID_CONSULTATION_);

alter table R_FACTURE
   add constraint FK_R_FACTURE_RECEVOIR_PATIENT foreign key (ID_PATIENT_)
      references R_PATIENT (ID_PATIENT_);

alter table R_PRESCRIPTION
   add constraint FK_R_PRESCRIP_CONTENIR__CONSULTA foreign key (ID_CONSULTATION_)
      references R_CONSULTATION (ID_CONSULTATION_);

alter table R_RENDEZ_VOUS
   add constraint FK_R_RENDEZ_V_RENDEZ_VO_MEDECIN foreign key (ID_MEDECIN_)
      references R_MEDECIN (ID_MEDECIN_);

alter table R_RENDEZ_VOUS
   add constraint FK_R_RENDEZ_V_RENDEZ_VO_PATIENT foreign key (ID_PATIENT_)
      references R_PATIENT (ID_PATIENT_);


-- creation d'INDEXE

create index idx_R_PATIENT_EMAIL on R_PATIENT(EMAIL);
/

create index idx_R_FACTURE_MONTANT_TOTAL  on R_FACTURE(MONTANT_TOTAL);
/

create index idx_R_EXAMEN_DATE_EXAMEN  on R_EXAMEN(DATE_EXAMEN);
/

create index idx_R_EXAMEN_ID_CONSULTATION_  on R_EXAMEN(ID_CONSULTATION_);
/

create index idx_R_CONSULTATION_DATE_CONSULTATION  on R_CONSULTATION(DATE_CONSULTATION);
/

create index idx_R_PRESCRIPTION_DATE_PRESCRIPTION on R_PRESCRIPTION(DATE_PRESCRIPTION);
/

create index idx_R_RENDEZ_VOUS_ID_PATIENT_  on R_RENDEZ_VOUS(ID_PATIENT_);
/

-- Donn�es pour la table R_MEDECIN
--R_MEDECIN (ID_MEDECIN_, NOM, PRENOM, SPECIALITE, TELEPHONE, EMAIL)
INSERT INTO R_MEDECIN VALUES ( 1, 'Dupont', 'Jean', 'Cardiologue', '01234567', 'jean.dupont@email.com');
INSERT INTO R_MEDECIN VALUES ( 2, 'Martin', 'Sophie', 'Dermatologue', '02345678', 'sophie.martin@email.com');
INSERT INTO R_MEDECIN VALUES ( 3, 'Lefevre', 'Pierre', 'G�n�raliste', '03456789', 'pierre.lefevre@email.com');
INSERT INTO R_MEDECIN VALUES ( 4, 'Leroy', 'Isabelle', 'Ophtalmologue', '04567890', 'isabelle.leroy@email.com');
INSERT INTO R_MEDECIN VALUES ( 5, 'Girard', 'Philippe', 'Chirurgien', '05678901', 'philippe.girard@email.com');
INSERT INTO R_MEDECIN VALUES ( 6, 'Bertrand', 'Marie', 'Gyn�cologue', '06789012', 'marie.bertrand@email.com');
INSERT INTO R_MEDECIN VALUES ( 7, 'Lemoine', 'Fran�ois', 'P�diatre', '07890123', 'francois.lemoine@email.com');
INSERT INTO R_MEDECIN VALUES ( 8, 'Roy', 'Catherine', 'Orthop�diste', '08901234', 'catherine.roy@email.com');
INSERT INTO R_MEDECIN VALUES ( 9, 'Moulin', 'Alexandre', 'Neurologue', '09012345', 'alexandre.moulin@email.com');
INSERT INTO R_MEDECIN VALUES ( 10, 'Marchand', 'Caroline', 'Rhumatologue', '01234567', 'caroline.marchand@email.com');
INSERT INTO R_MEDECIN VALUES (11, 'Dubois', 'Pierre', 'Cardiologue', '01234568', 'pierre.dubois@email.com');
INSERT INTO R_MEDECIN VALUES (12, 'Lefebvre', 'Sophie', 'Dermatologue', '01234569', 'sophie.lefebvre@email.com');
INSERT INTO R_MEDECIN VALUES (13, 'Martin', 'Luc', 'Ophtalmologue', '01234570', 'luc.martin@email.com');
INSERT INTO R_MEDECIN VALUES (14, 'Thomas', 'Marie', 'Psychiatre', '01234571', 'marie.thomas@email.com');
INSERT INTO R_MEDECIN VALUES (15, 'Garcia', 'Jean', 'Gynécologue', '01234572', 'jean.garcia@email.com');
INSERT INTO R_MEDECIN VALUES (16, 'Legrand', 'Isabelle', 'Pédiatre', '01234573', 'isabelle.legrand@email.com');
INSERT INTO R_MEDECIN VALUES (17, 'Moreau', 'Philippe', 'Chirurgien', '01234574', 'philippe.moreau@email.com');
INSERT INTO R_MEDECIN VALUES (18, 'Petit', 'Carlos', 'Oncologue', '01234575', 'carlos.petit@email.com');
INSERT INTO R_MEDECIN VALUES (19, 'Sanchez', 'Émilie', 'Neurologue', '01234576', 'emilie.sanchez@email.com');
INSERT INTO R_MEDECIN VALUES (20, 'Robert', 'Antoine', 'Endocrinologue', '01234577', 'antoine.robert@email.com');


-- Donn�es pour la table R_PATIENT
--INSERT INTO R_PATIENT (ID_PATIENT_, NOM, PRENOM, ADRESSE, EMAIL, DATE_NAISSAINCE)
INSERT INTO R_PATIENT VALUES(1, 'Dubois', 'Alice', '123 Rue de la Paix', 'alice.dubois@email.com', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(2, 'Leclerc', 'Thomas', '456 Avenue des Roses', 'thomas.leclerc@email.com', TO_DATE('1985-08-22', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(3, 'Moreau', 'Sophie', '789 Boulevard du Soleil', 'sophie.moreau@email.com', TO_DATE('1995-02-10', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(4, 'Leroy', 'Jean', '101 Rue de la Lune', 'jean.leroy@email.com', TO_DATE('1980-12-01', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(5, 'Girard', 'Isabelle', '202 Avenue des �toiles', 'isabelle.girard@email.com', TO_DATE('1992-09-18', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(6, 'Bertrand', 'Luc', '303 Boulevard de la Galaxie', 'luc.bertrand@email.com', TO_DATE('1987-04-25', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(7, 'Lemoine', 'Sophie', '404 Rue des Plan�tes', 'sophie.lemoine@email.com', TO_DATE('1998-07-03', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(8, 'Roy', 'Pierre', '505 Avenue de la Voie Lact�e', 'pierre.roy@email.com', TO_DATE('1983-10-12', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(9, 'Moulin', 'Caroline', '606 Boulevard des Com�tes', 'caroline.moulin@email.com', TO_DATE('1994-03-28', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(10, 'Marchand', 'Alexandre', '707 Rue des Ast�ro�des', 'alexandre.marchand@email.com', TO_DATE('1988-06-15', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(11, 'Dubois', 'Sophie', '123 Rue de la Paix', 'sophie.dubois@email.com', TO_DATE('1990-03-22', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(12, 'Lefebvre', 'Pierre', '456 Avenue des Champs-Élysées', 'pierre.lefebvre@email.com', TO_DATE('1985-11-10', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(13, 'Martin', 'Charlotte', '789 Boulevard Voltaire', 'charlotte.martin@email.com', TO_DATE('1995-09-28', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(14, 'Thomas', 'Luc', '1010 Rue de Rivoli', 'luc.thomas@email.com', TO_DATE('1977-07-17', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(15, 'Garcia', 'Maria', '222 Rue du Faubourg Saint-Honoré', 'maria.garcia@email.com', TO_DATE('1983-12-03', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(16, 'Legrand', 'Jean', '333 Avenue Montaigne', 'jean.legrand@email.com', TO_DATE('1992-05-20', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(17, 'Moreau', 'Isabelle', '444 Boulevard Haussmann', 'isabelle.moreau@email.com', TO_DATE('1979-08-12', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(18, 'Petit', 'Philippe', '555 Rue de la Liberté', 'philippe.petit@email.com', TO_DATE('1989-04-25', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(19, 'Sanchez', 'Carlos', '666 Avenue Foch', 'carlos.sanchez@email.com', TO_DATE('1980-02-09', 'YYYY-MM-DD'));
INSERT INTO R_PATIENT VALUES(20, 'Robert', 'Émilie', '777 Boulevard des Capucines', 'emilie.robert@email.com', TO_DATE('1993-10-15', 'YYYY-MM-DD'));

-- Donn�es pour la table R_FACTURE
--INSERT INTO R_FACTURE (ID_FACTURE_, ID_PATIENT_, MONTANT_TOTAL, DATE_FACTURE) 
INSERT INTO R_FACTURE VALUES( 101, 1, 150.50, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 102, 2, 200.75, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 103, 3, 120.00, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 104, 4, 180.25, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 105, 5, 250.00, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 106, 6, 300.50, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 107, 7, 170.75, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 108, 8, 220.00, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 109, 9, 190.20, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 110, 10, 280.75, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 111, 3, 150.50, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 112, 9, 200.75, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 113, 4, 120.00, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 114, 8, 180.25, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 115, 7, 250.00, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 116, 3, 300.50, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 117, 8, 170.75, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 118, 4, 220.00, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 119, 10, 190.20, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO R_FACTURE VALUES( 120, 8, 280.75, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table R_CONSULTATION
--INSERT INTO R_CONSULTATION (ID_CONSULTATION_, ID_FACTURE_, ID_MEDECIN_, ID_PATIENT_, DATE_CONSULTATION)
INSERT INTO R_CONSULTATION VALUES( 1, 101, 1, 1, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 2, 102, 2, 2, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 3, 103, 3, 3, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 4, 104, 4, 4, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 5, 105, 5, 5, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 6, 106, 6, 6, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 7, 107, 7, 7, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 8, 108, 8, 8, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 9, 109, 9, 9, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 10, 110, 10, 10, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 11, 111, 1, 1, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 12, 112, 2, 2, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 13, 113, 3, 3, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 14, 114, 4, 4, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 15, 115, 5, 5, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 16, 116, 6, 6, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 17, 117, 7, 7, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 18, 118, 8, 8, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 19, 119, 9, 9, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO R_CONSULTATION VALUES( 20, 120, 10, 10, TO_DATE('2024-02-25', 'YYYY-MM-DD'));


-- Donn�es pour la table R_EXAMEN
--INSERT INTO R_EXAMEN (ID_EXAMEN_, ID_CONSULTATION_, DETAILS_EXAMEN, DATE_EXAMEN)
INSERT INTO R_EXAMEN VALUES(1, 1, '�lectrocardiogramme', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(2, 2, 'Dermatoscopie', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(3, 3, 'Bilan sanguin', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(4, 4, 'R_EXAMEN ophtalmologique', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(5, 5, 'Chirurgie du genou', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(6, 6, '�chographie gyn�cologique', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(7, 7, 'Vaccination p�diatrique', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(8, 8, 'Radiographie orthop�dique', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(9, 9, 'IRM c�r�brale', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(10, 10, 'Scintigraphie articulaire', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(11, 11, 'IRM cérébrale', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(12, 12, 'Échographie cardiaque', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(13, 13, 'Radiographie thoracique', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(14, 14, 'Scanner abdominal', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(15, 15, 'Électrocardiogramme', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(16, 16, 'Endoscopie digestive', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(17, 17, 'IRM lombaire', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(18, 18, 'Mammographie', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(19, 19, 'Échographie rénale', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO R_EXAMEN VALUES(20, 20, 'Coloscopie', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table R_PRESCRIPTION
--INSERT INTO R_PRESCRIPTION (ID_PRESCRIPTION_, ID_CONSULTATION_, DETAILS_PRESCRIPTION, DATE_PRESCRIPTION)
INSERT INTO R_PRESCRIPTION VALUES(1, 1, 'Aspirine quotidienne', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(2, 2, 'Cr�me solaire SPF 30', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(3, 3, 'Antibiotiques', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(4, 4, 'Collyre pour les yeux', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(5, 5, 'Repos postop�ratoire', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(6, 6, 'Contr�le gyn�cologique annuel', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(7, 7, 'Vitamines pour enfants', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(8, 8, 'Attelle pour le genou', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(9, 9, 'Traitement neurologique', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(10, 10, 'Anti-inflammatoires', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(11, 11, 'Antibiotiques', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(12, 12, 'Analgesiques', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(13, 13, 'Antihypertenseurs', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(14, 14, 'Anticoagulants', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(15, 15, 'Antidépresseurs', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(16, 16, 'Antispasmodiques', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(17, 17, 'Antihistaminiques', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(18, 18, 'Antiemétiques', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(19, 19, 'Antifongiques', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO R_PRESCRIPTION VALUES(20, 20, 'Anticonvulsivants', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table R_RENDEZ_VOUS
--INSERT INTO R_RENDEZ_VOUS (ID_PATIENT_, ID_MEDECIN_, DATE_RENDEZ_VOUS)
INSERT INTO R_RENDEZ_VOUS VALUES(1, 1, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(2, 2, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(3, 3, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(4, 4, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(5, 5, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(6, 6, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(7, 7, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(8, 8, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(9, 9, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO R_RENDEZ_VOUS VALUES(10, 10, TO_DATE('2024-02-19', 'YYYY-MM-DD'));



 COMMIT;
 
 
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 -- Troisième application écrite en relationnel les tables sont organisees dans des segments séparés ---------------------
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 
 -- -- Créer des tablespaces
CREATE TABLESPACE CONSULTATION_tbs
DATAFILE 'CONSULTATION_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE EXAMEN_tbs
DATAFILE 'EXAMEN_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE FACTURE_tbs
DATAFILE 'FACTURE_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE MEDECIN_tbs
DATAFILE 'MEDECIN_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE PATIENT_tbs
DATAFILE 'PATIENT_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE PRESCRIPTION_tbs
DATAFILE 'PRESCRIPTION_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE RENDEZ_VOUS_tbs
DATAFILE 'RENDEZ_VOUS_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

CREATE TABLESPACE INDEX_tbs
DATAFILE 'INDEX_tbs_datafile.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
AUTOALLOCATE;

-- CREE DES TABLES


alter table CONSULTATION
   drop constraint FK_CONSULTA_EFFECTUER_MEDECIN;

alter table CONSULTATION
   drop constraint FK_CONSULTA_INCLURE_FACTURE;

alter table CONSULTATION
   drop constraint FK_CONSULTA_PASSER_PATIENT;

alter table EXAMEN
   drop constraint FK_EXAMEN_CONTENIR__CONSULTA;

alter table FACTURE
   drop constraint FK_FACTURE_RECEVOIR_PATIENT;

alter table PRESCRIPTION
   drop constraint FK_PRESCRIP_CONTENIR__CONSULTA;

alter table RENDEZ_VOUS
   drop constraint FK_RENDEZ_V_RENDEZ_VO_MEDECIN;

alter table RENDEZ_VOUS
   drop constraint FK_RENDEZ_V_RENDEZ_VO_PATIENT;

drop table CONSULTATION cascade constraints;

drop table EXAMEN cascade constraints;

drop table FACTURE cascade constraints;

drop table MEDECIN cascade constraints;

drop table PATIENT cascade constraints;

drop table PRESCRIPTION cascade constraints;

drop table RENDEZ_VOUS cascade constraints;

/*==============================================================*/
/* Table : CONSULTATION                                         */
/*==============================================================*/
create table CONSULTATION 
(
   ID_CONSULTATION_     INTEGER              not null,
   ID_FACTURE_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   DATE_CONSULTATION    DATE                 not null,
   constraint PK_CONSULTATION primary key (ID_CONSULTATION_)
)
TABLESPACE CONSULTATION_tbs;

/*==============================================================*/
/* Table : EXAMEN                                               */
/*==============================================================*/
create table EXAMEN 
(
   ID_EXAMEN_           INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_EXAMEN       VARCHAR2(100)        not null,
   DATE_EXAMEN          DATE                 not null,
   constraint PK_EXAMEN primary key (ID_EXAMEN_)
)
TABLESPACE EXAMEN_tbs;

/*==============================================================*/
/* Table : FACTURE                                              */
/*==============================================================*/
create table FACTURE 
(
   ID_FACTURE_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   MONTANT_TOTAL        NUMBER(15,2)         not null,
   DATE_FACTURE         DATE                 not null,
   constraint PK_FACTURE primary key (ID_FACTURE_)
)
TABLESPACE FACTURE_tbs;

/*==============================================================*/
/* Table : MEDECIN                                              */
/*==============================================================*/
create table MEDECIN 
(
   ID_MEDECIN_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   SPECIALITE           VARCHAR2(50)         not null,
   TELEPHONE            VARCHAR2(8)          not null,
   EMAIL                VARCHAR2(50)         not null,
   constraint PK_MEDECIN primary key (ID_MEDECIN_)
)
TABLESPACE MEDECIN_tbs;

/*==============================================================*/
/* Table : PATIENT                                              */
/*==============================================================*/
create table PATIENT 
(
   ID_PATIENT_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   ADRESSE              VARCHAR2(100),
   EMAIL                VARCHAR2(50),
   DATE_NAISSAINCE      DATE                 not null,
   constraint PK_PATIENT primary key (ID_PATIENT_)
)
TABLESPACE PATIENT_tbs;

/*==============================================================*/
/* Table : PRESCRIPTION                                         */
/*==============================================================*/
create table PRESCRIPTION 
(
   ID_PRESCRIPTION_     INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_PRESCRIPTION VARCHAR2(100)        not null,
   DATE_PRESCRIPTION    DATE                 not null,
   constraint PK_PRESCRIPTION primary key (ID_PRESCRIPTION_)
)
TABLESPACE PRESCRIPTION_tbs;

/*==============================================================*/
/* Table : RENDEZ_VOUS                                          */
/*==============================================================*/
create table RENDEZ_VOUS 
(
   ID_PATIENT_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   DATE_RENDEZ_VOUS     DATE                 not null,
   constraint PK_RENDEZ_VOUS primary key (ID_PATIENT_, ID_MEDECIN_)
)
TABLESPACE RENDEZ_VOUS_tbs;


alter table CONSULTATION
   add constraint FK_CONSULTA_EFFECTUER_MEDECIN foreign key (ID_MEDECIN_)
      references MEDECIN (ID_MEDECIN_);

alter table CONSULTATION
   add constraint FK_CONSULTA_INCLURE_FACTURE foreign key (ID_FACTURE_)
      references FACTURE (ID_FACTURE_);

alter table CONSULTATION
   add constraint FK_CONSULTA_PASSER_PATIENT foreign key (ID_PATIENT_)
      references PATIENT (ID_PATIENT_);

alter table EXAMEN
   add constraint FK_EXAMEN_CONTENIR__CONSULTA foreign key (ID_CONSULTATION_)
      references CONSULTATION (ID_CONSULTATION_);

alter table FACTURE
   add constraint FK_FACTURE_RECEVOIR_PATIENT foreign key (ID_PATIENT_)
      references PATIENT (ID_PATIENT_);

alter table PRESCRIPTION
   add constraint FK_PRESCRIP_CONTENIR__CONSULTA foreign key (ID_CONSULTATION_)
      references CONSULTATION (ID_CONSULTATION_);

alter table RENDEZ_VOUS
   add constraint FK_RENDEZ_V_RENDEZ_VO_MEDECIN foreign key (ID_MEDECIN_)
      references MEDECIN (ID_MEDECIN_);

alter table RENDEZ_VOUS
   add constraint FK_RENDEZ_V_RENDEZ_VO_PATIENT foreign key (ID_PATIENT_)
      references PATIENT (ID_PATIENT_);


-- creation d'INDEXE

create index idx_PATIENT_EMAIL on PATIENT(EMAIL)
 TABLESPACE INDEX_tbs;
/

create index idx_FACTURE_MONTANT_TOTAL  on FACTURE(MONTANT_TOTAL)
 TABLESPACE INDEX_tbs;
/

create index idx_EXAMEN_DATE_EXAMEN  on EXAMEN(DATE_EXAMEN)
 TABLESPACE INDEX_tbs;
/

create index idx_EXAMEN_ID_CONSULTATION_  on EXAMEN(ID_CONSULTATION_)
 TABLESPACE INDEX_tbs;
/

create index idx_CONSULTATION_DATE_CONSULTATION  on CONSULTATION(DATE_CONSULTATION)
 TABLESPACE INDEX_tbs;
/

create index idx_PRESCRIPTION_DATE_PRESCRIPTION on PRESCRIPTION(DATE_PRESCRIPTION)
 TABLESPACE INDEX_tbs;
/

create index idx_RENDEZ_VOUS_ID_PATIENT_  on RENDEZ_VOUS(ID_PATIENT_)
 TABLESPACE INDEX_tbs;
/


-- Donn�es pour la table MEDECIN
--MEDECIN (ID_MEDECIN_, NOM, PRENOM, SPECIALITE, TELEPHONE, EMAIL)
INSERT INTO MEDECIN VALUES ( 1, 'Dupont', 'Jean', 'Cardiologue', '01234567', 'jean.dupont@email.com');
INSERT INTO MEDECIN VALUES ( 2, 'Martin', 'Sophie', 'Dermatologue', '02345678', 'sophie.martin@email.com');
INSERT INTO MEDECIN VALUES ( 3, 'Lefevre', 'Pierre', 'G�n�raliste', '03456789', 'pierre.lefevre@email.com');
INSERT INTO MEDECIN VALUES ( 4, 'Leroy', 'Isabelle', 'Ophtalmologue', '04567890', 'isabelle.leroy@email.com');
INSERT INTO MEDECIN VALUES ( 5, 'Girard', 'Philippe', 'Chirurgien', '05678901', 'philippe.girard@email.com');
INSERT INTO MEDECIN VALUES ( 6, 'Bertrand', 'Marie', 'Gyn�cologue', '06789012', 'marie.bertrand@email.com');
INSERT INTO MEDECIN VALUES ( 7, 'Lemoine', 'Fran�ois', 'P�diatre', '07890123', 'francois.lemoine@email.com');
INSERT INTO MEDECIN VALUES ( 8, 'Roy', 'Catherine', 'Orthop�diste', '08901234', 'catherine.roy@email.com');
INSERT INTO MEDECIN VALUES ( 9, 'Moulin', 'Alexandre', 'Neurologue', '09012345', 'alexandre.moulin@email.com');
INSERT INTO MEDECIN VALUES ( 10, 'Marchand', 'Caroline', 'Rhumatologue', '01234567', 'caroline.marchand@email.com');
INSERT INTO MEDECIN VALUES (11, 'Dubois', 'Pierre', 'Cardiologue', '01234568', 'pierre.dubois@email.com');
INSERT INTO MEDECIN VALUES (12, 'Lefebvre', 'Sophie', 'Dermatologue', '01234569', 'sophie.lefebvre@email.com');
INSERT INTO MEDECIN VALUES (13, 'Martin', 'Luc', 'Ophtalmologue', '01234570', 'luc.martin@email.com');
INSERT INTO MEDECIN VALUES (14, 'Thomas', 'Marie', 'Psychiatre', '01234571', 'marie.thomas@email.com');
INSERT INTO MEDECIN VALUES (15, 'Garcia', 'Jean', 'Gynécologue', '01234572', 'jean.garcia@email.com');
INSERT INTO MEDECIN VALUES (16, 'Legrand', 'Isabelle', 'Pédiatre', '01234573', 'isabelle.legrand@email.com');
INSERT INTO MEDECIN VALUES (17, 'Moreau', 'Philippe', 'Chirurgien', '01234574', 'philippe.moreau@email.com');
INSERT INTO MEDECIN VALUES (18, 'Petit', 'Carlos', 'Oncologue', '01234575', 'carlos.petit@email.com');
INSERT INTO MEDECIN VALUES (19, 'Sanchez', 'Émilie', 'Neurologue', '01234576', 'emilie.sanchez@email.com');
INSERT INTO MEDECIN VALUES (20, 'Robert', 'Antoine', 'Endocrinologue', '01234577', 'antoine.robert@email.com');


-- Donn�es pour la table PATIENT
--INSERT INTO PATIENT (ID_PATIENT_, NOM, PRENOM, ADRESSE, EMAIL, DATE_NAISSAINCE)
INSERT INTO PATIENT VALUES(1, 'Dubois', 'Alice', '123 Rue de la Paix', 'alice.dubois@email.com', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(2, 'Leclerc', 'Thomas', '456 Avenue des Roses', 'thomas.leclerc@email.com', TO_DATE('1985-08-22', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(3, 'Moreau', 'Sophie', '789 Boulevard du Soleil', 'sophie.moreau@email.com', TO_DATE('1995-02-10', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(4, 'Leroy', 'Jean', '101 Rue de la Lune', 'jean.leroy@email.com', TO_DATE('1980-12-01', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(5, 'Girard', 'Isabelle', '202 Avenue des �toiles', 'isabelle.girard@email.com', TO_DATE('1992-09-18', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(6, 'Bertrand', 'Luc', '303 Boulevard de la Galaxie', 'luc.bertrand@email.com', TO_DATE('1987-04-25', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(7, 'Lemoine', 'Sophie', '404 Rue des Plan�tes', 'sophie.lemoine@email.com', TO_DATE('1998-07-03', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(8, 'Roy', 'Pierre', '505 Avenue de la Voie Lact�e', 'pierre.roy@email.com', TO_DATE('1983-10-12', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(9, 'Moulin', 'Caroline', '606 Boulevard des Com�tes', 'caroline.moulin@email.com', TO_DATE('1994-03-28', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(10, 'Marchand', 'Alexandre', '707 Rue des Ast�ro�des', 'alexandre.marchand@email.com', TO_DATE('1988-06-15', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(11, 'Dubois', 'Sophie', '123 Rue de la Paix', 'sophie.dubois@email.com', TO_DATE('1990-03-22', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(12, 'Lefebvre', 'Pierre', '456 Avenue des Champs-Élysées', 'pierre.lefebvre@email.com', TO_DATE('1985-11-10', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(13, 'Martin', 'Charlotte', '789 Boulevard Voltaire', 'charlotte.martin@email.com', TO_DATE('1995-09-28', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(14, 'Thomas', 'Luc', '1010 Rue de Rivoli', 'luc.thomas@email.com', TO_DATE('1977-07-17', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(15, 'Garcia', 'Maria', '222 Rue du Faubourg Saint-Honoré', 'maria.garcia@email.com', TO_DATE('1983-12-03', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(16, 'Legrand', 'Jean', '333 Avenue Montaigne', 'jean.legrand@email.com', TO_DATE('1992-05-20', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(17, 'Moreau', 'Isabelle', '444 Boulevard Haussmann', 'isabelle.moreau@email.com', TO_DATE('1979-08-12', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(18, 'Petit', 'Philippe', '555 Rue de la Liberté', 'philippe.petit@email.com', TO_DATE('1989-04-25', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(19, 'Sanchez', 'Carlos', '666 Avenue Foch', 'carlos.sanchez@email.com', TO_DATE('1980-02-09', 'YYYY-MM-DD'));
INSERT INTO PATIENT VALUES(20, 'Robert', 'Émilie', '777 Boulevard des Capucines', 'emilie.robert@email.com', TO_DATE('1993-10-15', 'YYYY-MM-DD'));

-- Donn�es pour la table FACTURE
--INSERT INTO FACTURE (ID_FACTURE_, ID_PATIENT_, MONTANT_TOTAL, DATE_FACTURE) 
INSERT INTO FACTURE VALUES( 101, 1, 150.50, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 102, 2, 200.75, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 103, 3, 120.00, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 104, 4, 180.25, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 105, 5, 250.00, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 106, 6, 300.50, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 107, 7, 170.75, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 108, 8, 220.00, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 109, 9, 190.20, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 110, 10, 280.75, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 111, 3, 150.50, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 112, 9, 200.75, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 113, 4, 120.00, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 114, 8, 180.25, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 115, 7, 250.00, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 116, 3, 300.50, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 117, 8, 170.75, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 118, 4, 220.00, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 119, 10, 190.20, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO FACTURE VALUES( 120, 8, 280.75, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table CONSULTATION
--INSERT INTO CONSULTATION (ID_CONSULTATION_, ID_FACTURE_, ID_MEDECIN_, ID_PATIENT_, DATE_CONSULTATION)
INSERT INTO CONSULTATION VALUES( 1, 101, 1, 1, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 2, 102, 2, 2, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 3, 103, 3, 3, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 4, 104, 4, 4, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 5, 105, 5, 5, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 6, 106, 6, 6, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 7, 107, 7, 7, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 8, 108, 8, 8, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 9, 109, 9, 9, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 10, 110, 10, 10, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 11, 111, 1, 1, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 12, 112, 2, 2, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 13, 113, 3, 3, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 14, 114, 4, 4, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 15, 115, 5, 5, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 16, 116, 6, 6, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 17, 117, 7, 7, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 18, 118, 8, 8, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 19, 119, 9, 9, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO CONSULTATION VALUES( 20, 120, 10, 10, TO_DATE('2024-02-25', 'YYYY-MM-DD'));


-- Donn�es pour la table EXAMEN
--INSERT INTO EXAMEN (ID_EXAMEN_, ID_CONSULTATION_, DETAILS_EXAMEN, DATE_EXAMEN)
INSERT INTO EXAMEN VALUES(1, 1, '�lectrocardiogramme', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(2, 2, 'Dermatoscopie', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(3, 3, 'Bilan sanguin', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(4, 4, 'Examen ophtalmologique', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(5, 5, 'Chirurgie du genou', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(6, 6, '�chographie gyn�cologique', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(7, 7, 'Vaccination p�diatrique', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(8, 8, 'Radiographie orthop�dique', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(9, 9, 'IRM c�r�brale', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(10, 10, 'Scintigraphie articulaire', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(11, 11, 'IRM cérébrale', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(12, 12, 'Échographie cardiaque', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(13, 13, 'Radiographie thoracique', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(14, 14, 'Scanner abdominal', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(15, 15, 'Électrocardiogramme', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(16, 16, 'Endoscopie digestive', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(17, 17, 'IRM lombaire', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(18, 18, 'Mammographie', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(19, 19, 'Échographie rénale', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO EXAMEN VALUES(20, 20, 'Coloscopie', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table PRESCRIPTION
--INSERT INTO PRESCRIPTION (ID_PRESCRIPTION_, ID_CONSULTATION_, DETAILS_PRESCRIPTION, DATE_PRESCRIPTION)
INSERT INTO PRESCRIPTION VALUES(1, 1, 'Aspirine quotidienne', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(2, 2, 'Cr�me solaire SPF 30', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(3, 3, 'Antibiotiques', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(4, 4, 'Collyre pour les yeux', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(5, 5, 'Repos postop�ratoire', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(6, 6, 'Contr�le gyn�cologique annuel', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(7, 7, 'Vitamines pour enfants', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(8, 8, 'Attelle pour le genou', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(9, 9, 'Traitement neurologique', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(10, 10, 'Anti-inflammatoires', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(11, 11, 'Antibiotiques', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(12, 12, 'Analgesiques', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(13, 13, 'Antihypertenseurs', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(14, 14, 'Anticoagulants', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(15, 15, 'Antidépresseurs', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(16, 16, 'Antispasmodiques', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(17, 17, 'Antihistaminiques', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(18, 18, 'Antiemétiques', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(19, 19, 'Antifongiques', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO PRESCRIPTION VALUES(20, 20, 'Anticonvulsivants', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table RENDEZ_VOUS
--INSERT INTO RENDEZ_VOUS (ID_PATIENT_, ID_MEDECIN_, DATE_RENDEZ_VOUS)
INSERT INTO RENDEZ_VOUS VALUES(1, 1, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(2, 2, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(3, 3, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(4, 4, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(5, 5, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(6, 6, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(7, 7, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(8, 8, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(9, 9, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO RENDEZ_VOUS VALUES(10, 10, TO_DATE('2024-02-19', 'YYYY-MM-DD'));

COMMIT;

 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
 -- 4ème écrite en relationnel mais les tables sont organisées dans un cluster indexé -------------------------
 --------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------
DROP CLUSTER CLU_ICONSUL_IPRESCRIP_IEXAM INCLUDING TABLES;
 
-- Création du cluster
CREATE CLUSTER CLU_ICONSUL_IPRESCRIP_IEXAM (
ID_CONSULTATION_     INTEGER 
);

-- Création de l'index sur la clé de cluster
CREATE INDEX IDX_CLU_ICONSUL_IPRESCRIP_IEXAM
ON CLUSTER CLU_ICONSUL_IPRESCRIP_IEXAM;

-- CREATION TABLE

/*==============================================================*/
/* Table : ICONSULTATION                                         */
/*==============================================================*/
-- Création de la table ICONSULTATION dans le cluster
CREATE TABLE ICONSULTATION(
  ID_CONSULTATION_     INTEGER              not null,
   ID_FACTURE_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   DATE_CONSULTATION    DATE                 not null,
   constraint PK_ICONSULTATION primary key (ID_CONSULTATION_)) CLUSTER CLU_ICONSUL_IPRESCRIP_IEXAM (ID_CONSULTATION_);


/*==============================================================*/
/* Table : IEXAMEN                                               */
/*==============================================================*/
-- Création de la table IEXAMEN dans le cluster
create table IEXAMEN 
(
   ID_EXAMEN_           INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_EXAMEN       VARCHAR2(100)        not null,
   DATE_EXAMEN          DATE                 not null,
   constraint PK_IEXAMEN primary key (ID_EXAMEN_))CLUSTER CLU_ICONSUL_IPRESCRIP_IEXAM (ID_CONSULTATION_);


/*==============================================================*/
/* Table : IFACTURE                                              */
/*==============================================================*/
create table IFACTURE 
(
   ID_FACTURE_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   MONTANT_TOTAL        NUMBER(15,2)         not null,
   DATE_FACTURE         DATE                 not null,
   constraint PK_IFACTURE primary key (ID_FACTURE_)
);

/*==============================================================*/
/* Table : IMEDECIN                                              */
/*==============================================================*/
create table IMEDECIN 
(
   ID_MEDECIN_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   SPECIALITE           VARCHAR2(50)         not null,
   TELEPHONE            VARCHAR2(8)          not null,
   EMAIL                VARCHAR2(50)         not null,
   constraint PK_IMEDECIN primary key (ID_MEDECIN_)
);

/*==============================================================*/
/* Table : IPATIENT                                              */
/*==============================================================*/
create table IPATIENT 
(
   ID_PATIENT_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   ADRESSE              VARCHAR2(100),
   EMAIL                VARCHAR2(50),
   DATE_NAISSAINCE      DATE                 not null,
   constraint PK_IPATIENT primary key (ID_PATIENT_)
);


/*==============================================================*/
/* Table : IPRESCRIPTION                                         */
/*==============================================================*/
-- Création de la table IPRESCRIPTION dans le cluster
create table IPRESCRIPTION 
(
   ID_PRESCRIPTION_     INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_PRESCRIPTION VARCHAR2(100)        not null,
   DATE_PRESCRIPTION    DATE                 not null,
   constraint PK_IPRESCRIPTION primary key (ID_PRESCRIPTION_))  CLUSTER CLU_ICONSUL_IPRESCRIP_IEXAM (ID_CONSULTATION_);


/*==============================================================*/
/* Table : IRENDEZ_VOUS                                          */
/*==============================================================*/
create table IRENDEZ_VOUS 
(
   ID_PATIENT_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   DATE_RENDEZ_VOUS     DATE                 not null,
   constraint PK_IRENDEZ_VOUS primary key (ID_PATIENT_, ID_MEDECIN_)
);

-- Donn�es pour la table IMEDECIN
--IMEDECIN (ID_MEDECIN_, NOM, PRENOM, SPECIALITE, TELEPHONE, EMAIL)
INSERT INTO IMEDECIN VALUES ( 1, 'Dupont', 'Jean', 'Cardiologue', '01234567', 'jean.dupont@email.com');
INSERT INTO IMEDECIN VALUES ( 2, 'Martin', 'Sophie', 'Dermatologue', '02345678', 'sophie.martin@email.com');
INSERT INTO IMEDECIN VALUES ( 3, 'Lefevre', 'Pierre', 'G�n�raliste', '03456789', 'pierre.lefevre@email.com');
INSERT INTO IMEDECIN VALUES ( 4, 'Leroy', 'Isabelle', 'Ophtalmologue', '04567890', 'isabelle.leroy@email.com');
INSERT INTO IMEDECIN VALUES ( 5, 'Girard', 'Philippe', 'Chirurgien', '05678901', 'philippe.girard@email.com');
INSERT INTO IMEDECIN VALUES ( 6, 'Bertrand', 'Marie', 'Gyn�cologue', '06789012', 'marie.bertrand@email.com');
INSERT INTO IMEDECIN VALUES ( 7, 'Lemoine', 'Fran�ois', 'P�diatre', '07890123', 'francois.lemoine@email.com');
INSERT INTO IMEDECIN VALUES ( 8, 'Roy', 'Catherine', 'Orthop�diste', '08901234', 'catherine.roy@email.com');
INSERT INTO IMEDECIN VALUES ( 9, 'Moulin', 'Alexandre', 'Neurologue', '09012345', 'alexandre.moulin@email.com');
INSERT INTO IMEDECIN VALUES ( 10, 'Marchand', 'Caroline', 'Rhumatologue', '01234567', 'caroline.marchand@email.com');
INSERT INTO IMEDECIN VALUES (11, 'Dubois', 'Pierre', 'Cardiologue', '01234568', 'pierre.dubois@email.com');
INSERT INTO IMEDECIN VALUES (12, 'Lefebvre', 'Sophie', 'Dermatologue', '01234569', 'sophie.lefebvre@email.com');
INSERT INTO IMEDECIN VALUES (13, 'Martin', 'Luc', 'Ophtalmologue', '01234570', 'luc.martin@email.com');
INSERT INTO IMEDECIN VALUES (14, 'Thomas', 'Marie', 'Psychiatre', '01234571', 'marie.thomas@email.com');
INSERT INTO IMEDECIN VALUES (15, 'Garcia', 'Jean', 'Gynécologue', '01234572', 'jean.garcia@email.com');
INSERT INTO IMEDECIN VALUES (16, 'Legrand', 'Isabelle', 'Pédiatre', '01234573', 'isabelle.legrand@email.com');
INSERT INTO IMEDECIN VALUES (17, 'Moreau', 'Philippe', 'Chirurgien', '01234574', 'philippe.moreau@email.com');
INSERT INTO IMEDECIN VALUES (18, 'Petit', 'Carlos', 'Oncologue', '01234575', 'carlos.petit@email.com');
INSERT INTO IMEDECIN VALUES (19, 'Sanchez', 'Émilie', 'Neurologue', '01234576', 'emilie.sanchez@email.com');
INSERT INTO IMEDECIN VALUES (20, 'Robert', 'Antoine', 'Endocrinologue', '01234577', 'antoine.robert@email.com');


-- Donn�es pour la table IPATIENT
--INSERT INTO IPATIENT (ID_PATIENT_, NOM, PRENOM, ADRESSE, EMAIL, DATE_NAISSAINCE)
INSERT INTO IPATIENT VALUES(1, 'Dubois', 'Alice', '123 Rue de la Paix', 'alice.dubois@email.com', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(2, 'Leclerc', 'Thomas', '456 Avenue des Roses', 'thomas.leclerc@email.com', TO_DATE('1985-08-22', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(3, 'Moreau', 'Sophie', '789 Boulevard du Soleil', 'sophie.moreau@email.com', TO_DATE('1995-02-10', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(4, 'Leroy', 'Jean', '101 Rue de la Lune', 'jean.leroy@email.com', TO_DATE('1980-12-01', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(5, 'Girard', 'Isabelle', '202 Avenue des �toiles', 'isabelle.girard@email.com', TO_DATE('1992-09-18', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(6, 'Bertrand', 'Luc', '303 Boulevard de la Galaxie', 'luc.bertrand@email.com', TO_DATE('1987-04-25', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(7, 'Lemoine', 'Sophie', '404 Rue des Plan�tes', 'sophie.lemoine@email.com', TO_DATE('1998-07-03', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(8, 'Roy', 'Pierre', '505 Avenue de la Voie Lact�e', 'pierre.roy@email.com', TO_DATE('1983-10-12', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(9, 'Moulin', 'Caroline', '606 Boulevard des Com�tes', 'caroline.moulin@email.com', TO_DATE('1994-03-28', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(10, 'Marchand', 'Alexandre', '707 Rue des Ast�ro�des', 'alexandre.marchand@email.com', TO_DATE('1988-06-15', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(11, 'Dubois', 'Sophie', '123 Rue de la Paix', 'sophie.dubois@email.com', TO_DATE('1990-03-22', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(12, 'Lefebvre', 'Pierre', '456 Avenue des Champs-Élysées', 'pierre.lefebvre@email.com', TO_DATE('1985-11-10', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(13, 'Martin', 'Charlotte', '789 Boulevard Voltaire', 'charlotte.martin@email.com', TO_DATE('1995-09-28', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(14, 'Thomas', 'Luc', '1010 Rue de Rivoli', 'luc.thomas@email.com', TO_DATE('1977-07-17', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(15, 'Garcia', 'Maria', '222 Rue du Faubourg Saint-Honoré', 'maria.garcia@email.com', TO_DATE('1983-12-03', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(16, 'Legrand', 'Jean', '333 Avenue Montaigne', 'jean.legrand@email.com', TO_DATE('1992-05-20', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(17, 'Moreau', 'Isabelle', '444 Boulevard Haussmann', 'isabelle.moreau@email.com', TO_DATE('1979-08-12', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(18, 'Petit', 'Philippe', '555 Rue de la Liberté', 'philippe.petit@email.com', TO_DATE('1989-04-25', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(19, 'Sanchez', 'Carlos', '666 Avenue Foch', 'carlos.sanchez@email.com', TO_DATE('1980-02-09', 'YYYY-MM-DD'));
INSERT INTO IPATIENT VALUES(20, 'Robert', 'Émilie', '777 Boulevard des Capucines', 'emilie.robert@email.com', TO_DATE('1993-10-15', 'YYYY-MM-DD'));

-- Donn�es pour la table IFACTURE
--INSERT INTO IFACTURE (ID_FACTURE_, ID_PATIENT_, MONTANT_TOTAL, DATE_FACTURE) 
INSERT INTO IFACTURE VALUES( 101, 1, 150.50, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 102, 2, 200.75, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 103, 3, 120.00, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 104, 4, 180.25, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 105, 5, 250.00, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 106, 6, 300.50, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 107, 7, 170.75, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 108, 8, 220.00, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 109, 9, 190.20, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 110, 10, 280.75, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 111, 3, 150.50, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 112, 9, 200.75, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 113, 4, 120.00, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 114, 8, 180.25, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 115, 7, 250.00, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 116, 3, 300.50, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 117, 8, 170.75, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 118, 4, 220.00, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 119, 10, 190.20, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO IFACTURE VALUES( 120, 8, 280.75, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table ICONSULTATION
--INSERT INTO ICONSULTATION (ID_CONSULTATION_, ID_FACTURE_, ID_MEDECIN_, ID_PATIENT_, DATE_CONSULTATION)
INSERT INTO ICONSULTATION VALUES( 1, 101, 1, 1, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 2, 102, 2, 2, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 3, 103, 3, 3, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 4, 104, 4, 4, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 5, 105, 5, 5, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 6, 106, 6, 6, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 7, 107, 7, 7, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 8, 108, 8, 8, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 9, 109, 9, 9, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 10, 110, 10, 10, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 11, 111, 1, 1, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 12, 112, 2, 2, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 13, 113, 3, 3, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 14, 114, 4, 4, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 15, 115, 5, 5, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 16, 116, 6, 6, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 17, 117, 7, 7, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 18, 118, 8, 8, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 19, 119, 9, 9, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO ICONSULTATION VALUES( 20, 120, 10, 10, TO_DATE('2024-02-25', 'YYYY-MM-DD'));


-- Donn�es pour la table IEXAMEN
--INSERT INTO IEXAMEN (ID_EXAMEN_, ID_CONSULTATION_, DETAILS_EXAMEN, DATE_EXAMEN)
INSERT INTO IEXAMEN VALUES(1, 1, '�lectrocardiogramme', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(2, 2, 'Dermatoscopie', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(3, 3, 'Bilan sanguin', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(4, 4, 'IEXAMEN ophtalmologique', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(5, 5, 'Chirurgie du genou', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(6, 6, '�chographie gyn�cologique', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(7, 7, 'Vaccination p�diatrique', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(8, 8, 'Radiographie orthop�dique', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(9, 9, 'IRM c�r�brale', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(10, 10, 'Scintigraphie articulaire', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(11, 11, 'IRM cérébrale', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(12, 12, 'Échographie cardiaque', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(13, 13, 'Radiographie thoracique', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(14, 14, 'Scanner abdominal', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(15, 15, 'Électrocardiogramme', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(16, 16, 'Endoscopie digestive', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(17, 17, 'IRM lombaire', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(18, 18, 'Mammographie', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(19, 19, 'Échographie rénale', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO IEXAMEN VALUES(20, 20, 'Coloscopie', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table IPRESCRIPTION
--INSERT INTO IPRESCRIPTION (ID_PRESCRIPTION_, ID_CONSULTATION_, DETAILS_PRESCRIPTION, DATE_PRESCRIPTION)
INSERT INTO IPRESCRIPTION VALUES(1, 1, 'Aspirine quotidienne', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(2, 2, 'Cr�me solaire SPF 30', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(3, 3, 'Antibiotiques', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(4, 4, 'Collyre pour les yeux', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(5, 5, 'Repos postop�ratoire', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(6, 6, 'Contr�le gyn�cologique annuel', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(7, 7, 'Vitamines pour enfants', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(8, 8, 'Attelle pour le genou', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(9, 9, 'Traitement neurologique', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(10, 10, 'Anti-inflammatoires', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(11, 11, 'Antibiotiques', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(12, 12, 'Analgesiques', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(13, 13, 'Antihypertenseurs', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(14, 14, 'Anticoagulants', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(15, 15, 'Antidépresseurs', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(16, 16, 'Antispasmodiques', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(17, 17, 'Antihistaminiques', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(18, 18, 'Antiemétiques', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(19, 19, 'Antifongiques', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO IPRESCRIPTION VALUES(20, 20, 'Anticonvulsivants', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table IRENDEZ_VOUS
--INSERT INTO IRENDEZ_VOUS (ID_PATIENT_, ID_MEDECIN_, DATE_RENDEZ_VOUS)
INSERT INTO IRENDEZ_VOUS VALUES(1, 1, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(2, 2, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(3, 3, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(4, 4, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(5, 5, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(6, 6, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(7, 7, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(8, 8, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(9, 9, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO IRENDEZ_VOUS VALUES(10, 10, TO_DATE('2024-02-19', 'YYYY-MM-DD'));

COMMIT;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--- La 5ème écrite en relationnel mais les tables sont organisées dans un cluster haché -----------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

DROP CLUSTER CLU_HCONSUL_HPRESCRIP_HEXAM INCLUDING TABLES; 
 
-- Création du cluster
CREATE CLUSTER CLU_HCONSUL_HPRESCRIP_HEXAM (
ID_CONSULTATION_     INTEGER 
) SIZE 2K HASH IS ID_CONSULTATION_ HASHKEYS 100;


/*==============================================================*/
/* Table : HCONSULTATION                                         */
/*==============================================================*/
-- Création de la table HCONSULTATION dans le cluster
CREATE TABLE HCONSULTATION(
  ID_CONSULTATION_     INTEGER              not null,
   ID_FACTURE_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   DATE_CONSULTATION    DATE                 not null,
   constraint PK_HCONSULTATION primary key (ID_CONSULTATION_)) CLUSTER CLU_HCONSUL_HPRESCRIP_HEXAM (ID_CONSULTATION_);


/*==============================================================*/
/* Table : HEXAMEN                                               */
/*==============================================================*/
-- Création de la table HEXAMEN dans le cluster
create table HEXAMEN 
(
   ID_EXAMEN_           INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_EXAMEN       VARCHAR2(100)        not null,
   DATE_EXAMEN          DATE                 not null,
   constraint PK_HEXAMEN primary key (ID_EXAMEN_))CLUSTER CLU_HCONSUL_HPRESCRIP_HEXAM (ID_CONSULTATION_);


/*==============================================================*/
/* Table : HFACTURE                                              */
/*==============================================================*/
create table HFACTURE 
(
   ID_FACTURE_          INTEGER              not null,
   ID_PATIENT_          INTEGER              not null,
   MONTANT_TOTAL        NUMBER(15,2)         not null,
   DATE_FACTURE         DATE                 not null,
   constraint PK_HFACTURE primary key (ID_FACTURE_)
);

/*==============================================================*/
/* Table : HMEDECIN                                              */
/*==============================================================*/
create table HMEDECIN 
(
   ID_MEDECIN_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   SPECIALITE           VARCHAR2(50)         not null,
   TELEPHONE            VARCHAR2(8)          not null,
   EMAIL                VARCHAR2(50)         not null,
   constraint PK_HMEDECIN primary key (ID_MEDECIN_)
);

/*==============================================================*/
/* Table : HPATIENT                                              */
/*==============================================================*/
create table HPATIENT 
(
   ID_PATIENT_          INTEGER              not null,
   NOM                  VARCHAR2(50)         not null,
   PRENOM               VARCHAR2(50)         not null,
   ADRESSE              VARCHAR2(100),
   EMAIL                VARCHAR2(50),
   DATE_NAISSAINCE      DATE                 not null,
   constraint PK_HPATIENT primary key (ID_PATIENT_)
);

/*==============================================================*/
/* Table : HPRESCRIPTION                                         */
/*==============================================================*/
-- Création de la table HPRESCRIPTION dans le cluster
create table HPRESCRIPTION 
(
   ID_PRESCRIPTION_     INTEGER              not null,
   ID_CONSULTATION_     INTEGER              not null,
   DETAILS_PRESCRIPTION VARCHAR2(100)        not null,
   DATE_PRESCRIPTION    DATE                 not null,
   constraint PK_HPRESCRIPTION primary key (ID_PRESCRIPTION_))CLUSTER CLU_HCONSUL_HPRESCRIP_HEXAM (ID_CONSULTATION_);

/*==============================================================*/
/* Table : HRENDEZ_VOUS                                          */
/*==============================================================*/
create table HRENDEZ_VOUS 
(
   ID_PATIENT_          INTEGER              not null,
   ID_MEDECIN_          INTEGER              not null,
   DATE_RENDEZ_VOUS     DATE                 not null,
   constraint IPK_HRENDEZ_VOUS primary key (ID_PATIENT_, ID_MEDECIN_)
);


-- Donn�es pour la table HMEDECIN
--HMEDECIN (ID_MEDECIN_, NOM, PRENOM, SPECIALITE, TELEPHONE, EMAIL)
INSERT INTO HMEDECIN VALUES ( 1, 'Dupont', 'Jean', 'Cardiologue', '01234567', 'jean.dupont@email.com');
INSERT INTO HMEDECIN VALUES ( 2, 'Martin', 'Sophie', 'Dermatologue', '02345678', 'sophie.martin@email.com');
INSERT INTO HMEDECIN VALUES ( 3, 'Lefevre', 'Pierre', 'G�n�raliste', '03456789', 'pierre.lefevre@email.com');
INSERT INTO HMEDECIN VALUES ( 4, 'Leroy', 'Isabelle', 'Ophtalmologue', '04567890', 'isabelle.leroy@email.com');
INSERT INTO HMEDECIN VALUES ( 5, 'Girard', 'Philippe', 'Chirurgien', '05678901', 'philippe.girard@email.com');
INSERT INTO HMEDECIN VALUES ( 6, 'Bertrand', 'Marie', 'Gyn�cologue', '06789012', 'marie.bertrand@email.com');
INSERT INTO HMEDECIN VALUES ( 7, 'Lemoine', 'Fran�ois', 'P�diatre', '07890123', 'francois.lemoine@email.com');
INSERT INTO HMEDECIN VALUES ( 8, 'Roy', 'Catherine', 'Orthop�diste', '08901234', 'catherine.roy@email.com');
INSERT INTO HMEDECIN VALUES ( 9, 'Moulin', 'Alexandre', 'Neurologue', '09012345', 'alexandre.moulin@email.com');
INSERT INTO HMEDECIN VALUES ( 10, 'Marchand', 'Caroline', 'Rhumatologue', '01234567', 'caroline.marchand@email.com');
INSERT INTO HMEDECIN VALUES (11, 'Dubois', 'Pierre', 'Cardiologue', '01234568', 'pierre.dubois@email.com');
INSERT INTO HMEDECIN VALUES (12, 'Lefebvre', 'Sophie', 'Dermatologue', '01234569', 'sophie.lefebvre@email.com');
INSERT INTO HMEDECIN VALUES (13, 'Martin', 'Luc', 'Ophtalmologue', '01234570', 'luc.martin@email.com');
INSERT INTO HMEDECIN VALUES (14, 'Thomas', 'Marie', 'Psychiatre', '01234571', 'marie.thomas@email.com');
INSERT INTO HMEDECIN VALUES (15, 'Garcia', 'Jean', 'Gynécologue', '01234572', 'jean.garcia@email.com');
INSERT INTO HMEDECIN VALUES (16, 'Legrand', 'Isabelle', 'Pédiatre', '01234573', 'isabelle.legrand@email.com');
INSERT INTO HMEDECIN VALUES (17, 'Moreau', 'Philippe', 'Chirurgien', '01234574', 'philippe.moreau@email.com');
INSERT INTO HMEDECIN VALUES (18, 'Petit', 'Carlos', 'Oncologue', '01234575', 'carlos.petit@email.com');
INSERT INTO HMEDECIN VALUES (19, 'Sanchez', 'Émilie', 'Neurologue', '01234576', 'emilie.sanchez@email.com');
INSERT INTO HMEDECIN VALUES (20, 'Robert', 'Antoine', 'Endocrinologue', '01234577', 'antoine.robert@email.com');


-- Donn�es pour la table HPATIENT
--INSERT INTO HPATIENT (ID_PATIENT_, NOM, PRENOM, ADRESSE, EMAIL, DATE_NAISSAINCE)
INSERT INTO HPATIENT VALUES(1, 'Dubois', 'Alice', '123 Rue de la Paix', 'alice.dubois@email.com', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(2, 'Leclerc', 'Thomas', '456 Avenue des Roses', 'thomas.leclerc@email.com', TO_DATE('1985-08-22', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(3, 'Moreau', 'Sophie', '789 Boulevard du Soleil', 'sophie.moreau@email.com', TO_DATE('1995-02-10', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(4, 'Leroy', 'Jean', '101 Rue de la Lune', 'jean.leroy@email.com', TO_DATE('1980-12-01', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(5, 'Girard', 'Isabelle', '202 Avenue des �toiles', 'isabelle.girard@email.com', TO_DATE('1992-09-18', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(6, 'Bertrand', 'Luc', '303 Boulevard de la Galaxie', 'luc.bertrand@email.com', TO_DATE('1987-04-25', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(7, 'Lemoine', 'Sophie', '404 Rue des Plan�tes', 'sophie.lemoine@email.com', TO_DATE('1998-07-03', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(8, 'Roy', 'Pierre', '505 Avenue de la Voie Lact�e', 'pierre.roy@email.com', TO_DATE('1983-10-12', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(9, 'Moulin', 'Caroline', '606 Boulevard des Com�tes', 'caroline.moulin@email.com', TO_DATE('1994-03-28', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(10, 'Marchand', 'Alexandre', '707 Rue des Ast�ro�des', 'alexandre.marchand@email.com', TO_DATE('1988-06-15', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(11, 'Dubois', 'Sophie', '123 Rue de la Paix', 'sophie.dubois@email.com', TO_DATE('1990-03-22', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(12, 'Lefebvre', 'Pierre', '456 Avenue des Champs-Élysées', 'pierre.lefebvre@email.com', TO_DATE('1985-11-10', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(13, 'Martin', 'Charlotte', '789 Boulevard Voltaire', 'charlotte.martin@email.com', TO_DATE('1995-09-28', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(14, 'Thomas', 'Luc', '1010 Rue de Rivoli', 'luc.thomas@email.com', TO_DATE('1977-07-17', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(15, 'Garcia', 'Maria', '222 Rue du Faubourg Saint-Honoré', 'maria.garcia@email.com', TO_DATE('1983-12-03', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(16, 'Legrand', 'Jean', '333 Avenue Montaigne', 'jean.legrand@email.com', TO_DATE('1992-05-20', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(17, 'Moreau', 'Isabelle', '444 Boulevard Haussmann', 'isabelle.moreau@email.com', TO_DATE('1979-08-12', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(18, 'Petit', 'Philippe', '555 Rue de la Liberté', 'philippe.petit@email.com', TO_DATE('1989-04-25', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(19, 'Sanchez', 'Carlos', '666 Avenue Foch', 'carlos.sanchez@email.com', TO_DATE('1980-02-09', 'YYYY-MM-DD'));
INSERT INTO HPATIENT VALUES(20, 'Robert', 'Émilie', '777 Boulevard des Capucines', 'emilie.robert@email.com', TO_DATE('1993-10-15', 'YYYY-MM-DD'));

-- Donn�es pour la table HFACTURE
--INSERT INTO HFACTURE (ID_FACTURE_, ID_PATIENT_, MONTANT_TOTAL, DATE_FACTURE) 
INSERT INTO HFACTURE VALUES( 101, 1, 150.50, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 102, 2, 200.75, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 103, 3, 120.00, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 104, 4, 180.25, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 105, 5, 250.00, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 106, 6, 300.50, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 107, 7, 170.75, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 108, 8, 220.00, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 109, 9, 190.20, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 110, 10, 280.75, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 111, 3, 150.50, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 112, 9, 200.75, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 113, 4, 120.00, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 114, 8, 180.25, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 115, 7, 250.00, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 116, 3, 300.50, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 117, 8, 170.75, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 118, 4, 220.00, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 119, 10, 190.20, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO HFACTURE VALUES( 120, 8, 280.75, TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table HCONSULTATION
--INSERT INTO HCONSULTATION (ID_CONSULTATION_, ID_FACTURE_, ID_MEDECIN_, ID_PATIENT_, DATE_CONSULTATION)
INSERT INTO HCONSULTATION VALUES( 1, 101, 1, 1, TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 2, 102, 2, 2, TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 3, 103, 3, 3, TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 4, 104, 4, 4, TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 5, 105, 5, 5, TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 6, 106, 6, 6, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 7, 107, 7, 7, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 8, 108, 8, 8, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 9, 109, 9, 9, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 10, 110, 10, 10, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 11, 111, 1, 1, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 12, 112, 2, 2, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 13, 113, 3, 3, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 14, 114, 4, 4, TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 15, 115, 5, 5, TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 16, 116, 6, 6, TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 17, 117, 7, 7, TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 18, 118, 8, 8, TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 19, 119, 9, 9, TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO HCONSULTATION VALUES( 20, 120, 10, 10, TO_DATE('2024-02-25', 'YYYY-MM-DD'));


-- Donn�es pour la table HEXAMEN
--INSERT INTO HEXAMEN (ID_EXAMEN_, ID_CONSULTATION_, DETAILS_EXAMEN, DATE_EXAMEN)
INSERT INTO HEXAMEN VALUES(1, 1, '�lectrocardiogramme', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(2, 2, 'Dermatoscopie', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(3, 3, 'Bilan sanguin', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(4, 4, 'HEXAMEN ophtalmologique', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(5, 5, 'Chirurgie du genou', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(6, 6, '�chographie gyn�cologique', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(7, 7, 'Vaccination p�diatrique', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(8, 8, 'Radiographie orthop�dique', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(9, 9, 'IRM c�r�brale', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(10, 10, 'Scintigraphie articulaire', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(11, 11, 'IRM cérébrale', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(12, 12, 'Échographie cardiaque', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(13, 13, 'Radiographie thoracique', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(14, 14, 'Scanner abdominal', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(15, 15, 'Électrocardiogramme', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(16, 16, 'Endoscopie digestive', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(17, 17, 'IRM lombaire', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(18, 18, 'Mammographie', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(19, 19, 'Échographie rénale', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO HEXAMEN VALUES(20, 20, 'Coloscopie', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table HPRESCRIPTION
--INSERT INTO HPRESCRIPTION (ID_PRESCRIPTION_, ID_CONSULTATION_, DETAILS_PRESCRIPTION, DATE_PRESCRIPTION)
INSERT INTO HPRESCRIPTION VALUES(1, 1, 'Aspirine quotidienne', TO_DATE('2024-02-05', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(2, 2, 'Cr�me solaire SPF 30', TO_DATE('2024-02-06', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(3, 3, 'Antibiotiques', TO_DATE('2024-02-07', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(4, 4, 'Collyre pour les yeux', TO_DATE('2024-02-08', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(5, 5, 'Repos postop�ratoire', TO_DATE('2024-02-09', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(6, 6, 'Contr�le gyn�cologique annuel', TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(7, 7, 'Vitamines pour enfants', TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(8, 8, 'Attelle pour le genou', TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(9, 9, 'Traitement neurologique', TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(10, 10, 'Anti-inflammatoires', TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(11, 11, 'Antibiotiques', TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(12, 12, 'Analgesiques', TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(13, 13, 'Antihypertenseurs', TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(14, 14, 'Anticoagulants', TO_DATE('2024-02-19', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(15, 15, 'Antidépresseurs', TO_DATE('2024-02-20', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(16, 16, 'Antispasmodiques', TO_DATE('2024-02-21', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(17, 17, 'Antihistaminiques', TO_DATE('2024-02-22', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(18, 18, 'Antiemétiques', TO_DATE('2024-02-23', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(19, 19, 'Antifongiques', TO_DATE('2024-02-24', 'YYYY-MM-DD'));
INSERT INTO HPRESCRIPTION VALUES(20, 20, 'Anticonvulsivants', TO_DATE('2024-02-25', 'YYYY-MM-DD'));

-- Donn�es pour la table HRENDEZ_VOUS
--INSERT INTO HRENDEZ_VOUS (ID_PATIENT_, ID_MEDECIN_, DATE_RENDEZ_VOUS)
INSERT INTO HRENDEZ_VOUS VALUES(1, 1, TO_DATE('2024-02-10', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(2, 2, TO_DATE('2024-02-11', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(3, 3, TO_DATE('2024-02-12', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(4, 4, TO_DATE('2024-02-13', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(5, 5, TO_DATE('2024-02-14', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(6, 6, TO_DATE('2024-02-15', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(7, 7, TO_DATE('2024-02-16', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(8, 8, TO_DATE('2024-02-17', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(9, 9, TO_DATE('2024-02-18', 'YYYY-MM-DD'));
INSERT INTO HRENDEZ_VOUS VALUES(10, 10, TO_DATE('2024-02-19', 'YYYY-MM-DD'));

COMMIT;

alter system checkpoint;

 --------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------
 -- Diverses requêtes sur les différentes applications créés ----------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------
 
 -- Calcul des statitisques sur les objets de HOPITAL
 Execute Dbms_stats.gather_schema_stats('HOPITAL');

 
 
 -- L'activation de la trace en traceonly évite l'affiche du
 -- résultat des réquêtes à l'écran.
 Set autotrace &TRACEOPTION
 set linesize 200
 -- Fixer l'optimizer de statistiques en mode first_rows_1
 Alter session set optimizer_mode=first_rows_1;
 

 -- Jointure avec des tables non clustérisées (CBO)
SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM CONSULTATION C, EXAMEN E , PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ ;


-- Jointure avec tables relationnelles en cluster indexé (CBO)
SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM ICONSULTATION C, IEXAMEN E , IPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ ;


-- Jointure avec tables en cluster haché (CBO)
SELECT /*+USE_HASH(C E P) */ C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM HCONSULTATION C, HEXAMEN E , HPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ ;


-- Fixer l'optimizer de statistiques en mode all_rows
Alter session set optimizer_mode=all_rows;


 -- Jointure avec des tables non clustérisées (CBO)
SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM CONSULTATION C, EXAMEN E , PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ ;


-- Jointure avec tables relationnelles en cluster indexé (CBO)
SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM ICONSULTATION C, IEXAMEN E , IPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ ;


-- Jointure avec tables en cluster haché (CBO)
SELECT /*+USE_HASH(C E P) */ C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM HCONSULTATION C, HEXAMEN E , HPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ ;


-- Fixer l'optimizer de statistiques en mode first_rows_1
Alter session set optimizer_mode=first_rows_1;

-- Comptage de lignes dans les tables CONSULTATION, ICONSULTATION et HCONSULTATION
select count(*) from CONSULTATION;

select count(*) from ICONSULTATION;

select count(*) from HCONSULTATION;


-- Fixer l'optimizer de statistiques en mode all_rows
Alter session set optimizer_mode=all_rows;


-- Comptage de lignes dans les tables CONSULTATION, ICONSULTATION et HCONSULTATION
select count(*) from CONSULTATION;

select count(*) from ICONSULTATION;

select count(*) from HCONSULTATION;


 -- Fixer l'optimizer de statistiques en mode first_rows_1
 Alter session set optimizer_mode=first_rows_1;
 
  
 -- Jointures connaissant un département donné.
 set autotrace &TRACEOPTION
 
 SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM CONSULTATION C, EXAMEN E , PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;


SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM ICONSULTATION C, IEXAMEN E , IPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;

SELECT /*+USE_HASH(C E P) */ C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM HCONSULTATION C, HEXAMEN E , HPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;


 -- Fixer l'optimizer de statistiques en mode all_rows
 Alter session set optimizer_mode=all_rows;

 SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM CONSULTATION C, EXAMEN E , PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;


SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM ICONSULTATION C, IEXAMEN E , IPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;

SELECT /*+USE_HASH(C E P) */ C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM HCONSULTATION C, HEXAMEN E , HPRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;


 -- Fixer l'optimizer de statistiques en mode first_rows_1
 Alter session set optimizer_mode=first_rows_1;

 -- Recherche des examens d'une  consultation connu.
SELECT ID_EXAMEN_ , DETAILS_EXAMEN, DATE_EXAMEN FROM EXAMEN
WHERE ID_CONSULTATION_ = 1;

SELECT ID_EXAMEN_ , DETAILS_EXAMEN, DATE_EXAMEN FROM IEXAMEN
WHERE ID_CONSULTATION_ = 1;

SELECT ID_EXAMEN_ , DETAILS_EXAMEN, DATE_EXAMEN FROM HEXAMEN
WHERE ID_CONSULTATION_ = 1;



 -- Fixer l'optimizer de statistiques en mode all_rows
 Alter session set optimizer_mode=all_rows;
 
  -- Recherche des examens d'une  consultation connu.
SELECT ID_EXAMEN_ , DETAILS_EXAMEN, DATE_EXAMEN FROM EXAMEN
WHERE ID_CONSULTATION_ = 1;

SELECT ID_EXAMEN_ , DETAILS_EXAMEN, DATE_EXAMEN FROM IEXAMEN
WHERE ID_CONSULTATION_ = 1;

SELECT ID_EXAMEN_ , DETAILS_EXAMEN, DATE_EXAMEN FROM HEXAMEN
WHERE ID_CONSULTATION_ = 1;


 
 
 -- Consultations comparées sur les tables objets et les tables relationnelles
 
 set autotrace &TRACEOPTION
 set linesize 300
 -- Consultation en mode FIRST_ROWS_1
 alter session set optimizer_mode=FIRST_ROWS_1;
 
 
 -- Recherche des informations sur les examens (+info consultation) d'une consultation connaissant son numéro
 -- Via la table des examens. Tables objets
select E.ID_EXAMEN, E.REFCONSULTATION.DIAGNOSTIC, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.REFCONSULTATION.ID_CONSULTATION =1 ;


select /*+INDEX (e IDX_O_EXAMEN_refConsultation)*/ E.ID_EXAMEN, E.REFCONSULTATION.DIAGNOSTIC, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.REFCONSULTATION.ID_CONSULTATION =1 ;

 -- Recherche des informations sur les examens  d'une consultation connaissant son numéro
 -- Via la table des examens. Tables objets  
select E.ID_EXAMEN, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.REFCONSULTATION.ID_CONSULTATION =1 ;


 -- Recherche des informations sur les examens d'une consultation connaissant son numéro
 -- Via la liste des références vers les examens dudit consultation: tables objets
SELECT  LEXA.COLUMN_VALUE.ID_EXAMEN, LEXA.COLUMN_VALUE.DETAILS_EXAMEN, LEXA.COLUMN_VALUE.DATE_EXAMEN FROM TABLE(SELECT C.PLISTREFEXAMENS FROM O_CONSULTATION C WHERE C.ID_CONSULTATION = 1) LEXA;



 SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM R_CONSULTATION C, R_EXAMEN E , R_PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;


 -- Recherche des informations sur une consultation connaissant un examen de ce
 -- Via la liste des références vers les examens dudit consultation: tables objets
SELECT E.REFCONSULTATION.DIAGNOSTIC, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.ID_EXAMEN = 2 ;


 SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM R_CONSULTATION C, R_EXAMEN E , R_PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND E.ID_EXAMEN_ = 2;



 -- Consultation en mode all_rows
 alter session set optimizer_mode=all_rows;
 
 -- Recherche des informations sur les examens  d'une consultation connaissant son numéro
 -- Via la table des examens. Tables objets  
select E.ID_EXAMEN, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.REFCONSULTATION.ID_CONSULTATION =1 ;


select /*+INDEX (e IDX_O_EXAMEN_refConsultation)*/ E.ID_EXAMEN, E.REFCONSULTATION.DIAGNOSTIC, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.REFCONSULTATION.ID_CONSULTATION =1 ;


 -- Recherche des informations sur les examens d'une consultation connaissant son numéro
 -- Via la liste des références vers les examens dudit consultation: tables objets
SELECT  LEXA.COLUMN_VALUE.ID_EXAMEN, LEXA.COLUMN_VALUE.DETAILS_EXAMEN, LEXA.COLUMN_VALUE.DATE_EXAMEN FROM TABLE(SELECT C.PLISTREFEXAMENS FROM O_CONSULTATION C WHERE C.ID_CONSULTATION = 1) LEXA;


 SELECT C.DATE_CONSULTATION,E.DETAILS_EXAMEN,E.DATE_EXAMEN, P.DETAILS_PRESCRIPTION, P.DATE_PRESCRIPTION FROM R_CONSULTATION C, R_EXAMEN E , R_PRESCRIPTION P
WHERE C.ID_CONSULTATION_ = E.ID_EXAMEN_
AND C.ID_CONSULTATION_ = P.ID_PRESCRIPTION_ 
AND C.ID_CONSULTATION_ = 1;

 -- Recherche des informations sur une consultation connaissant un examen de ce
 -- Via la liste des références vers les examens dudit consultation: tables objets
SELECT E.REFCONSULTATION.DIAGNOSTIC, E.DETAILS_EXAMEN,E.DATE_EXAMEN  from O_EXAMEN E 
WHERE E.ID_EXAMEN = 2 ;



 -- Désactivation de la trace afin de pouvoir par la suite utiliser TKPROF
 -- Voir les indications à la fin de ce fichier.
 execute dbms_session.set_sql_trace(false);
 
 
 set autotrace off
 
 ---?
 
 -- 3. Récupération du SPID afin de pouvoir identifier le fichier de
 -- trace TKPROF
 
 select vs.username, vp.spid
   from v$process vp , v$session vs
   where vp.addr=vs.paddr
   and vs.username ='HOPITAL';
   
 
 -- Désactivation de la trace
 -- Voir la fin du fichier pour voir comment lancer TKPROF
 execute dbms_session.set_sql_trace(false);
 
  
 -- La valeur de user_dump_dest indique l'emplacement
 -- du fichier de trace généré.
 show parameter user_dump_dest;
 
  
 set termout off
 set echo off