DROP TABLE PERSONNE CASCADE CONSTRAINTS;
DROP TABLE EXAMEN CASCADE CONSTRAINTS;
DROP TABLE CONSULTATION CASCADE CONSTRAINTS;
DROP TABLE PRESCRIPTION CASCADE CONSTRAINTS;
DROP TABLE FACTURE CASCADE CONSTRAINTS;
DROP TABLE RENDEZ_VOUS CASCADE CONSTRAINTS;

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


-- Creation des types 

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

-- Pour l'heritage
 CREATE OR REPLACE TYPE PERSONNE_T AS OBJECT(
	 Id_Personne# NUMBER(4),
	 Nom VARCHAR2(12),
	 Email VARCHAR2(30),
	 listTelephones ListTelephones_t,
	 listPrenoms ListPrenoms_t,
	 Adresse Adresse_t,
	 MAP member FUNCTION match RETURN VARCHAR2
) NOT INSTANTIABLE NOT FINAL;
/

CREATE OR REPLACE TYPE PATIENT_T UNDER PERSONNE_T(
	 Date_naissance DATE,
	 pListRefRendezVous ListRefRendezVous_t,
	 pListRefConsultations ListRefConsultations_t,
	 pListRefFactures ListRefFactures_t,
	 OVERRIDING  MAP MEMBER FUNCTION match RETURN VARCHAR2,
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
	 OVERRIDING MAP member FUNCTION match RETURN VARCHAR2,	 
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
	refPatient REF PATIENT_T,
	refMedecin REF MEDECIN_T,
	Date_Rendez_Vous Date,
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
	refConsultation REF CONSULTATION_T,
	Id_Prescription# NUMBER(8),
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
	Id_Consultation# number(8),
	Raison varchar2(200),
	Diagnostic varchar2(200),
	Date_Consultation Date,
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

-- Implementation des corps des types (A completer)

CREATE OR REPLACE TYPE BODY PERSONNE_T AS
	MAP MEMBER FUNCTION match RETURN VARCHAR2 IS
	BEGIN
		RETURN NOM||Id_Personne#;
	END;
END;
/

CREATE OR REPLACE TYPE BODY PATIENT_T AS
	OVERRIDING MAP MEMBER FUNCTION match RETURN VARCHAR2 IS
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

-- Creation des TABLEs objets a partir des types crees (A completer)

CREATE TABLE PERSONNE OF PERSONNE_T(
)
/

CREATE TABLE EXAMEN OF EXAMEN_T(
)
/

CREATE TABLE FACTURE OF FACTURE_T(
)
/

CREATE TABLE PRESCRIPTION OF PRESCRIPTION_T(
)
/

CREATE TABLE CONSULTATION OF CONSULTATION_T(
)
/

CREATE TABLE RENDEZ_VOUS OF RENDEZ_VOUS_T(
)
/

-- Creation des indexes (A completer)


-- Insertion des lignes dans les tables objets


-- Test des methodes

