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

-- Déclaration Forward du Type RENDEZ_VOUS_T afin d'éviter l'interblocage dû au reférencement mutuel entre types
CREATE OR REPLACE TYPE RENDEZ_VOUS_T
/

CREATE OR REPLACE TYPE ListRefRendezVous_t AS TABLE OF REF RENDEZ_VOUS_T
/

-- Déclaration Forward du Type CONSULTATION_T afin d'éviter l'interblocage dû au reférencement mutuel entre types
CREATE OR REPLACE TYPE CONSULTATION_T
/

CREATE OR REPLACE TYPE ListRefConsultations_t AS TABLE OF REF CONSULTATION_T
/

-- Déclaration Forward du Type FACTURE_T afin d'éviter l'interblocage dû au reférencement mutuel entre types
CREATE OR REPLACE TYPE FACTURE_T
/

CREATE OR REPLACE TYPE ListRefFactures_t AS TABLE OF REF FACTURE_T
/

-- Déclaration Forward du Type EXAMEN_T afin d'éviter l'interblocage dû au reférencement mutuel entre types
CREATE OR REPLACE TYPE EXAMEN_T
/

CREATE OR REPLACE TYPE ListRefExamens_t AS TABLE OF REF EXAMEN_T
/

-- Déclaration Forward du Type PRESCRIPTION_T afin d'éviter l'interblocage dû au reférencement mutuel entre types
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
	Motif VARCHAR2(200)
)
/


CREATE OR REPLACE TYPE EXAMEN_T AS OBJECT(
	Id_Examen NUMBER(8),
	refConsultation REF CONSULTATION_T,
	Details_Examen VARCHAR2(200),
	Date_Examen DATE
)
/

CREATE OR REPLACE TYPE PRESCRIPTION_T AS OBJECT(
	Id_Prescription NUMBER(8),
	refConsultation REF CONSULTATION_T,
	Details_Prescription VARCHAR2(200),
	Date_Prescription DATE
)
/

CREATE OR REPLACE TYPE FACTURE_T AS OBJECT(
	Id_Facture NUMBER(8),
	refPatient REF PATIENT_T,
	refConsultation REF CONSULTATION_T,
	Montant_Total NUMBER(7,2),
	Date_Facture DATE
)
/

CREATE OR REPLACE TYPE CONSULTATION_T AS OBJECT(
	Id_Consultation NUMBER(8),
	refPatient REF PATIENT_T,
	refMedecin REF MEDECIN_T,
	Raison VARCHAR2(200),
	Diagnostic VARCHAR2(200),
	Date_Consultation DATE,
	pListRefExamens ListRefExamens_t,
	pListRefPrescriptions ListRefPrescriptions_t
)
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
	 pListRefFactures ListRefFactures_t
)
/

CREATE OR REPLACE TYPE MEDECIN_T UNDER PERSONNE_T(
	 Specialite VARCHAR2(40),
	 CV CLOB,
	 pListRefRendezVous ListRefRendezVous_t,
	 pListRefConsultations ListRefConsultations_t
)
/
