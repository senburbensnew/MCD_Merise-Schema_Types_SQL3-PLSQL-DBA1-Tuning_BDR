-- CREATION DE L'UTILISATEUR ORACLE ICI

-- CREATE USER Oracle IDENTIFIED BY PASS123;
-- ALTER USER Oracle QUOTA UNLIMITED  ON USERS;
-- GRANT CREATE SESSION TO Oracle;
-- GRANT CREATE TABLE TO Oracle WITH ADMIN OPTION;
-- GRANT CREATE  VIEW TO Oracle WITH ADMIN OPTION;
-- GRANT CREATE PROCEDURE TO Oracle WITH ADMIN OPTION;
-- GRANT CREATE TYPE TO Oracle WITH ADMIN OPTION;

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

CREATE OR REPLACE TYPE RENDEZ_VOUS_T AS OBJECT(
    Id_Rendez_Vous NUMBER(8),
	refPatient REF PATIENT_T,
	refMedecin REF MEDECIN_T,
	Date_Rendez_Vous DATE,
	Motif VARCHAR2(200),
	MAP member FUNCTION match RETURN VARCHAR2,
	STATIC PROCEDURE listerRendezVous,
	STATIC PROCEDURE rechercherRendezVousParDate(date DATE),
	STATIC PROCEDURE ajouterRendezVous(rendezVous RENDEZ_VOUS_T),
	STATIC PROCEDURE lireRendezVous(rendezVousId NUMBER),
	STATIC PROCEDURE modifierRendezVous(rendezVous RENDEZ_VOUS_T),
	STATIC PROCEDURE supprimerRendezVous(rendezVousId NUMBER)
)
/

CREATE OR REPLACE TYPE setRENDEZ_VOUS_T AS TABLE OF RENDEZ_VOUS_T
/   

CREATE OR REPLACE TYPE EXAMEN_T AS OBJECT(
	Id_Examen NUMBER(8),
	refConsultation REF CONSULTATION_T,
	Details_Examen VARCHAR2(200),
	Date_Examen DATE,	
	MAP MEMBER FUNCTION match RETURN VARCHAR2,
	STATIC PROCEDURE listerExamens,
	STATIC PROCEDURE rechercherExamenParDate(date DATE),
	STATIC PROCEDURE ajouterExamen(examen EXAMEN_T),
	STATIC PROCEDURE lireExamen(examenId NUMBER),
	STATIC PROCEDURE modifierExamen(examen EXAMEN_T),
	STATIC PROCEDURE supprimerExamen(examenId NUMBER)
)
/

CREATE OR REPLACE TYPE PRESCRIPTION_T AS OBJECT(
	Id_Prescription NUMBER(8),
	refConsultation REF CONSULTATION_T,
	Details_Prescription VARCHAR2(200),
	Date_Prescription DATE,	
	MAP MEMBER FUNCTION match RETURN VARCHAR2,
	STATIC PROCEDURE listerPrescriptions,
	STATIC PROCEDURE rechercherPrescriptionParConsultation(consultationId NUMBER),
	STATIC PROCEDURE ajouterPrescription(prescription PRESCRIPTION_T),
	STATIC PROCEDURE lirePrescription(prescriptionId NUMBER),
	STATIC PROCEDURE modifierPrescription(prescription PRESCRIPTION_T),
	STATIC PROCEDURE supprimerPrescription(prescriptionId NUMBER)
)
/

CREATE OR REPLACE TYPE FACTURE_T AS OBJECT(
	Id_Facture NUMBER(8),
	refPatient REF PATIENT_T,
	refConsultation REF CONSULTATION_T,
	Montant_Total NUMBER(7,2),
	Date_Facture DATE,		
	MAP MEMBER FUNCTION match RETURN VARCHAR2,
	STATIC FUNCTION rechercherFactureParMontant(montant NUMBER) RETURN FACTURE_T,
	STATIC FUNCTION rechercherFactureParDate(date DATE) RETURN FACTURE_T,
	STATIC FUNCTION lireFacture(factureId NUMBER) RETURN FACTURE_T,
	-- STATIC FUNCTION listerFactures,
	-- STATIC PROCEDURE ajouterFacture(facture FACTURE_T),
	-- STATIC PROCEDURE modifierFacture(facture FACTURE_T),
	-- STATIC PROCEDURE supprimerFacture(factureId NUMBER)
)
/

CREATE OR REPLACE TYPE setFACTURES_T AS TABLE OF FACTURE_T
/ 

