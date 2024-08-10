-- CREATION DE L'UTILISATEUR ORACLE ICI
-- sqlplus SYS AS SYSDBA;
-- CREATE USER Oracle IDENTIFIED BY password;
-- GRANT CONNECT, RESOURCE TO Oracle;
-- GRANT UNLIMITED TABLESPACE TO Oracle;
-- sqlplus Oracle/password@your_database

-- SUPPRESSION DES TABLES OBJETS
DROP TABLE O_EXAMEN CASCADE CONSTRAINTS;
DROP TABLE O_CONSULTATION CASCADE CONSTRAINTS;
DROP TABLE O_PRESCRIPTION CASCADE CONSTRAINTS;
DROP TABLE O_FACTURE CASCADE CONSTRAINTS;
DROP TABLE O_RENDEZ_VOUS CASCADE CONSTRAINTS;
DROP TABLE O_MEDECIN CASCADE CONSTRAINTS;
DROP TABLE O_PATIENT CASCADE CONSTRAINTS;

-- SUPPRESSION DES TYPES
DROP TYPE ADRESSE_T force;
DROP TYPE ListPrenoms_t force;
DROP TYPE ListTelephones_t force;
DROP TYPE ListRefConsultations_t force;
DROP TYPE ListRefRendezVous_t force;
DROP TYPE ListRefFactures_t force;
DROP TYPE ListRefExamens_t force;
DROP TYPE ListRefPrescriptions_t force;
DROP TYPE PERSONNE_T force;
DROP TYPE EXAMEN_T force;
DROP TYPE PATIENT_T force;
DROP TYPE MEDECIN_T force;
DROP TYPE PRESCRIPTION_T force;
DROP TYPE FACTURE_T force;
DROP TYPE CONSULTATION_T force;
DROP TYPE RENDEZ_VOUS_T force;

-- CREATION DES TYPES 
CREATE OR REPLACE TYPE ADRESSE_T AS OBJECT (
	 Numero NUMBER(4),
	 Rue VARCHAR2(20),
	 Code_Postal NUMBER(5),
	 Ville VARCHAR2(20)
)
/

CREATE OR REPLACE TYPE ListPrenoms_t AS varray(3) OF varchar2(30);
/

CREATE OR REPLACE TYPE ListTelephones_t AS varray(3) OF varchar2(30);
/

CREATE OR REPLACE TYPE RENDEZ_VOUS_T;
/

CREATE OR REPLACE TYPE ListRefRendezVous_t AS TABLE OF REF RENDEZ_VOUS_T;
/

CREATE OR REPLACE TYPE CONSULTATION_T;
/

CREATE OR REPLACE TYPE ListRefConsultations_t AS TABLE OF REF CONSULTATION_T;
/

CREATE OR REPLACE TYPE FACTURE_T;
/

CREATE OR REPLACE TYPE ListRefFactures_t AS TABLE OF REF FACTURE_T;
/

CREATE OR REPLACE TYPE EXAMEN_T;
/

CREATE OR REPLACE TYPE ListRefExamens_t AS TABLE OF REF EXAMEN_T;
/

CREATE OR REPLACE TYPE PRESCRIPTION_T;
/

CREATE OR REPLACE TYPE ListRefPrescriptions_t AS TABLE OF REF PRESCRIPTION_T;
/

CREATE OR REPLACE TYPE PERSONNE_T AS OBJECT(
	 Id_Personne# NUMBER(4),
	 Numero_Securite_Sociale NUMBER(30),
	 Nom VARCHAR2(12),
	 Email VARCHAR2(30),
	 listTelephones ListTelephones_t,
	 listPrenoms ListPrenoms_t,
	 Adresse Adresse_t,
	 Sexe varchar2(1),
	 MAP member FUNCTION match RETURN VARCHAR2 
) NOT INSTANTIABLE NOT FINAL;
/

CREATE OR REPLACE TYPE PATIENT_T UNDER PERSONNE_T(
	 Date_naissance DATE,
	 pListRefRendezVous ListRefRendezVous_t,
	 pListRefConsultations ListRefConsultations_t,
	 pListRefFactures ListRefFactures_t,
	 MEMBER PROCEDURE ajouterRendezVous(refRendezVous REF RENDEZ_VOUS_T),
     MEMBER PROCEDURE supprimerRendezVous(refRendezVous REF RENDEZ_VOUS_T),
     STATIC PROCEDURE listerRendezVous,
     MEMBER PROCEDURE ajouterConsultation(refConsultation REF Consultation_T),
     MEMBER PROCEDURE supprimerConsultation(refConsultation REF Consultation_T),
     STATIC PROCEDURE listerConsultations,
     MEMBER PROCEDURE ajouterFacture(refFacture REF FACTURE_T),
     MEMBER PROCEDURE supprimerFacture(refFacture REF FACTURE_T),
     STATIC PROCEDURE listerFactures,
     STATIC PROCEDURE listerPatients,
     STATIC PROCEDURE rechercherPatientParNom(nom VARCHAR2),
     STATIC PROCEDURE ajouterPatient(patient PATIENT_T),
     STATIC PROCEDURE lirePatient(patientId NUMBER),
     STATIC PROCEDURE modifierPatient(patientId NUMBER, patient PATIENT_T),
     STATIC PROCEDURE supprimerPatient(patientId NUMBER)
)
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

