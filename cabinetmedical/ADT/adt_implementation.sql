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
    MEMBER FUNCTION getPatient RETURN REF PATIENT_T, 
    -- Consultation
    MEMBER FUNCTION getMedecin RETURN REF MEDECIN_T, 
     -- Méthode CRUD (update)
    MEMBER PROCEDURE updateMotif(newMotif VARCHAR2),
    -- Méthode CRUD (delete)
    MEMBER PROCEDURE deleteRendezVous                 
);
/

-- Creation de la table O_RENDEZ_VOUS pour le type RENDEZ_VOUS_T
CREATE TABLE O_RENDEZ_VOUS OF RENDEZ_VOUS_T(
	CONSTRAINT pk_o_rendez_vous_id_rendez_vous PRIMARY KEY(Id_Rendez_Vous),
	refPatient CONSTRAINT o_rendez_vous_ref_patient_not_null NOT NULL,
	refMedecin CONSTRAINT o_rendez_vous_ref_medecin_not_null NOT NULL,
	Date_Rendez_Vous CONSTRAINT date_rendez_vous_not_null NOT NULL,
	Motif CONSTRAINT motif_not_null NOT NULL
)
/

-- Implémentation des méthodes du Type RENDEZ_VOUS_T
CREATE OR REPLACE TYPE BODY RENDEZ_VOUS_T AS 

    -- Méthode de consultation : retourne l'ID du rendez-vous
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN Id_Rendez_Vous;
    END getId;

    -- Méthode de consultation : retourne la date du rendez-vous
    MEMBER FUNCTION getDate RETURN DATE IS
    BEGIN
        RETURN Date_Rendez_Vous;
    END getDate;

    -- Méthode d'ordre : compare deux rendez-vous par date
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN Date_Rendez_Vous;
    END compareDate;

    -- Gestion des liens : associe un rendez-vous à un patient
    MEMBER PROCEDURE linkToPatient(p REF PATIENT_T) IS
    BEGIN
        SELF.refPatient := p;
    END linkToPatient;

    -- Gestion des liens : associe un rendez-vous à un médecin
    MEMBER PROCEDURE linkToMedecin(m REF MEDECIN_T) IS
    BEGIN
        SELF.refMedecin := m;
    END linkToMedecin;

    -- Méthode de consultation : retourne la référence du patient associé
    MEMBER FUNCTION getPatient RETURN REF PATIENT_T IS
    BEGIN
        RETURN SELF.refPatient;
    END getPatient;

    -- Méthode de consultation : retourne la référence du médecin associé
    MEMBER FUNCTION getMedecin RETURN REF MEDECIN_T IS
    BEGIN
        RETURN SELF.refMedecin;
    END getMedecin;

    -- Méthode CRUD (update) : met à jour le motif du rendez-vous
    MEMBER PROCEDURE updateMotif(newMotif VARCHAR2) IS
    BEGIN
        SELF.Motif := newMotif;
    END updateMotif;

    -- Méthode CRUD (delete) : supprime le rendez-vous
    MEMBER PROCEDURE deleteRendezVous IS
    BEGIN
        DELETE FROM O_RENDEZ_VOUS WHERE Id_Rendez_Vous = SELF.Id_Rendez_Vous ;
    END deleteRendezVous;

END;
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
    MEMBER FUNCTION getConsultation RETURN REF CONSULTATION_T, 
    -- Méthode CRUD (update)
    MEMBER PROCEDURE updateDetails(newDetails VARCHAR2), 
    -- Méthode CRUD (delete)
    MEMBER PROCEDURE deleteExamen                       
);
/

-- Creation de la table O_EXAMEN pour le type EXAMEN_T
CREATE TABLE O_EXAMEN OF EXAMEN_T(
	CONSTRAINT pk_o_examen_id_examen PRIMARY KEY(Id_Examen),
	refConsultation CONSTRAINT o_examen_ref_consultation_not_null NOT NULL,
	Details_Examen CONSTRAINT details_examen_not_null NOT NULL,
	Date_Examen CONSTRAINT date_examen_not_null NOT NULL
)
/