CREATE OR REPLACE TYPE CONSULTATION_T AS OBJECT(
	Id_Consultation NUMBER(8),
	refPatient REF PATIENT_T,
	refMedecin REF MEDECIN_T,
	Raison VARCHAR2(200),
	Diagnostic VARCHAR2(200),
	Date_Consultation DATE,
	pListRefExamens ListRefExamens_t,
	pListRefPrescriptions ListRefPrescriptions_t,
	MAP MEMBER FUNCTION match RETURN VARCHAR2,
	MEMBER PROCEDURE ajouterExamen(examen EXAMEN_T),
	MEMBER PROCEDURE supprimerExamen(examen EXAMEN_T),
	MEMBER PROCEDURE listerExamens,
	MEMBER PROCEDURE ajouterPrescription(prescription PRESCRIPTION_T),
	MEMBER PROCEDURE supprimerPrescription(prescription PRESCRIPTION_T),
	MEMBER PROCEDURE listerPrescriptions,
	STATIC PROCEDURE listerConsultations,
	STATIC PROCEDURE rechercherConsultationParPatient(patientId NUMBER),
	STATIC PROCEDURE ajouterConsultation(consultation CONSULTATION_T),
	STATIC PROCEDURE lireConsultation(consultationId NUMBER),
	STATIC PROCEDURE modifierConsultation(consultation CONSULTATION_T),
	STATIC PROCEDURE supprimerConsultation(consultationId NUMBER)
)
/

CREATE OR REPLACE TYPE setCONSULTATIONS_T AS TABLE OF CONSULTATION_T
/   

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
	 MAP MEMBER FUNCTION MATCH RETURN VARCHAR2 
) NOT INSTANTIABLE NOT FINAL;
/

CREATE OR REPLACE TYPE PATIENT_T UNDER PERSONNE_T(
	 POIDS NUMBER(8),
	 HAUTEUR NUMBER(8),
	 pListRefRendezVous ListRefRendezVous_t,
	 pListRefConsultations ListRefConsultations_t,
	 pListRefFactures ListRefFactures_t,
	 MEMBER FUNCTION listerConsultations RETURN setCONSULTATIONS_T,
	 MEMBER FUNCTION listerRendezVous RETURN setRENDEZ_VOUS_T,
     MEMBER FUNCTION listerFactures RETURN setFACTURES_T,
     -- STATIC FUNCTION listerPatients RETURN setPATIENTS_T,
	 STATIC FUNCTION rechercherPatient(patientId IN NUMBER) RETURN PATIENT_T,
     STATIC FUNCTION rechercherPatientParNom(nom IN VARCHAR2) RETURN PATIENT_T,
	 STATIC FUNCTION rechercherPatientParEmail(email IN VARCHAR2) RETURN PATIENT_T,
	 STATIC FUNCTION rechercherPatientParNumeroSecuriteSociale(numeroSecuriteSociale IN VARCHAR2) RETURN PATIENT_T,
	 MEMBER PROCEDURE ajouterRendezVous(refRendezVous REF RENDEZ_VOUS_T),
     MEMBER PROCEDURE supprimerRendezVous(refRendezVous REF RENDEZ_VOUS_T),
     MEMBER PROCEDURE ajouterConsultation(refConsultation REF Consultation_T),
     MEMBER PROCEDURE supprimerConsultation(refConsultation REF Consultation_T),
	 MEMBER PROCEDURE ajouterFacture(refFacture REF FACTURE_T),
     MEMBER PROCEDURE supprimerFacture(refFacture REF FACTURE_T),
	 STATIC PROCEDURE ajouterPatient(patient PATIENT_T),
     STATIC PROCEDURE modifierPatient(patientId NUMBER, patient PATIENT_T),
     STATIC PROCEDURE supprimerPatient(patientId NUMBER)
)
/

CREATE OR REPLACE TYPE setPATIENTS_T AS TABLE OF PATIENT_T
/  