CREATE OR REPLACE TYPE RENDEZ_VOUS_T AS OBJECT(
    Id_Rendez_Vous# NUMBER(8),
	refPatient REF PATIENT_T,
	refMedecin REF MEDECIN_T,
	Date_Rendez_Vous DATE,
	Motif VARCHAR2(200),
	MAP member FUNCTION match RETURN VARCHAR2,
	STATIC PROCEDURE listerRendezVous,
	STATIC PROCEDURE rechercherRendezVousParDate(date Date),
	STATIC PROCEDURE ajouterRendezVous(rendezVous RENDEZ_VOUS_T),
	STATIC PROCEDURE lireRendezVous(rendezVousId NUMBER),
	STATIC PROCEDURE modifierRendezVous(rendezVous RENDEZ_VOUS_T),
	STATIC PROCEDURE supprimerRendezVous(rendezVousId NUMBER)
)
/

CREATE OR REPLACE TYPE EXAMEN_T AS OBJECT(
	Id_Examen# NUMBER(8),
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
	Id_Prescription# NUMBER(8),
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
	Id_Facture# NUMBER(8),
	refPatient REF PATIENT_T,
	refConsultation REF CONSULTATION_T,
	Montant_Total NUMBER(7,2),
	Date_Facture DATE,	
	MAP MEMBER FUNCTION match RETURN VARCHAR2,
	STATIC PROCEDURE listerFactures,
	STATIC PROCEDURE rechercherFactureParMontant(montant NUMBER),
	STATIC PROCEDURE rechercherFactureParDate(date DATE),
	STATIC PROCEDURE ajouterFacture(facture FACTURE_T),
	STATIC PROCEDURE lireFacture(factureId NUMBER),
	STATIC PROCEDURE modifierFacture(facture FACTURE_T),
	STATIC PROCEDURE supprimerFacture(factureId NUMBER)
)
/