-- Implémentation des méthodes du Type EXAMEN_T
CREATE OR REPLACE TYPE BODY EXAMEN_T AS 

    -- Méthode de consultation : retourne l'ID de l'examen
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN Id_Examen;
    END getId;

    -- Méthode de consultation : retourne la date de l'examen
    MEMBER FUNCTION getDate RETURN DATE IS
    BEGIN
        RETURN Date_Examen;
    END getDate;

    -- Méthode d'ordre : compare deux examens par date
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN Date_Examen;
    END compareDate;

    -- Gestion des liens : associe un examen à une consultation
    MEMBER PROCEDURE linkToConsultation(c REF CONSULTATION_T) IS
    BEGIN
        SELF.refConsultation := c;
    END linkToConsultation;

    -- Méthode de consultation : retourne la référence de la consultation associée
    MEMBER FUNCTION getConsultation RETURN REF CONSULTATION_T IS
    BEGIN
        RETURN SELF.refConsultation;
    END getConsultation;

    -- Méthode CRUD (update) : met à jour les détails de l'examen
    MEMBER PROCEDURE updateDetails(newDetails VARCHAR2) IS
    BEGIN
        SELF.Details_Examen := newDetails;
    END updateDetails;

    -- Méthode CRUD (delete) : supprime l'examen en mettant
    MEMBER PROCEDURE deleteExamen IS
    BEGIN
        DELETE FROM O_EXAMEN WHERE Id_Examen = SELF.Id_Examen ;
    END deleteExamen;

END;
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
    MEMBER FUNCTION getConsultation RETURN REF CONSULTATION_T, 
    -- Méthode CRUD (update) : met à jour les détails de la prescription
    MEMBER PROCEDURE updateDetails(newDetails VARCHAR2), 
    -- Méthode CRUD (delete) : supprime la prescription
    MEMBER PROCEDURE deletePrescription                   
);
/

-- Creation de la table O_PRESCRIPTION pour le type PRESCRIPTION_T
CREATE TABLE O_PRESCRIPTION OF PRESCRIPTION_T(
	CONSTRAINT pk_o_prescription_id_prescription PRIMARY KEY(Id_Prescription),
	refConsultation CONSTRAINT o_prescription_ref_consultation_not_null NOT NULL,
	Details_Prescription CONSTRAINT details_prescription_not_null NOT NULL,
	Date_Prescription CONSTRAINT date_prescription_not_null NOT NULL
)
/

-- Implémentation des méthodes du Type PRESCRIPTION_T
CREATE OR REPLACE TYPE BODY PRESCRIPTION_T AS 

    -- Méthode de consultation : retourne l'ID de la prescription
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN Id_Prescription;
    END getId;

    -- Méthode de consultation : retourne la date de la prescription
    MEMBER FUNCTION getDate RETURN DATE IS
    BEGIN
        RETURN Date_Prescription;
    END getDate;

    -- Méthode d'ordre : compare deux prescriptions par date
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN Date_Prescription;
    END compareDate;

    -- Gestion des liens : associe une prescription à une consultation
    MEMBER PROCEDURE linkToConsultation(c REF CONSULTATION_T) IS
    BEGIN
        SELF.refConsultation := c;
    END linkToConsultation;

    -- Méthode de consultation : retourne la référence de la consultation associée
    MEMBER FUNCTION getConsultation RETURN REF CONSULTATION_T IS
    BEGIN
        RETURN SELF.refConsultation;
    END getConsultation;

    -- Méthode CRUD (update) : met à jour les détails de la prescription
    MEMBER PROCEDURE updateDetails(newDetails VARCHAR2) IS
    BEGIN
        SELF.Details_Prescription := newDetails;
    END updateDetails;

    -- Méthode CRUD (delete) : supprime la prescription en mettant ses références à NULL
    MEMBER PROCEDURE deletePrescription IS
    BEGIN
        DELETE FROM O_PRESCRIPTION WHERE Id_Prescription = SELF.Id_Prescription ;
    END deletePrescription;

END;
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
    MEMBER FUNCTION getPatient RETURN REF PATIENT_T, 
    -- Consultation : retourne LA REFERENCE de la consultation associée au facture
    MEMBER FUNCTION getConsultation RETURN REF CONSULTATION_T, 
     -- Méthode CRUD (update) : met à jour le montant de la facture
    MEMBER PROCEDURE updateMontant(newMontant NUMBER),
    -- Méthode CRUD (delete) : supprime la facture
    MEMBER PROCEDURE deleteFacture                     
);
/

-- Creation de la table O_FACTURE pour le type FACTURE_T
CREATE TABLE O_FACTURE OF FACTURE_T(
    CONSTRAINT pk_o_facture_id_facture PRIMARY KEY(Id_Facture),
    refPatient CONSTRAINT o_facture_ref_patient_not_null NOT NULL,
    refConsultation CONSTRAINT o_facture_ref_consultation_not_null NOT NULL,
    Montant_Total CONSTRAINT montant_total_not_null NOT NULL,
    Date_Facture CONSTRAINT date_facture_not_null NOT NULL
)
/

