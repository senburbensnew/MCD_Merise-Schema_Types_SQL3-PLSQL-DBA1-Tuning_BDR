package org.gestioncabinetmedical;

import oracle.sql.REF;
import org.gestioncabinetmedical.entity.Adresse;
import java.io.IOException;
import java.sql.*;
import oracle.jdbc.pool.OracleDataSource;
import org.gestioncabinetmedical.entity.Medecin;
import org.gestioncabinetmedical.entity.Patient;
import org.gestioncabinetmedical.service.ConsultationService;
import org.gestioncabinetmedical.service.ExamenService;
import org.gestioncabinetmedical.service.MedecinService;
import org.gestioncabinetmedical.service.PatientService;

public class Main{
    public static void main(String[] args) throws SQLException {
        Connection conn = null;
        String jdbcUrl = "jdbc:oracle:thin:@localhost:1521:xe";
        String user = "Oracle";
        String password = "password";

        try {
            OracleDataSource ods = new OracleDataSource();
            ods.setURL(jdbcUrl);
            ods.setUser(user);
            ods.setPassword(password);

            conn = ods.getConnection();
            conn.setAutoCommit(true);

            ExamenService examenService = new ExamenService(conn);
            ConsultationService consultationService = new ConsultationService(conn);
            PatientService patientService = new PatientService(conn);
            MedecinService medecinService = new MedecinService(conn);

            /** Patient test */
            // Insert Patient
            Adresse adresse = new Adresse();
            adresse.setNUMERO(123);
            adresse.setRUE("Rue de Paris");
            adresse.setCODE_POSTAL(75000);
            adresse.setVILLE("Paris");

            Patient patient = new Patient();
            patient.setID_PERSONNE(2001);
            patient.setNUMERO_SECURITE_SOCIALE("66373578");
            patient.setSEXE("Masculin");
            patient.setEMAIL("eami5@gmail.com");
            patient.setDATE_NAISSANCE(Date.valueOf("2024-10-06"));
            patient.setPOIDS(56.4F);
            patient.setHAUTEUR(190.8F);
            patient.setNOM("John Doe");
            patient.setADRESSE(adresse);

            patientService.insertPatient(patient);

            // Get Patient by Id
            Patient retrievedPatient  = patientService.getPatientById(2001);
            retrievedPatient.display();

            // Get REF to patient by id
            REF refPatient = patientService.getRefPatient(2001);
            System.out.println(refPatient);

            // Update patient
            retrievedPatient.setPOIDS(140.6F);
            patientService.updatePatient(retrievedPatient);

            // Delete Patient
            patientService.deletePatient(2001);

            /** Medecin test */
            // Insert Medecin
            Adresse adresseMedecin = new Adresse();
            adresseMedecin.setNUMERO(7);
            adresseMedecin.setRUE("Rue de Marseille");
            adresseMedecin.setCODE_POSTAL(10000);
            adresseMedecin.setVILLE("Marseille");

            Medecin medecin = new Medecin();
            medecin.setID_PERSONNE(2001);
            medecin.setNUMERO_SECURITE_SOCIALE("234509");
            medecin.setSEXE("Feminin");
            medecin.setEMAIL("medein@gmail.com");
            medecin.setDATE_NAISSANCE(Date.valueOf("2025-09-01"));
            medecin.setNOM("John Doe medecin");
            medecin.setADRESSE(adresse);

            medecinService.insertMedecin(medecin);


            /*
                // Get REF of Consultation
                REF refConsultation = consultationService.getRefConsultation(1);

                // Insert Examen
                Examen examen = new Examen(3000, refConsultation, "Blood Test", Date.valueOf("2024-10-06"));
                examenService.insertExamen(examen);

                // Get Examen by Id and display
                Examen insertedExamen = examenService.getExamenById(3000);
                insertedExamen.display();
            */
        }catch(SQLException | IOException e){
            System.out.println("Echec du mapping");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }finally {
            conn.close();
        }
    }
}