CREATE OR REPLACE TYPE CONSULTATION_T AS OBJECT(
	Id_Consultation# NUMBER(8),
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

-- CREATION DES TABLES OBJETS A PARTIR DES TYPES
CREATE TABLE O_PATIENT OF PATIENT_T(
	CONSTRAINT pk_o_patient_id_personne PRIMARY KEY(Id_Personne#),
	Numero_Securite_Sociale CONSTRAINT o_patient_num_secu_social_not_null NOT NULL,
	Nom CONSTRAINT o_patient_nom_not_null NOT NULL,
	Email CONSTRAINT o_patient_email_not_null NOT NULL,
	Date_naissance CONSTRAINT o_patient_date_naissance_not_null NOT NULL,
	Sexe CONSTRAINT o_patient_sexe_not_null NOT NULL,
	CONSTRAINT o_patient_sexe_check CHECK (Sexe IN ('Masculin', 'Feminin', 'Autre'))
)
NESTED TABLE pListRefRendezVous STORE AS o_patient_table_pListRefRendezVous
NESTED TABLE pListRefConsultations STORE AS o_patient_table_pListRefConsultations
NESTED TABLE pListRefFactures STORE AS o_patient_table_pListRefFactures
/

CREATE TABLE O_MEDECIN OF MEDECIN_T(
	CONSTRAINT pk_o_medecin_id_personne PRIMARY KEY(Id_Personne#),
	Numero_Securite_Sociale CONSTRAINT o_medecin_num_secu_social_not_null NOT NULL,
	Nom CONSTRAINT o_medecin_nom_not_null NOT NULL,
	Email CONSTRAINT o_medecin_email_not_null NOT NULL,
	Specialite CONSTRAINT o_medecin_date_naissance_not_null NOT NULL,
	Sexe CONSTRAINT o_medecin_sexe_not_null NOT NULL,
	CONSTRAINT o_medecin_sexe_check CHECK (Sexe IN ('Masculin', 'Feminin', 'Autre')),
	CONSTRAINT o_medecin_specialite_check CHECK (Sexe IN ('Urologue', 'Gynecologue', 'Interniste', 'Cardiologue', 'Pediatre', 'Chirurgien'))
)
NESTED TABLE pListRefRendezVous STORE AS o_medecin_table_pListRefRendezVous
NESTED TABLE pListRefConsultations STORE AS o_medecin_table_pListRefConsultations
LOB(CV) STORE AS storeCV(PCTVERSION 30)
/


CREATE TABLE O_EXAMEN OF EXAMEN_T(
	CONSTRAINT pk_o_examen_id_examen PRIMARY KEY(Id_Examen#),
	Details_Examen CONSTRAINT details_examen_not_null NOT NULL,
	Date_Examen CONSTRAINT date_examen_not_null NOT NULL
)
/

CREATE TABLE O_PRESCRIPTION OF PRESCRIPTION_T(
	CONSTRAINT pk_o_prescription_id_prescription PRIMARY KEY(Id_Prescription#),
	refConsultation CONSTRAINT o_prescription_ref_consultation_not_null NOT NULL,
	Details_Prescription CONSTRAINT details_prescription_not_null NOT NULL,
	Date_Prescription CONSTRAINT date_prescription_not_null NOT NULL
)
/

CREATE TABLE O_FACTURE OF FACTURE_T(	
	CONSTRAINT pk_o_facture_id_facture PRIMARY KEY(Id_Facture#),
	refPatient CONSTRAINT o_facture_ref_patient_not_null NOT NULL,
	refConsultation CONSTRAINT o_facture_ref_consultation_not_null NOT NULL,
	Montant_Total CONSTRAINT montant_total_not_null NOT NULL,
	Date_Facture CONSTRAINT date_facture_not_null NOT NULL
)
/

CREATE TABLE O_RENDEZ_VOUS OF RENDEZ_VOUS_T(
	CONSTRAINT pk_o_rendez_vous_id_rendez_vous PRIMARY KEY(Id_Rendez_Vous#),
	refPatient CONSTRAINT o_rendez_vous_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_rendez_vous_ref_medecin_not_null NOT NULL,
	Date_Rendez_Vous CONSTRAINT date_rendez_vous_not_null NOT NULL,
	Motif CONSTRAINT motif_not_null NOT NULL
)
/

CREATE TABLE O_CONSULTATION OF CONSULTATION_T(
	CONSTRAINT pk_o_consultation_id_consultation PRIMARY KEY(Id_Consultation#),
	Raison CONSTRAINT raison_not_null NOT NULL,
	Diagnostic CONSTRAINT diagnostic_not_null NOT NULL,
	Date_Consultation CONSTRAINT date_consultation_not_null NOT NULL
) 
NESTED TABLE pListRefExamens STORE AS table_pListRefExamens
NESTED TABLE pListRefPrescriptions STORE AS table_pListRefPrescriptions
/

-- CREATION DES INDEX
ALTER TABLE O_RENDEZ_VOUS ADD (SCOPE FOR (refPatient) IS O_PATIENT);
ALTER TABLE O_RENDEZ_VOUS ADD (SCOPE FOR (refMedecin) IS O_MEDECIN);
ALTER TABLE O_FACTURE ADD (SCOPE FOR (refPatient) IS O_PATIENT);
ALTER TABLE O_FACTURE ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
ALTER TABLE O_PRESCRIPTION ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
ALTER TABLE O_EXAMEN ADD (SCOPE FOR (refConsultation) IS O_CONSULTATION);
ALTER TABLE o_medecin_table_pListRefConsultations ADD (SCOPE FOR (column_value) IS O_CONSULTATION);
ALTER TABLE o_medecin_table_pListRefRendezVous ADD (SCOPE FOR (column_value) IS O_RENDEZ_VOUS);
ALTER TABLE o_patient_table_pListRefConsultations ADD (SCOPE FOR (column_value) IS O_CONSULTATION);
ALTER TABLE o_patient_table_pListRefRendezVous ADD (SCOPE FOR (column_value) IS O_RENDEZ_VOUS);
ALTER TABLE o_patient_table_pListRefFactures ADD (SCOPE FOR (column_value) IS O_FACTURE);
ALTER TABLE table_pListRefExamens ADD (SCOPE FOR (column_value) IS O_EXAMEN);
ALTER TABLE table_pListRefPrescriptions ADD (SCOPE FOR (column_value) IS O_PRESCRIPTION);


DROP INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique;
DROP INDEX idx_o_patient_email_unique;
DROP INDEX idx_o_patient_num_sec_social_unique;
DROP INDEX idx_o_medecin_email_unique;
DROP INDEX idx_o_medecin_num_sec_social_unique;
DROP INDEX idx_o_medecin_specialite;
DROP INDEX idx_o_facture_montant_total;
DROP INDEX IDX_O_RENDEZ_VOUS_refPatient;
DROP INDEX IDX_O_RENDEZ_VOUS_refMedecin;
DROP INDEX IDX_O_FACTURE_refPatient;
DROP INDEX IDX_O_FACTURE_refConsultation;
DROP INDEX IDX_O_PRESCRIPTION_refConsultation;
DROP INDEX IDX_O_EXAMEN_refConsultation;
DROP INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value;
DROP INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value;
DROP INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value;
DROP INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value;
DROP INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value;
DROP INDEX idx_table_pListRefExamens_Nested_table_id_Column_value;
DROP INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value;

CREATE UNIQUE INDEX idx_o_rendez_vous_ref_patient_ref_medecin_date_unique ON O_RENDEZ_VOUS(refPatient, refMedecin, Date_Rendez_Vous);
CREATE UNIQUE INDEX idx_o_patient_email_unique ON O_PATIENT(Email);
CREATE UNIQUE INDEX idx_o_patient_num_sec_social_unique ON O_PATIENT(Numero_Securite_Sociale);
CREATE UNIQUE INDEX idx_o_medecin_email_unique ON O_MEDECIN(Email);
CREATE UNIQUE INDEX idx_o_medecin_num_sec_social_unique ON O_MEDECIN(Numero_Securite_Sociale);
CREATE INDEX idx_o_medecin_specialite ON O_MEDECIN(Specialite);
CREATE INDEX idx_o_facture_montant_total ON O_FACTURE(Montant_Total);
CREATE INDEX IDX_O_RENDEZ_VOUS_refPatient ON O_RENDEZ_VOUS(refPatient);
CREATE INDEX IDX_O_RENDEZ_VOUS_refMedecin ON O_RENDEZ_VOUS(refMedecin);
CREATE INDEX IDX_O_FACTURE_refPatient ON O_FACTURE(refPatient);
CREATE INDEX IDX_O_FACTURE_refConsultation ON O_FACTURE(refConsultation);
CREATE INDEX IDX_O_PRESCRIPTION_refConsultation ON O_PRESCRIPTION(refConsultation);
CREATE INDEX IDX_O_EXAMEN_refConsultation ON O_EXAMEN(refConsultation);
CREATE UNIQUE INDEX idx_o_medecin_table_pListRefConsultations_Nested_table_id_Column_value ON o_medecin_table_pListRefConsultations(Nested_table_id, Column_value);
CREATE UNIQUE INDEX idx_o_medecin_table_pListRefRendezVous_Nested_table_id_Column_value ON o_medecin_table_pListRefRendezVous(Nested_table_id, Column_value);
CREATE UNIQUE INDEX idx_o_patient_table_pListRefConsultations_Nested_table_id_Column_value ON o_patient_table_pListRefConsultations(Nested_table_id, Column_value);
CREATE UNIQUE INDEX idx_o_patient_table_pListRefRendezVous_Nested_table_id_Column_value ON o_patient_table_pListRefRendezVous(Nested_table_id, Column_value);
CREATE UNIQUE INDEX idx_o_patient_table_pListRefFactures_Nested_table_id_Column_value ON o_patient_table_pListRefFactures(Nested_table_id, Column_value);
CREATE UNIQUE INDEX idx_table_pListRefExamens_Nested_table_id_Column_value ON table_pListRefExamens(Nested_table_id, Column_value);
CREATE UNIQUE INDEX idx_table_pListRefPrescriptions_Nested_table_id_Column_value ON table_pListRefPrescriptions(Nested_table_id, Column_value);


-- INSERTION DES LIGNES DANS LES TABLES OBJETS

COMMIT;



-- IMPLEMENTATION DES CORPS DES TYPES
CREATE OR REPLACE TYPE BODY PATIENT_T AS
	MAP MEMBER FUNCTION match RETURN VARCHAR2 IS
	BEGIN
		RETURN NOM||Date_naissance;
	END;
	
	MEMBER PROCEDURE ajouterRendezVous(refRendezVous REF RENDEZ_VOUS_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE supprimerRendezVous(refRendezVous REF RENDEZ_VOUS_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE listerRendezVous IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE ajouterConsultation(refConsultation REF Consultation_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE supprimerConsultation(refConsultation REF Consultation_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE listerConsultations IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE ajouterFacture(refFacture REF FACTURE_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE supprimerFacture(refFacture REF FACTURE_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE listerFactures IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE listerPatients IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE rechercherPatientParNom(nom VARCHAR2) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE ajouterPatient(patient PATIENT_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE lirePatient(patientId NUMBER) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE modifierPatient(patientId NUMBER, patient PATIENT_T) IS
	BEGIN
		NULL;
	END;
	
    MEMBER PROCEDURE supprimerPatient(patientId NUMBER) IS
	BEGIN
		NULL;
	END;
END;
/

CREATE OR REPLACE TYPE BODY MEDECIN_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Specialite||NOM;
	END;
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
		RETURN Date_Prescription;
	END;
END;
/

CREATE OR REPLACE TYPE BODY FACTURE_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Date_Facture||Montant_Total;
	END;
END;
/


-- TEST DES METHODES