-- Implémentation des méthodes du Type FACTURE_T
CREATE OR REPLACE TYPE BODY FACTURE_T AS 

    -- Méthode de consultation : retourne l'ID de la facture
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN Id_Facture;
    END getId;

    -- Méthode de consultation : retourne la date de la facture
    MEMBER FUNCTION getDate RETURN DATE IS
    BEGIN
        RETURN Date_Facture;
    END getDate;

    -- Méthode d'ordre : compare deux factures par date
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN Date_Facture;
    END compareDate;

    -- Gestion des liens : associe une facture à un patient
    MEMBER PROCEDURE linkToPatient(p REF PATIENT_T) IS
    BEGIN
        SELF.refPatient := p;
    END linkToPatient;

    -- Gestion des liens : associe une facture à une consultation
    MEMBER PROCEDURE linkToConsultation(c REF CONSULTATION_T) IS
    BEGIN
        SELF.refConsultation := c;
    END linkToConsultation;

    -- Méthode de consultation : retourne la référence du patient associé à la facture
    MEMBER FUNCTION getPatient RETURN REF PATIENT_T IS
    BEGIN
        RETURN SELF.refPatient;
    END getPatient;

    -- Méthode de consultation : retourne la référence de la consultation associée à la facture
    MEMBER FUNCTION getConsultation RETURN REF CONSULTATION_T IS
    BEGIN
        RETURN SELF.refConsultation;
    END getConsultation;

    -- Méthode CRUD (update) : met à jour le montant de la facture
    MEMBER PROCEDURE updateMontant(newMontant NUMBER) IS
    BEGIN
        SELF.Montant_Total := newMontant;
    END updateMontant;

    -- Méthode CRUD (delete) : supprime la facture en mettant les références à NULL
    MEMBER PROCEDURE deleteFacture IS
    BEGIN
        DLETE FROM O_FACTURE WHERE Id_Facture = SELF.Id_Facture ;
    END deleteFacture;

END;
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
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION getDate RETURN DATE,
    -- Méthode d'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE, 
    -- Gestion des liens
    MEMBER PROCEDURE linkToPatient(p REF PATIENT_T), 
    -- Gestion des liens
    MEMBER PROCEDURE linkToMedecin(m REF MEDECIN_T), 
    -- Consultation : retourne la REFERENCE du patient associé à la consultation
    MEMBER FUNCTION getPatient RETURN REF PATIENT_T, 
    -- Consultation Retourne la REFERENCE du medecin associé à la consultation
    MEMBER FUNCTION getMedecin RETURN REF MEDECIN_T, 
    -- Consultation : retourne la liste des examens associés à la consultation
    MEMBER FUNCTION getExamens RETURN ListRefExamens_t, 
    -- Consultation : retourne la liste des prescriptions associés à la consultation
    MEMBER FUNCTION getPrescriptions RETURN ListRefPrescriptions_t, 
    -- Méthode CRUD (update) : met à jour le diagnostic
    MEMBER PROCEDURE updateDiagnostic(newDiagnostic VARCHAR2),
    -- Méthode CRUD (delete) : supprime la consultation 
    MEMBER PROCEDURE deleteConsultation                         
);
/

-- Creation de la table O_CONSULTATION  pour le type CONSULTATION_T
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

-- Implémentation des méthodes du Type CONSULTATION_T
CREATE OR REPLACE TYPE BODY CONSULTATION_T AS 

    -- Méthode de consultation : retourne l'ID de la consultation
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN Id_Consultation;
    END getId;

    -- Méthode de consultation : retourne la date de la consultation
    MEMBER FUNCTION getDate RETURN DATE IS
    BEGIN
        RETURN Date_Consultation;
    END getDate;

    -- Méthode d'ordre : compare deux consultations par date
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN SELF.Date_Consultation;
    END compareDate;

    -- Gestion des liens : associe un patient à la consultation
    MEMBER PROCEDURE linkToPatient(p REF PATIENT_T) IS
    BEGIN
        SELF.refPatient := p;
    END linkToPatient;

    -- Gestion des liens : associe un médecin à la consultation
    MEMBER PROCEDURE linkToMedecin(m REF MEDECIN_T) IS
    BEGIN
        SELF.refMedecin := m;
    END linkToMedecin;

    -- Méthode de consultation : retourne la référence du patient associé à la consultation
    MEMBER FUNCTION getPatient RETURN REF PATIENT_T IS
    BEGIN
        RETURN SELF.refPatient;
    END getPatient;

    -- Méthode de consultation : retourne la référence du médecin associé à la consultation
    MEMBER FUNCTION getMedecin RETURN REF MEDECIN_T IS
    BEGIN
        RETURN SELF.refMedecin;
    END getMedecin;

    -- Méthode de consultation : retourne la liste des examens associés à la consultation
    MEMBER FUNCTION getExamens RETURN ListRefExamens_t IS
    BEGIN
        RETURN SELF.pListRefExamens;
    END getExamens;

    -- Méthode de consultation : retourne la liste des prescriptions associées à la consultation
    MEMBER FUNCTION getPrescriptions RETURN ListRefPrescriptions_t IS
    BEGIN
        RETURN SELF.pListRefPrescriptions;
    END getPrescriptions;

    -- Méthode CRUD (update) : met à jour le diagnostic
    MEMBER PROCEDURE updateDiagnostic(newDiagnostic VARCHAR2) IS
    BEGIN
        SELF.Diagnostic := newDiagnostic;
    END updateDiagnostic;

    -- Méthode CRUD (delete) : supprime la consultation en mettant les références à NULL
    MEMBER PROCEDURE deleteConsultation IS
    BEGIN
        -- Suppression de lignes de O_CONSULTATION qui contiennent des tables imbriquées comme pListRefExamens 
        -- et pListRefPrescriptions entraînera également la suppression de ces tables imbriquées associées à la consultation
        DELETE FROM O_CONSULTATION WHERE Id_Consultation = SELF.Id_Consultation;
    END deleteConsultation;

