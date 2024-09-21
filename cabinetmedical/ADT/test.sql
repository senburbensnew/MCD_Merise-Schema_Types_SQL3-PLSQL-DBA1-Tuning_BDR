-- Type PATIENT_T
CREATE OR REPLACE TYPE PATIENT_T UNDER PERSONNE_T(
    POIDS NUMBER(8),
    HAUTEUR NUMBER(8),
    pListRefRendezVous ListRefRendezVous_t,
    pListRefConsultations ListRefConsultations_t,
    pListRefFactures ListRefFactures_t,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION compareTo(otherPatient REF PATIENT_T) RETURN NUMBER, -- Méthode d'ordre
    MEMBER PROCEDURE addRendezVous(rv REF RENDEZ_VOUS_T), -- Gestion des liens
    MEMBER PROCEDURE addConsultation(c REF CONSULTATION_T), -- Gestion des liens
    MEMBER PROCEDURE addFacture(f REF FACTURE_T), -- Gestion des liens
    MEMBER FUNCTION getRendezVous RETURN ListRefRendezVous_t, -- Consultation
    MEMBER FUNCTION getConsultations RETURN ListRefConsultations_t, -- Consultation
    MEMBER FUNCTION getFactures RETURN ListRefFactures_t, -- Consultation
    MEMBER PROCEDURE updatePoids(newPoids NUMBER), -- Méthode CRUD (update)
    MEMBER PROCEDURE updateHauteur(newHauteur NUMBER), -- Méthode CRUD (update)
    MEMBER PROCEDURE deletePatient                    -- Méthode CRUD (delete)
);
/

-- Type MEDECIN_T
CREATE OR REPLACE TYPE MEDECIN_T UNDER PERSONNE_T(
    Specialite VARCHAR2(40),
    CV CLOB,
    pListRefRendezVous ListRefRendezVous_t,
    pListRefConsultations ListRefConsultations_t,

    -- Méthodes
    MEMBER FUNCTION getId RETURN NUMBER,
    MEMBER FUNCTION compareTo(otherMedecin REF MEDECIN_T) RETURN NUMBER, -- Méthode d'ordre
    MEMBER PROCEDURE addRendezVous(rv REF RENDEZ_VOUS_T), -- Gestion des liens
    MEMBER PROCEDURE addConsultation(c REF CONSULTATION_T), -- Gestion des liens
    MEMBER FUNCTION getRendezVous RETURN ListRefRendezVous_t, -- Consultation
    MEMBER FUNCTION getConsultations RETURN ListRefConsultations_t, -- Consultation
    MEMBER PROCEDURE updateSpecialite(newSpecialite VARCHAR2), -- Méthode CRUD (update)
    MEMBER PROCEDURE deleteMedecin                            -- Méthode CRUD (delete)
);
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

    -- Méthodes
    MAP MEMBER FUNCTION MATCH RETURN VARCHAR2,
    MEMBER FUNCTION compareTo(otherPersonne REF PERSONNE_T) RETURN NUMBER -- Méthode d'ordre
) NOT INSTANTIABLE NOT FINAL;
/