CREATE OR REPLACE TYPE MEDECIN_T UNDER PERSONNE_T(
	 Specialite VARCHAR2(40),
	 CV CLOB,
	 pListRefRendezVous ListRefRendezVous_t,
	 pListRefConsultations ListRefConsultations_t,
	 MEMBER PROCEDURE ajouterRendezVous(refRendezVous REF Rendez_Vous_T),
	 MEMBER PROCEDURE supprimerRendezVous(refRendezVous REF Rendez_Vous_T),
	 STATIC PROCEDURE listerRendezVous,
	 MEMBER PROCEDURE ajouterConsultation(refConsultation REF Consultation_T),
	 MEMBER PROCEDURE supprimerConsultation(refConsultation REF Consultation_T),
	 STATIC PROCEDURE listerConsultations,
	 STATIC PROCEDURE listerMedecins,
	 STATIC PROCEDURE rechercherMedecinParSpecialite(specialite VARCHAR2),
	 STATIC PROCEDURE ajouterMedecin(medecin MEDECIN_T),
	 STATIC PROCEDURE lireMedecin(medecinId NUMBER),
	 STATIC PROCEDURE modifierMedecin(medecin MEDECIN_T),
	 STATIC PROCEDURE supprimerMedecin(medecinId NUMBER)
)
/

CREATE OR REPLACE TYPE setMEDECINS_T AS TABLE OF MEDECIN_T
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

-- MISE A JOUR ET CONSULTATION DES DONNEES DANS VOS TABLES OBJETS

-- REQUETES DE MISE A JOUR
-- 2 REQUETES IMPLIQUANT 1 TABLE

-- Cette requete modifie la date de naissance du patient dont l’adresse mail est maria.martinez@orange.fr. 
-- La nouvelle date de naissance sera 22-AUG-1986. Seules les
-- lignes correspondant a l’adresse mail specifiee seront affectees.
UPDATE O_PATIENT OP 
SET OP.DATE_NAISSANCE=TO_DATE('22/08/1986', 'DD/MM/YYYY') 
WHERE OP.EMAIL='maria.martinez@orange.fr';

ROLLBACK;

-- Cette requete modifie l’adresse du patient dont l’identifiant est 1. La nouvelle adresse sera 90, DELMAS 75. 
-- Seule la ligne correspondant a l’identifiant specifie sera affectee.
UPDATE O_PATIENT OP 
SET OP.ADRESSE=ADRESSE_T(5, 'DELMAS 75', 75008, 'PORT-AU-PRINCE') 
WHERE OP.ID_PERSONNE=1;

ROLLBACK;

-- 2 REQUETES IMPLIQUANT 2 TABLES

-- Cette requete SQL permet de modifier la date de rendez-vous des patients dont le
-- rendez-vous est pr´evu entre le 14-FEB-2024 et le 18-FEB-2024 dans la table virtuelle
-- issue de la jointure entre PATIENT et RENDEZ VOUS. La nouvelle date de rendezvous sera le 01-MAR-24.
UPDATE O_RENDEZ_VOUS ORV 
SET ORV.Date_Rendez_Vous=TO_DATE('01/03/2024', 'DD/MM/YYYY') 
WHERE ORV.refPatient.DATE_NAISSANCE > TO_DATE('12/12/1994', 'DD/MM/YYYY') 
AND ORV.Date_Rendez_Vous BETWEEN TO_DATE('14/02/2024', 'DD/MM/YYYY') AND TO_DATE('18/02/2024', 'DD/MM/YYYY')

ROLLBACK;

-- Cette requete parcourt toutes les factures dont le montant total est inferieur a 200
-- et pour lesquelles un patient correspondant existe. Pour chacune de ces factures, elle
-- augmente le montant total de 10
UPDATE O_FACTURE OFA 
SET OFA.Montant_Total = OFA.Montant_Total + OFA.Montant_Total * 0.10 
WHERE OFA.Montant_Total < 200 
AND (OFA.refPatient IS NOT DANGLING OR OFA.refPatient IS NULL);

ROLLBACK;

-- 2 requetes impliquant plus de 2 tables

-- Cette requete met a jour la colonne DETAILS PRESCRIPTION de la table PRESCRIPTION pour les enregistrements associes a 
-- des consultations de patients ayant
-- un identifiant de patient egal a 1 et ou la date de consultation est le 5 f´evrier 2024.
-- La nouvelle valeur de la colonne DETAILS PRESCRIPTION sera Zinoboost.
UPDATE O_PRESCRIPTION OPR 
SET OPR.Details_Prescription='Zinoboost'
WHERE OPR.refConsultation.Date_Consultation = TO_DATE('05/02/2024', 'DD/MM/YYYY') 
AND (DEREF(OPR.refConsultation)).refPatient = (SELECT REF(OP) FROM O_PATIENT OP WHERE OP.Id_Personne=1);

ROLLBACK;