END;
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
CREATE OR REPLACE TYPE BODY PERSONNE_T AS
 -- Méthode de comparaison pour l'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN SELF.DATE_NAISSANCE;
    END compareDate;
END;
/

-- Type PATIENT_T
CREATE OR REPLACE TYPE PATIENT_T UNDER PERSONNE_T(
    POIDS NUMBER(8),
    HAUTEUR NUMBER(8),
    pListRefRendezVous ListRefRendezVous_t,
    pListRefConsultations ListRefConsultations_t,
    pListRefFactures ListRefFactures_t,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    -- Gestion des liens
    MEMBER PROCEDURE addRendezVous(refRendezVous REF RENDEZ_VOUS_T), 
    -- Gestion des liens
    MEMBER PROCEDURE addConsultation(refConsultation REF CONSULTATION_T), 
    -- Gestion des liens
    MEMBER PROCEDURE addFacture(refFacture REF FACTURE_T), 
    -- Consultation: retourne la liste des rendez-vous associés au patient
    MEMBER FUNCTION getRendezVous RETURN ListRefRendezVous_t, 
    -- Consultation: retourne la liste des rendez-vous associés au patient
    MEMBER FUNCTION getConsultations RETURN ListRefConsultations_t, 
    -- Consultation: retourne la liste des factures associés au patient
    MEMBER FUNCTION getFactures RETURN ListRefFactures_t, 
    -- Méthode CRUD (update) : met à jour le poids
    MEMBER PROCEDURE updatePoids(newPoids NUMBER), 
    -- Méthode CRUD (update) : met à jour la hauteur
    MEMBER PROCEDURE updateHauteur(newHauteur NUMBER), 
    -- Méthode CRUD (delete) : supprime le patient
    MEMBER PROCEDURE deletePatient                    
);
/

-- creation de la table O_PATIENT qui contient les objets de type PATIENT_T
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

