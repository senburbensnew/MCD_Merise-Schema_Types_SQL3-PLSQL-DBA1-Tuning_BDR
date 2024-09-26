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
DROP TYPE setEXAMEN_T FORCE;
DROP TYPE setPRESCRIPTION_T FORCE;
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
    static FUNCTION getConsultation(idConsultation in NUMBER) RETURN O_CONSULTATION,
    static FUNCTION getExamenInfo (idConsultation in NUMBER) RETURN setEXAMEN_T,
    static FUNCTION getPrescriptionInfo (idConsultation in NUMBER) setPRESCRIPTION_T,
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
    POIDS NUMBER(8),
    HAUTEUR NUMBER(8),
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
    Static MEMBER FUNCTION getMedecin(idMedecin in NUMBER) RETURN MEDECIN_T,
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




-------******************* TYPE BODY ***********************-------


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

-- Implémentation des méthodes du Type CONSULTATION_T
/* Formatted on 25/09/2024 22:47:22 (QP5 v5.360) */
CREATE OR REPLACE TYPE BODY CONSULTATION_T
    AS
    STATIC FUNCTION getConsultation (idConsultation IN NUMBER)
        RETURN CONSULTATION_T
    IS
        vConsultation   CONSULTATION_T;
    BEGIN
        SELECT VALUE (oc)
          INTO vConsultation
          FROM o_consultation oc
         WHERE Id_Consultation = idConsultation;

        RETURN vConsultation;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getConsultation;

    STATIC FUNCTION getExamenInfo (idConsultation IN NUMBER)
        RETURN setEXAMEN_T
    IS
        vSetExamen   setEXAMEN_T;
    BEGIN
        SELECT CAST (collet (DEREF (lre.COLUMN_VALUE)) AS setEXAMEN_T)
          INTO vSetExamen
          FROM TABLE (SELECT oc.pListRefExamens
                        FROM o_consultation oc
                       WHERE oc.Id_Consultation = idConsultation) lre;

        RETURN vSetExamen;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getExamenInfo;


    STATIC FUNCTION getPrescriptionInfo (idConsultation IN NUMBER)
        RETURN setPRESCRIPTION_T
    IS
        vSetPrescription   setPRESCRIPTION_T;
    BEGIN
        SELECT CAST (collet (DEREF (lre.COLUMN_VALUE)) AS setPRESCRIPTION_T)
          INTO vSetPrescription
          FROM TABLE (SELECT oc.pListRefPrescriptions
                        FROM o_consultation oc
                       WHERE oc.Id_Consultation = idConsultation) lre;

        RETURN vSetPrescription;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getPrescriptionInfo;

    -- for pListRefExamens
    MEMBER PROCEDURE addLinkListeExamens (refExamens1 REF EXAMEN_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT oc.pListRefExamens
                             FROM o_consultation oc
                            WHERE oc.Id_Consultation = self.Id_Consultation)
                    lre
             VALUES (refExamens1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListeExamens (refExamens1 REF EXAMEN_T)
    IS
    BEGIN
        DELETE FROM
            TABLE (SELECT oc.pListRefExamens
                     FROM o_consultation oc
                    WHERE oc.Id_Consultation = self.Id_Consultation) lre
              WHERE lre.COLUMN_VALUE = refExamens1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListeExamens (refExamens1   REF EXAMEN_T,
                                             refExamens2   REF EXAMEN_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT oc.pListRefExamens
                        FROM o_consultation oc
                       WHERE oc.Id_Consultation = self.Id_Consultation) lre
           SET lre.COLUMN_VALUE = refExamens2
         WHERE lre.COLUMN_VALUE = refExamens1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;



    -- for pListRefPrescriptions
    MEMBER PROCEDURE addLinkListePrescriptions (
        refPrescription1   REF PRESCRIPTION_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT oc.pListRefPrescriptions
                             FROM o_consultation oc
                            WHERE oc.Id_Consultation = self.Id_Consultation)
                    lre
             VALUES (refPrescription1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListePrescriptions (
        refPrescription1   REF PRESCRIPTION_T)
    IS
    BEGIN
        DELETE FROM
            TABLE (SELECT oc.pListRefPrescriptions
                     FROM o_consultation oc
                    WHERE oc.Id_Consultation = self.Id_Consultation) lre
              WHERE lre.COLUMN_VALUE = refPrescription1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListePrescriptions (
        refPrescription1   REF PRESCRIPTION_T,
        refPrescription2   REF PRESCRIPTION_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT oc.pListRefPrescriptions
                        FROM o_consultation oc
                       WHERE oc.Id_Consultation = self.Id_Consultation) lre
           SET lre.COLUMN_VALUE = refPrescription2
         WHERE lre.COLUMN_VALUE = refPrescription1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    -- Méthode d'ordre : compare deux consultations par date
    MAP MEMBER FUNCTION compareDate
        RETURN DATE
    IS
    BEGIN
        RETURN SELF.Date_Consultation;
    END compareDate;
END;
/

CREATE OR REPLACE TYPE BODY PERSONNE_T AS
 -- Méthode de comparaison pour l'ordre
    MAP MEMBER FUNCTION compareDate RETURN DATE IS
    BEGIN
        RETURN SELF.DATE_NAISSANCE;
    END compareDate;
END;
/


/* Formatted on 25/09/2024 22:33:01 (QP5 v5.360) */
CREATE OR REPLACE TYPE BODY PATIENT_T
    AS
    STATIC FUNCTION getPatient (idPersonne IN NUMBER)
        RETURN PATIENT_T
    IS
        vPatient   PATIENT_T;
    BEGIN
        SELECT VALUE (op)
          INTO vPatient
          FROM patient_o op
         WHERE id_personne = idPersonne;

        RETURN vPatient;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getPatient;

    STATIC FUNCTION getFActureInfo (idPersonne IN NUMBER)
        RETURN setFACTURES_T
    IS
        vSetFacture   setFACTURES_T;
    BEGIN
        SELECT CAST (collet (DEREF (lre.COLUMN_VALUE)) AS setFACTURES_T)
          INTO vSetFacture
          FROM TABLE (SELECT op.pListRefFactures
                        FROM o_patient op
                       WHERE op.id_personne = idPersonne) lre;

        RETURN vSetFacture;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getFActureInfo;


    STATIC FUNCTION getConsultationInfo (idPersonne IN NUMBER)
        RETURN setCONSULTATIONS_T
    IS
        vSetConsultation   setCONSULTATIONS_T;
    BEGIN
        SELECT CAST (collet (DEREF (lre.COLUMN_VALUE)) AS setCONSULTATIONS_T)
          INTO vSetConsultation
          FROM TABLE (SELECT op.pListRefConsultations
                        FROM o_patient op
                       WHERE op.id_personne = idPersonne) lre;

        RETURN vSetConsultation;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getConsultationInfo;

    -- for pListRefRendezVous
    MEMBER PROCEDURE addLinkListeRendezVous (
        refRendezVous1   REF RENDEZ_VOUS_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT op.pListRefRendezVous
                             FROM O_PATIENT op
                            WHERE op.id_personne = self.id_personne) lre
             VALUES (refRendezVous1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListeRendezVous (
        refRendezVous1   REF RENDEZ_VOUS_T)
    IS
    BEGIN
        DELETE FROM TABLE (SELECT op.pListRefRendezVous
                             FROM O_PATIENT op
                            WHERE op.id_personne = self.id_personne) lre
              WHERE lre.COLUMN_VALUE = refRendezVous1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListeRendezVous (
        refRendezVous1   REF RENDEZ_VOUS_T,
        refRendezVous2   REF RENDEZ_VOUS_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT op.pListRefRendezVous
                        FROM O_PATIENT op
                       WHERE op.id_personne = self.id_personne) lre
           SET lre.COLUMN_VALUE = refRendezVous2
         WHERE lre.COLUMN_VALUE = refRendezVous1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;



    -- for pListRefConsultations
    MEMBER PROCEDURE addLinkListeConsultations (
        refConsultation1   REF CONSULTATION_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT op.pListRefConsultations
                             FROM O_PATIENT op
                            WHERE op.id_personne = self.id_personne) lre
             VALUES (refConsultation1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListeConsultations (
        refConsultation1   REF CONSULTATION_T)
    IS
    BEGIN
        DELETE FROM TABLE (SELECT op.pListRefConsultations
                             FROM O_PATIENT op
                            WHERE op.id_personne = self.id_personne) lre
              WHERE lre.COLUMN_VALUE = refConsultation1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListeConsultations (
        refConsultation1   REF CONSULTATION_T,
        refConsultation2   REF CONSULTATION_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT op.pListRefConsultations
                        FROM O_PATIENT op
                       WHERE op.id_personne = self.id_personne) lre
           SET lre.COLUMN_VALUE = refConsultation2
         WHERE lre.COLUMN_VALUE = refConsultation1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    -- for pListRefFactures
    MEMBER PROCEDURE addLinkListeFactures (refFacture1 REF FACTURE_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT op.pListRefFactures
                             FROM O_PATIENT op
                            WHERE op.id_personne = self.id_personne) lre
             VALUES (refFacture1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListeFactures (refFacture1 REF FACTURE_T)
    IS
    BEGIN
        DELETE FROM TABLE (SELECT op.pListRefFactures
                             FROM O_PATIENT op
                            WHERE op.id_personne = self.id_personne) lre
              WHERE lre.COLUMN_VALUE = refFacture1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListeFactures (refFacture1   REF FACTURE_T,
                                              refFacture2   REF FACTURE_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT op.pListRefFactures
                        FROM O_PATIENT op
                       WHERE op.id_personne = self.id_personne) lre
           SET lre.COLUMN_VALUE = refFacture2
         WHERE lre.COLUMN_VALUE = refFacture1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;
END;
/


/* Formatted on 26/09/2024 11:04:21 (QP5 v5.360) */
CREATE OR REPLACE TYPE BODY MEDECIN_T
    AS
    STATIC FUNCTION getMedecin (idMedecin IN NUMBER)
        RETURN MEDECIN_T
    IS
        vMedecin   MEDECIN_T;
    BEGIN
        SELECT VALUE (om)
          INTO vMedecin
          FROM o_medecin om
         WHERE Id_Personne = idMedecin;

        RETURN vMedecin;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getMedecin;

    STATIC FUNCTION getConsultationInfo (idMedecin IN NUMBER)
        RETURN setCONSULTATIONS_T
    IS
        vSetCONSULTATION   setCONSULTATIONS_T;
    BEGIN
        SELECT CAST (collet (DEREF (lre.COLUMN_VALUE)) AS setCONSULTATIONS_T)
          INTO vSetCONSULTATION
          FROM TABLE (SELECT om.pListRefRendezVous
                        FROM o_medecin om
                       WHERE om.Id_Personne = idMedecin) lre;

        RETURN vSetCONSULTATION;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getConsultationInfo;


    STATIC FUNCTION getRendezVousInfo (idMedecin IN NUMBER)
        RETURN setRENDEZ_VOUS_T
    IS
        vSetRendezVous   setRENDEZ_VOUS_T;
    BEGIN
        SELECT CAST (collet (DEREF (lre.COLUMN_VALUE)) AS setRENDEZ_VOUS_T)
          INTO vSetRendezVous
          FROM TABLE (SELECT om.pListRefRendezVous
                        FROM o_medecin om
                       WHERE om.Id_Personne = idMedecin) lre;

        RETURN vSetRendezVous;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            RAISE;
        WHEN OTHERS
        THEN
            RAISE;
    END getRendezVousInfo;

    -- for pListRefRendezVous
    MEMBER PROCEDURE addLinkListeRendezVous (
        refRendezVous1   REF RENDEZ_VOUS_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT om.pListRefRendezVous
                             FROM o_medecin om
                            WHERE om.Id_Personne = self.Id_Personne) lre
             VALUES (refRendezVous1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListeRendezVous (
        refRendezVous1   REF RENDEZ_VOUS_T)
    IS
    BEGIN
        DELETE FROM TABLE (SELECT om.pListRefRendezVous
                             FROM o_medecin om
                            WHERE om.Id_Personne = self.Id_Personne) lre
              WHERE lre.COLUMN_VALUE = refRendezVous1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListeRendezVous (
        refRendezVous1   REF RENDEZ_VOUS_T,
        refRendezVous2   REF RENDEZ_VOUS_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT om.pListRefRendezVous
                        FROM o_medecin om
                       WHERE om.Id_Personne = self.Id_Personne) lre
           SET lre.COLUMN_VALUE = refRendezVous2
         WHERE lre.COLUMN_VALUE = refRendezVous1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;



    -- for pListRefConsultations
    MEMBER PROCEDURE addLinkListeConsultations (
        refConsultation1   REF CONSULTATION_T)
    IS
    BEGIN
        INSERT INTO TABLE (SELECT om.pListRefConsultations
                             FROM o_medecin om
                            WHERE om.Id_Personne = self.Id_Personne) lre
             VALUES (refConsultation1);
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE deleteLinkListePrescriptions (
        refConsultation1   REF CONSULTATION_T)
    IS
    BEGIN
        DELETE FROM TABLE (SELECT om.pListRefConsultations
                             FROM o_medecin om
                            WHERE om.Id_Personne = self.Id_Personne) lre
              WHERE lre.COLUMN_VALUE = refConsultation1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;

    MEMBER PROCEDURE updateLinkListePrescriptions (
        refConsultation1   REF CONSULTATION_T,
        refConsultation2   REF CONSULTATION_T)
    IS
    BEGIN
        UPDATE TABLE (SELECT om.pListRefConsultations
                        FROM o_medecin om
                       WHERE om.Id_Personne = self.Id_Personne) lre
           SET lre.COLUMN_VALUE = refConsultation2
         WHERE lre.COLUMN_VALUE = refConsultation1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END;
END;
/