-- Cette requete met a jour la colonne DETAILS EXAMEN de la table EXAMEN pour
-- les enregistrements associes a des consultations de patients ayant un identifiant de
-- patient egal a 1 et ou la date de consultation est le 5 fevrier 2024. La nouvelle valeur
-- de la colonne DETAILS EXAMEN sera HAC1
UPDATE O_EXAMEN OE 
SET OE.Details_Examen='HAC1' 
WHERE OE.Date_Consultation=TO_DATE('05/02/2024', 'DD/MM/YYYY')
AND (DEREF(OPR.refConsultation)).refPatient = (SELECT REF(OP) FROM O_PATIENT OP WHERE OP.Id_Personne=1);

ROLLBACK;

-- REQUETES DE SUPPRESSION

-- 2 requetes impliquant 1 table

-- Cette requete supprime toutes les lignes de la table EXAMEN ou la valeur de la
-- colonne DATE EXAMEN est egale a la date du 5 fevrier 2024.
DELETE 
FROM O_EXAMEN OE 
WHERE OE.Date_Examen=TO_DATE('05/02/2024', 'DD/MM/YYYY');

ROLLBACK;

-- Cette requete supprime toutes les lignes de la table PRESCRIPTION ou la valeur
-- de la colonne DATE PRESCRIPTION est egale a la date du 5 fevrier 2024.
DELETE 
FROM O_PRESCRIPTION OP 
WHERE OP.Date_Prescription=TO_DATE('05/02/2024', 'DD/MM/YYYY');

ROLLBACK;

-- 2 requetes impliquant 2 tables

-- Cette requete supprime tous les rendez-vous des patients dont l’adresse e-mail est
-- thomas.leclerc@email.com.
DELETE 
FROM O_RENDEZ_VOUS ORV 
WHERE ORV.refPatient.EMAIL='thomas.leclerc@email.com';

ROLLBACK;

-- Cette requete supprime tous les rendez-vous du patient dont l’identifiant est 3.
DELETE 
FROM O_RENDEZ_VOUS ORV 
WHERE ORV.refPatient.ID_PERSONNE=3;

ROLLBACK;

-- 2 requetes impliquant plus de 2 tables

-- Cette requete supprime tous les examens associ´es `a une consultation qui a eu lieu le
-- fevrier 2024 et qui est liee a un patient dont l’identifiant est 1.
DELETE 
FROM O_EXAMEN OE 
WHERE OE.refConsultation.Date_Consultation=TO_DATE('05/02/2024', 'DD/MM/YYYY') 
AND DEREF(OE.refConsultation).refPatient.ID_PERSONNE=1;

ROLLBACK;

-- Cette requete supprime tous les examens associ´es `a une consultation qui a eu lieu le
-- 6 fevrier 2024 et qui est liee a un patient dont l’identifiant est 2.
DELETE 
FROM O_EXAMEN OE 
WHERE OE.refConsultation.Date_Consultation=TO_DATE('06/02/2024', 'DD/MM/YYYY') 
AND DEREF(OE.refConsultation).refPatient.ID_PERSONNE=2;

ROLLBACK;

-- Description textuelles des requˆetes de consultation

-- 5 requetes impliquant 1 table dont 1 avec un group By
-- et une avec un Order By