CREATE OR REPLACE TYPE BODY PATIENT_T AS
    -- Méthode pour retourner l'ID du patient
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN SELF.ID_PERSONNE;
    END getId;

    -- Méthode pour ajouter un rendez-vous
    MEMBER PROCEDURE addRendezVous(refRendezVous REF RENDEZ_VOUS_T) IS
    BEGIN
        SELF.pListRefRendezVous.EXTEND;
        SELF.pListRefRendezVous(SELF.pListRefRendezVous.LAST) := refRendezVous;
    END addRendezVous;

    -- Méthode pour ajouter une consultation
    MEMBER PROCEDURE addConsultation(refConsultation REF CONSULTATION_T) IS
    BEGIN
        SELF.pListRefConsultations.EXTEND;
        SELF.pListRefConsultations(SELF.pListRefConsultations.LAST) := refConsultation;
    END addConsultation;

    -- Méthode pour ajouter une facture
    MEMBER PROCEDURE addFacture(refFacture REF FACTURE_T) IS
    BEGIN
        SELF.pListRefFactures.EXTEND;
        SELF.pListRefFactures(SELF.pListRefFactures.LAST) := refFacture;
    END addFacture;

    -- Méthode pour retourner la liste des rendez-vous
    MEMBER FUNCTION getRendezVous RETURN ListRefRendezVous_t IS
    BEGIN
        RETURN SELF.pListRefRendezVous;
    END getRendezVous;

    -- Méthode pour retourner la liste des consultations
    MEMBER FUNCTION getConsultations RETURN ListRefConsultations_t IS
    BEGIN
        RETURN SELF.pListRefConsultations;
    END getConsultations;

    -- Méthode pour retourner la liste des factures
    MEMBER FUNCTION getFactures RETURN ListRefFactures_t IS
    BEGIN
        RETURN SELF.pListRefFactures;
    END getFactures;

    -- Méthode pour mettre à jour le poids
    MEMBER PROCEDURE updatePoids(newPoids NUMBER) IS
    BEGIN
        SELF.POIDS := newPoids;
    END updatePoids;

    -- Méthode pour mettre à jour la hauteur
    MEMBER PROCEDURE updateHauteur(newHauteur NUMBER) IS
    BEGIN
        SELF.HAUTEUR := newHauteur;
    END updateHauteur;

    -- Méthode pour supprimer le patient
    MEMBER PROCEDURE deletePatient IS
    BEGIN
        -- Suppression de lignes de O_PATIENT qui contiennent des tables imbriquées comme pListRefRendezVous, pListRefConsultations
        -- et pListRefFactures entraînera également la suppression de ces tables imbriquées associées à O_PATIENT
        DELETE FROM O_PATIENT WHERE ID_PERSONNE = SELF.ID_PERSONNE;
    END deletePatient;
END;
/


-- Type MEDECIN_T
CREATE OR REPLACE TYPE MEDECIN_T UNDER PERSONNE_T(
    Specialite VARCHAR2(40),
    CV CLOB,
    pListRefRendezVous ListRefRendezVous_t,
    pListRefConsultations ListRefConsultations_t,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    -- Gestion des liens
    MEMBER PROCEDURE addRendezVous(rv REF RENDEZ_VOUS_T), 
    -- Gestion des liens
    MEMBER PROCEDURE addConsultation(c REF CONSULTATION_T), 
    -- Consultation : renvoie la liste des rendez-vous associes à ce médecin
    MEMBER FUNCTION getRendezVous RETURN ListRefRendezVous_t, 
    -- Consultation : renvoie la liste des consultations associees à ce médecin
    MEMBER FUNCTION getConsultations RETURN ListRefConsultations_t,
    -- Méthode CRUD (update) : mise à jour de la specialite du medecin
    MEMBER PROCEDURE updateSpecialite(newSpecialite VARCHAR2), 
    -- Mehode CRUD (delete) : suppression du medecin
    MEMBER PROCEDURE deleteMedecin                            
);
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

CREATE OR REPLACE TYPE BODY MEDECIN_T AS

    -- Méthode pour retourner l'ID du médecin
    MEMBER FUNCTION getId RETURN NUMBER IS
    BEGIN
        RETURN SELF.ID_PERSONNE;
    END getId;

    -- Méthode pour ajouter un rendez-vous à la liste du médecin
    MEMBER PROCEDURE addRendezVous(rv REF RENDEZ_VOUS_T) IS
    BEGIN
        SELF.pListRefRendezVous.EXTEND;
        SELF.pListRefRendezVous(SELF.pListRefRendezVous.LAST) := rv;
    END addRendezVous;

    -- Méthode pour ajouter une consultation à la liste du médecin
    MEMBER PROCEDURE addConsultation(c REF CONSULTATION_T) IS
    BEGIN
        SELF.pListRefConsultations.EXTEND;
        SELF.pListRefConsultations(SELF.pListRefConsultations.LAST) := c;
    END addConsultation;

    -- Méthode pour retourner la liste des rendez-vous associés à ce médecin
    MEMBER FUNCTION getRendezVous RETURN ListRefRendezVous_t IS
    BEGIN
        RETURN SELF.pListRefRendezVous;
    END getRendezVous;

    -- Méthode pour retourner la liste des consultations associées à ce médecin
    MEMBER FUNCTION getConsultations RETURN ListRefConsultations_t IS
    BEGIN
        RETURN SELF.pListRefConsultations;
    END getConsultations;

    -- Méthode pour mettre à jour la spécialité du médecin
    MEMBER PROCEDURE updateSpecialite(newSpecialite VARCHAR2) IS
    BEGIN
        SELF.Specialite := newSpecialite;
    END updateSpecialite;

    -- Méthode pour supprimer le médecin
    MEMBER PROCEDURE deleteMedecin IS
    BEGIN
        DELETE FROM O_MEDECIN WHERE ID_PERSONNE = SELF.ID_PERSONNE;
    END deleteMedecin;

END;
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
