
DROP TABLE PATIENT CASCADE CONSTRAINTS;
DROP TABLE EXAMEN CASCADE CONSTRAINTS;
DROP TABLE CONSULTATION CASCADE CONSTRAINTS;
DROP TABLE MEDECIN CASCADE CONSTRAINTS;
DROP TABLE PRESCRIPTION CASCADE CONSTRAINTS;
DROP TABLE FACTURE CASCADE CONSTRAINTS;
DROP TABLE RENDEZ_VOUS CASCADE CONSTRAINTS;

DROP TYPE EXAMEN_T force;
DROP TYPE PATIENT_T force;
DROP TYPE MEDECIN_T force;
DROP TYPE PRESCRIPTION_T force;
DROP TYPE FACTURE_T force;
DROP TYPE CONSULTATION_T force;
DROP TYPE RENDEZ_VOUS_T;


-- Creation des types 

CREATE OR REPLACE TYPE ADRESSE_T AS OBJECT (
	Numero NUMBER(4),
	Rue VARCHAR2(20),
	Code_Postal NUMBER(5),
	Ville VARCHAR2(20)
);

CREATE OR REPLACE TYPE ListPrenoms_t AS varray(3) OF varchar2(30);

CREATE OR REPLACE TYPE ListTelephones_t AS varray(3) OF varchar2(30);

CREATE OR REPLACE TYPE ListRefRendezVous_t AS TABLE OF REF RENDEZ_VOUS_T;

CREATE OR REPLACE TYPE ListRefConsultations_t AS TABLE OF REF CONSULTATION_T;

CREATE OR REPLACE TYPE ListRefFactures_t AS TABLE OF REF FACTURES_T;

CREATE OR REPLACE TYPE ListRefExamens_t AS TABLE OF REF EXAMEN_T;

CREATE OR REPLACE TYPE ListRefPrescriptions_t AS TABLE OF REF PRESCRIPTION_T;


CREATE OR REPLACE TYPE PATIENT_T AS OBJECT(
	Id_Patient# number(8),
	Nom varchar2,
	listPrenoms ListPrenoms_t,
	Adresse Adresse_t,
	Email varchar2,
	listTelephones ListTelephones_t,
	Date_naissance date
	pListRefRendezVous ListRefRendezVous_t,
	pListRefConsultations ListRefConsultations_t,
	pListRefFactures ListRefFactures_t,
	MAP member FUNCTION match RETURN varchar2
);

CREATE OR REPLACE TYPE MEDECIN_T AS OBJECT(
	Id_Medecin# number(8),
	Nom varchar2,
	listPrenoms ListPrenoms_t,
	Adresse Adresse_t,
	Email varchar2,
	listTelephones ListTelephones_t,
	Date_naissance date,
	CV CLOB,
	pListRefRendezVous pListRefRendezVous_t,
	pListRefConsultations pListRefConsultations_t,
	MAP member FUNCTION match RETURN varchar2
);

CREATE OR REPLACE TYPE RENDEZ_VOUS_T AS OBJECT(
	refPatient REF PATIENT_T,
	refMedecin REF MEDECIN_T,
	Date_Rendez_Vous date,
	Motif varchar2(200),
	MAP member FUNCTION match RETURN varchar2
);

CREATE OR REPLACE TYPE EXAMEN_T AS OBJECT(
	Id_Examen# number(8),
	Details_Examen varchar2(200),
	Date_Examen date,
	MAP member FUNCTION match RETURN varchar2
);

CREATE OR REPLACE TYPE PRESCRIPTION_T AS OBJECT(
	refConsultation REF CONSULTATION_T,
	Id_Prescription# number(8),
	Details_Prescription varchar2(200),
	Date_Prescription date,
	MAP member FUNCTION match RETURN varchar2
);

CREATE OR REPLACE TYPE FACTURE_T AS OBJECT(
	refPatient REF PATIENT_T,
	refConsultation REF CONSULTATION_T,
	Id_Facture# number(8),
	Montant_Total number(8,2)
	Date_Facture date,
	MAP member FUNCTION match RETURN varchar2
);

CREATE OR REPLACE TYPE CONSULTATION_T AS OBJECT(
	Id_Consultation# number(8),
	Raison varchar2,
	Diagnostic varchar2(200),
	Date_Consultation date,
	pListRefExamens ListRefExamens_t,
	pListRefPrescriptions ListRefPrescriptions_t,
	MAP member FUNCTION match RETURN varchar2
);



-- Implementation des corps des types (A completer)

CREATE OR REPLACE TYPE BODY PATIENT_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Nom || Date_naissance || Id_Patient#;
	END;
END;
/

CREATE OR REPLACE TYPE BODY MEDECIN_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Nom || Date_naissance || Id_Medecin#;
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

CREATE OR REPLACE TYPE BODY FACTURES_T AS
	MAP member FUNCTION match RETURN varchar2 IS
	BEGIN
		RETURN Date_Facture || Montant_Total;
	END;
END;
/

-- Creation des TABLEs objets a partir des types crees (A completer)

CREATE TABLE PATIENT OF PATIENT_T;

CREATE TABLE MEDECIN OF MEDECIN_T;

CREATE TABLE EXAMEN OF EXAMEN_T;

CREATE TABLE FACTURE OF FACTURES_T;

CREATE TABLE PRESCRIPTION OF PRESCRIPTION_T;

CREATE TABLE CONSULTATION OF CONSULTATION_T;

CREATE TABLE RENDEZ_VOUS OF RENDEZ_VOUS_T;


-- Creation des indexes (A completer)