-- Cette requete r´ecup`ere toutes les informations (toutes les colonnes) stockees dans la
-- table PATIENT, ce qui signifie qu’elle retournera toutes les lignes de cette table.
SELECT * FROM O_PATIENT OP;

-- Cette requete recupere toutes les informations (toutes les colonnes) stockees dans la
-- table CONSULTATION, ce qui signifie qu’elle retournera toutes les lignes de cette
-- table.
SELECT * FROM O_CONSULTATION OC;

-- Cette requˆete compte le nombre de lignes dans chaque groupe de donn´ees regroup´ees
-- selon les valeurs uniques de la colonne DETAILS EXAMEN. Chaque groupe dans
-- le r´esultat final repr´esente une valeur unique de DETAILS EXAMEN, et le nombre
-- de lignes dans chaque groupe est renvoy´e.
SELECT E.details_examens, COUNT(*) AS NB_LIGNES
FROM (SELECT DISTINCT oe.Details_Examen AS details_examens FROM O_EXAMEN oe) E 
GROUP BY E.details_examens;

-- Cette requˆete compte le nombre de lignes dans chaque groupe de donn´ees regroup´ees
-- selon les valeurs uniques de la colonne DETAILS EXAMEN, et les pr´esente dans
-- l’ordre croissant bas´e sur ces valeurs.
SELECT E.details_examens, COUNT(*) AS NB_LIGNES
FROM (SELECT DISTINCT oe.Details_Examen AS details_examens FROM O_EXAMEN oe) E 
GROUP BY E.details_examens 
ORDER BY E.details_examens ASC;

-- Cette requete renvoie le nombre total de factures, la somme totale des montants
-- de toutes les factures pour chaque patient, regroup´ees par ID PATIENT , et les
-- pr´esente dans l’ordre croissant des ID PATIENT .
SELECT COUNT(*) nb_total_factures, SUM(OFA.Montant_Total) somme_montants_totaux
FROM O_FACTURE OFA 
GROUP BY OFA.refPatient.ID_PERSONNE
ORDER BY OFA.refPatient.ID_PERSONNE;  

--5 requetes impliquant 2 tables avec jointures internes
-- dont 1 externe + 1 group by + 1 tri

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

-- Cette requete retourne toutes les colonnes des consultations et des patients, incluant tous les patients et seulement les consultations qui leur sont associ´ees, tri´ees
-- par date de consultation croissante. Les consultations sans patients associes apparaıtront avec des valeurs NULL dans les colonnes correspondantes de la table
-- ”CONSULTATION”.
SELECT 

-- 5 requetes impliquant plus de 2 tables avec jointures
-- internes dont 1 externe + 1 group by + 1 tri

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

-- Cette requete retourne toutes les colonnes des consultations, des examens et des
-- patients, ou chaque consultation est liee a ses examens correspondants et chaque
-- consultation est ´egalement liee a son patient correspondant. Les resultats sont tries
-- par date de consultation croissante. Les patients pour lesquels il n’y a pas de consultation 
-- correspondante apparaitront avec des valeurs NULL dans les colonnes correspondantes de la table ”CONSULTATION”.
SELECT


-- IMPLEMENTATION DES CORPS DES TYPES
CREATE OR REPLACE TYPE BODY PERSONNE_T AS
	MAP MEMBER FUNCTION match RETURN VARCHAR2 IS
	BEGIN
		RETURN NOM||Sexe||Numero_Securite_Sociale;
	END;
END;
/

--	   MEMBER PROCEDURE ajouterRendezVous(refRendezVous REF RENDEZ_VOUS_T),
--     MEMBER PROCEDURE supprimerRendezVous(refRendezVous REF RENDEZ_VOUS_T),
--     MEMBER PROCEDURE listerRendezVous,
--     MEMBER PROCEDURE ajouterConsultation(refConsultation REF Consultation_T),
--     MEMBER PROCEDURE supprimerConsultation(refConsultation REF Consultation_T),
--     STATIC PROCEDURE listerConsultations,
--     MEMBER PROCEDURE ajouterFacture(refFacture REF FACTURE_T),
--     MEMBER PROCEDURE supprimerFacture(refFacture REF FACTURE_T),
--     STATIC PROCEDURE listerFactures,
--     STATIC PROCEDURE listerPatients,
--     STATIC PROCEDURE rechercherPatientParNom(nom VARCHAR2),
--     STATIC PROCEDURE ajouterPatient(patient PATIENT_T),
--     STATIC PROCEDURE lirePatient(patientId NUMBER),
--     STATIC PROCEDURE modifierPatient(patientId NUMBER, patient PATIENT_T),
--     STATIC PROCEDURE supprimerPatient(patientId NUMBER)

CREATE OR REPLACE TYPE BODY PATIENT_T AS	
	MEMBER PROCEDURE ajouterRendezVous(refRendezVous REF RENDEZ_VOUS_T) IS
	BEGIN		
		INSERT INTO TABLE(
			SELECT op.pListRefRendezVous FROM O_PATIENT op WHERE op.Id_Personne = self.Id_Personne
		) list_ref_rendez_vous_to_table
        VALUES(refRendezVous);
        EXCEPTION 
          WHEN OTHERS THEN RAISE; 
	END;
	
--  MEMBER PROCEDURE supprimerRendezVous(refRendezVous REF RENDEZ_VOUS_T) IS
--	BEGIN
--		DELETE FROM TABLE(
--			SELECT op.pListRefRendezVous FROM O_PATIENT op WHERE op.Id_Personne = self.Id_Personne
--		) list_ref_rendez_vous_to_table
--        WHERE list_ref_rendez_vous_to_table.column_value = refRendezVous;
--		EXCEPTION 
--			WHEN OTHERS THEN RAISE;
--	END;
	
--  MEMBER PROCEDURE listerRendezVous IS
--	BEGIN
--		NULL;
--	END;
	
--  MEMBER PROCEDURE ajouterConsultation(refConsultation REF Consultation_T) IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE supprimerConsultation(refConsultation REF Consultation_T) IS
--	BEGIN
--		NULL;
--	END;
	
--  MEMBER PROCEDURE listerConsultations IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE ajouterFacture(refFacture REF FACTURE_T) IS
--	BEGIN
--		NULL;
--	END;
	
--   MEMBER PROCEDURE supprimerFacture(refFacture REF FACTURE_T) IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE listerFactures IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE listerPatients IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE rechercherPatientParNom(nom VARCHAR2) IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE ajouterPatient(patient PATIENT_T) IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE lirePatient(patientId NUMBER) IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE modifierPatient(patientId NUMBER, patient PATIENT_T) IS
--	BEGIN
--		NULL;
--	END;
	
--    MEMBER PROCEDURE supprimerPatient(patientId NUMBER) IS
--	BEGIN
--		NULL;
--	END;
END;
/

CREATE OR REPLACE TYPE BODY MEDECIN_T AS
END;
/

CREATE OR REPLACE TYPE BODY CONSULTATION_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Date_Consultation;
	END;
END;
/

CREATE OR REPLACE TYPE BODY EXAMEN_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Date_Examen;
	END;
END;
/

CREATE OR REPLACE TYPE BODY RENDEZ_VOUS_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Date_Rendez_Vous;
	END;
END;
/

CREATE OR REPLACE TYPE BODY PRESCRIPTION_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		NULL;
	END;
END;
/

/* 
	CREATE OR REPLACE TYPE FACTURE_T AS OBJECT(
		MAP MEMBER FUNCTION match RETURN VARCHAR2,
		STATIC FUNCTION rechercherFactureParMontant(montant NUMBER) RETURN FACTURE_T,
		STATIC FUNCTION rechercherFactureParDate(date DATE) RETURN FACTURE_T,
		STATIC FUNCTION lireFacture(factureId NUMBER) RETURN FACTURE_T,
		-- STATIC FUNCTION listerFactures,
		-- STATIC PROCEDURE ajouterFacture(facture FACTURE_T),
		-- STATIC PROCEDURE modifierFacture(facture FACTURE_T),
		-- STATIC PROCEDURE supprimerFacture(factureId NUMBER)
	)
*/
	
CREATE OR REPLACE TYPE BODY FACTURE_T AS
	MAP MEMBER FUNCTION match RETURN VARCHAR2 IS
	BEGIN
		RETURN Date_Facture||Montant_Total;
	END;
	
	STATIC FUNCTION rechercherFactureParMontant(montant NUMBER) RETURN FACTURE_T IS
		v_facture FACTURE_T;
	BEGIN
		SELECT VALUE(OFA) INTO v_facture FROM O_FACTURE OFA WHERE OFA.MONTANT_TOTAL = montant;
		RETURN v_facture;
	EXCEPTION 
		WHEN no_data_found THEN
			RAISE;
		WHEN OTHERS THEN
			RAISE; 
	END;
	
	STATIC FUNCTION rechercherFactureParDate(date DATE) RETURN FACTURE_T IS
		v_facture FACTURE_T;
	BEGIN
		SELECT VALUE(OFA) INTO v_facture FROM O_FACTURE OFA WHERE OFA.Date_Facture = date;
		RETURN v_facture;
	EXCEPTION 
		WHEN no_data_found THEN
			RAISE;
		WHEN OTHERS THEN
			RAISE; 
	END;
	
	STATIC FUNCTION lireFacture(factureId NUMBER) RETURN FACTURE_T IS
		v_facture FACTURE_T;
	BEGIN
		SELECT VALUE(OFA) INTO v_facture FROM O_FACTURE OFA WHERE OFA.Id_Facture = factureId;
		RETURN v_facture;
	EXCEPTION 
		WHEN no_data_found THEN
			RAISE;
		WHEN OTHERS THEN
			RAISE; 
	END;
	
	/* 	STATIC FUNCTION listerFactures IS
	BEGIN
		NULL;
	END;
	
	STATIC PROCEDURE ajouterFacture(facture FACTURE_T) IS
	BEGIN
		NULL;
	END;
	
	STATIC PROCEDURE modifierFacture(facture FACTURE_T) IS
	BEGIN
		NULL;
	END;
	
	STATIC PROCEDURE supprimerFacture(factureId NUMBER) IS
	BEGIN
		NULL;
	END;
	*/
END;
/

-- TEST DES METHODES