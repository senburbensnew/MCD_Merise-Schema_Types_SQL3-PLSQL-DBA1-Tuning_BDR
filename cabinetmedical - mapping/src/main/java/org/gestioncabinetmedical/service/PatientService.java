package org.gestioncabinetmedical.service;

import oracle.sql.REF;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;
import org.gestioncabinetmedical.entity.Examen;
import org.gestioncabinetmedical.entity.Patient;
import java.sql.*;

public class PatientService {
    private final Connection conn;

    public PatientService(Connection conn) {
        this.conn = conn;
    }

    public void insertPatient(Patient patient) throws SQLException {
        String sql = "INSERT INTO O_PATIENT (ID_PERSONNE#, NUMERO_SECURITE_SOCIALE, nom, EMAIL, sexe, date_naissance, poids, hauteur, adresse) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, patient.getID_PERSONNE());
        ps.setString(2, patient.getNUMERO_SECURITE_SOCIALE());
        ps.setString(3, patient.getNOM());
        ps.setString(4, patient.getEMAIL());
        ps.setString(5, patient.getSEXE());
        ps.setDate(6, patient.getDATE_NAISSANCE());
        ps.setFloat(7, patient.getPOIDS());
        ps.setFloat(8, patient.getHAUTEUR());

        // Map the Adresse object to STRUCT for Oracle
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor("ADRESSE_T", conn);
        Object[] adresseData = { patient.getADRESSE().getNUMERO(), patient.getADRESSE().getRUE(), patient.getADRESSE().getCODE_POSTAL(), patient.getADRESSE().getVILLE() };
        STRUCT struct = new STRUCT(structDescriptor, conn, adresseData);
        ps.setObject(9, struct);

        ps.executeUpdate();
        ps.close();
        System.out.println("Patient inserted successfully!");
    }

    public Patient getPatientById(int patientId) throws SQLException {
        String query = "SELECT * FROM O_PATIENT WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(query);
        psPatient.setInt(1, patientId);

        ResultSet rs = psPatient.executeQuery();
        Patient patient = null;

        if (rs.next()) {
            patient = new Patient();
            patient.setID_PERSONNE(rs.getInt("ID_PERSONNE#"));
            patient.setNOM(rs.getString("NOM"));
            patient.setNUMERO_SECURITE_SOCIALE(rs.getString("NUMERO_SECURITE_SOCIALE"));
        }

        rs.close();
        psPatient.close();

        return patient;
    }

    public REF getRefPatient(int patientId){
        return null;
    }

    public void updatePatient(Patient patient) {
    }

    public void deletePatient(int id) {
    }
}
