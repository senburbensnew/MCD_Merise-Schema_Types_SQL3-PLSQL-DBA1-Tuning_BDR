DECLARE
    v_rv  RENDEZ_VOUS_T;
    v_patient PATIENT_T;
    v_nouveau_patient_ref ref PATIENT_T;
    v_medecin MEDECIN_T;
    v_nouveau_medecin_ref ref MEDECIN_T;
    
    v_prenom_patient varchar2(100);
    v_prenom_medecin varchar2(100);
    
    v_nom_test varchar2(100);
BEGIN
    -- Get the reference to the rendez-vous
    SELECT value(rv) INTO v_rv FROM O_RENDEZ_VOUS rv WHERE rv.Id_Rendez_Vous = 1;
    
    -- test methode getRefPatient() et getRefMedecin()
    -- Dereference the patient reference to get the PATIENT_T object
    SELECT DEREF(v_rv.getRefPatient()) INTO v_patient FROM dual;
    
    -- Dereference the medecin reference to get the MEDECIN_T object
    SELECT DEREF(v_rv.getRefMedecin()) INTO v_medecin FROM dual;

    -- Boucle pour parcourir et afficher les éléments du VARRAY
    FOR i IN 1.. v_patient.LIST_PRENOMS.COUNT LOOP
        v_prenom_patient := v_prenom_patient ||' '|| v_patient.LIST_PRENOMS(i);
    END LOOP;
     
    -- Output the patient's details
    -- Info sur le patient pour le rendez-vous choisi
    DBMS_OUTPUT.PUT_LINE('***** Info sur le patient pour le rendez-vous du ' ||v_rv.DATE_RENDEZ_VOUS  || '*****');
    DBMS_OUTPUT.PUT_LINE('Patient Nom: ' || v_patient.nom);
    DBMS_OUTPUT.PUT_LINE('Patient Prenom: ' || v_prenom_patient);
    DBMS_OUTPUT.PUT_LINE('Patient Email: ' || v_patient.email);
    DBMS_OUTPUT.PUT_LINE('Patient Sexe: ' || v_patient.sexe);
    DBMS_OUTPUT.PUT_LINE(' ');
    
    -- Info sur le patient pour le rendez-vous choisi
    -- Boucle pour parcourir et afficher les éléments du VARRAY
    FOR i IN 1.. v_patient.LIST_PRENOMS.COUNT LOOP
        v_prenom_medecin := v_prenom_medecin ||' '|| v_medecin.LIST_PRENOMS(i);
    END LOOP;
   
    DBMS_OUTPUT.PUT_LINE('***** Info sur le médecin pour le rendez-vous du ' ||v_rv.DATE_RENDEZ_VOUS  || '*****');
    DBMS_OUTPUT.PUT_LINE('Médecin Nom: ' || v_medecin.nom);
    DBMS_OUTPUT.PUT_LINE('Médecin Prenom: ' || v_prenom_medecin);
    DBMS_OUTPUT.PUT_LINE('Médecin Email: ' || v_medecin.email);
    DBMS_OUTPUT.PUT_LINE('Médecin Sécialité: '|| v_medecin.specialite);
    DBMS_OUTPUT.PUT_LINE('Médecin Sexe: '|| v_medecin.sexe);
    
    -- teste methode  updateMotif()
    -- Modifier le motif -- 
    DBMS_OUTPUT.PUT_LINE('Motif initial: '||v_rv.MOTIF );
    -- Mise à jour du motif du rendez-vous
    v_rv.updateMotif('Consultation de suivi');
    -- affichage du Motif après modification
    DBMS_OUTPUT.PUT_LINE('Motif ares modification: '||v_rv.MOTIF  );
    
    -- teste des methodes linkToPatient() et linkToMedecin()
    -- Sélectionner un nouveau patient et un nouveau médecin pour tester les méthodes de lien
    SELECT REF(p) INTO v_nouveau_patient FROM O_PATIENT p WHERE p.ID_PERSONNE  = 5;
    SELECT REF(m) INTO v_nouveau_medecin FROM O_MEDECIN m WHERE m.ID_PERSONNE  = 5;
    -- Associer un nouveau patient et un nouveau médecin au rendez-vous
    v_rv.linkToPatient(v_nouveau_patient_ref);
    v_rv.linkToMedecin(v_nouveau_medecin_ref);
    
    v_nom_test :=  deref(v_rv.getRefMedecin()).nom;
    -- afficher nouveau medecin et patient du rendez-vous
    --DBMS_OUTPUT.PUT_LINE('Médecin : ' || v_rv.getRefMedecin().nom ||' '||' '|| v_medecin.email||' '|| v_medecin.specialite ); 
    DBMS_OUTPUT.PUT_LINE('Patient : ' || v_patient.nom ||' '||' '|| v_patient.email); 
    -- enregistrer le motif dans la table O_RENDEZ_VOUS  après modification 
    update O_RENDEZ_VOUS orv
    set orv = v_rv
    where orv.id_rendez_vous = 1;
    
    -- Valider les changements
    --COMMIT;

    DBMS_OUTPUT.PUT_LINE('Mise à jour réussie.');
    
END;