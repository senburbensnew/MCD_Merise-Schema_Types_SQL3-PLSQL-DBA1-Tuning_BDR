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
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T, 
    -- Consultation
    MEMBER FUNCTION getRefMedecin RETURN REF MEDECIN_T, 
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
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T IS
    BEGIN
        RETURN SELF.refPatient;
    END getRefPatient;

    -- Méthode de consultation : retourne la référence du médecin associé
    MEMBER FUNCTION getRefMedecin RETURN REF MEDECIN_T IS
    BEGIN
        RETURN SELF.refMedecin;
    END getrefMedecin;

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
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T, 
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
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T IS
    BEGIN
        RETURN SELF.refConsultation;
    END getRefConsultation;

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
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T, 
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
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T IS
    BEGIN
        RETURN SELF.refConsultation;
    END getRefConsultation;

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
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T, 
    -- Consultation : retourne LA REFERENCE de la consultation associée au facture
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T, 
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
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T IS
    BEGIN
        RETURN SELF.refPatient;
    END getRefPatient;

    -- Méthode de consultation : retourne la référence de la consultation associée à la facture
    MEMBER FUNCTION getRefConsultation RETURN REF CONSULTATION_T IS
    BEGIN
        RETURN SELF.refConsultation;
    END getRefConsultation;

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
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T, 
    -- Consultation Retourne la REFERENCE du medecin associé à la consultation
    MEMBER FUNCTION getRefMedecin RETURN REF MEDECIN_T, 
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
    MEMBER FUNCTION getRefPatient RETURN REF PATIENT_T IS
    BEGIN
        RETURN SELF.refPatient;
    END getRefPatient;

    -- Méthode de consultation : retourne la référence du médecin associé à la consultation
    MEMBER FUNCTION getRefMedecin RETURN REF MEDECIN_T IS
    BEGIN
        RETURN SELF.refMedecin;
    END getRefMedecin;

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

