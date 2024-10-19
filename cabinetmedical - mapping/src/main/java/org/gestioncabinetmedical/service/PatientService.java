package org.gestioncabinetmedical.service;

import oracle.sql.REF;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;
import org.gestioncabinetmedical.entity.Adresse;
import org.gestioncabinetmedical.entity.Patient;
import java.math.BigDecimal;
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
        Object[] adresseData = {
                patient.getADRESSE().getNUMERO(),
                patient.getADRESSE().getRUE(),
                patient.getADRESSE().getCODE_POSTAL(),
                patient.getADRESSE().getVILLE()
        };
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
            patient.setHAUTEUR(rs.getFloat("HAUTEUR"));
            patient.setPOIDS(rs.getFloat("POIDS"));
            patient.setSEXE(rs.getString("SEXE"));
            patient.setEMAIL(rs.getString("EMAIL"));
            patient.setDATE_NAISSANCE(rs.getDate("date_naissance"));

            STRUCT addressStruct = (STRUCT) rs.getObject("adresse");
            patient.setADRESSE(parseAddress(addressStruct));

            // Array phoneArray = rs.getArray("List_Telephones");
            // patient.setLIST_TELEPHONES((ARRAY) phoneArray.getArray());

            // Array prenomArray = rs.getArray("List_Prenoms");
            // patient.setLIST_PRENOMS((ARRAY) prenomArray.getArray());
        }

        rs.close();
        psPatient.close();

        return patient;
    }

    public REF getRefPatient(int patientId) throws SQLException {
        String query = "SELECT REF(op) FROM O_PATIENT op WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(query);
        psPatient.setInt(1, patientId);

        ResultSet rs = psPatient.executeQuery();
        REF refPatient = null;

        if (rs.next()) {
            refPatient = (REF) rs.getRef(1);
        }

        rs.close();
        psPatient.close();

        return refPatient;
    }

    public void updatePatient(Patient patient) throws SQLException {
        String sql = "UPDATE O_PATIENT SET ID_PERSONNE# = ?, NUMERO_SECURITE_SOCIALE = ?, nom = ?, EMAIL = ?, sexe = ?, date_naissance = ?, poids = ?, hauteur = ?, adresse = ? WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(sql);
        psPatient.setInt(1, patient.getID_PERSONNE());
        psPatient.setString(2, patient.getNUMERO_SECURITE_SOCIALE());
        psPatient.setString(3, patient.getNOM());
        psPatient.setString(4, patient.getEMAIL());
        psPatient.setString(5, patient.getSEXE());
        psPatient.setDate(6, patient.getDATE_NAISSANCE());
        psPatient.setFloat(7, patient.getPOIDS());
        psPatient.setFloat(8, patient.getHAUTEUR());

        // Map the Adresse object to STRUCT for Oracle
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor("ADRESSE_T", conn);
        Object[] adresseData = {
                patient.getADRESSE().getNUMERO(),
                patient.getADRESSE().getRUE(),
                patient.getADRESSE().getCODE_POSTAL(),
                patient.getADRESSE().getVILLE()
        };
        STRUCT struct = new STRUCT(structDescriptor, conn, adresseData);
        psPatient.setObject(9, struct);
        psPatient.setInt(10, patient.getID_PERSONNE());

        psPatient.executeUpdate();
        psPatient.close();

        System.out.println("Patient updated successfully!");
    }

    public void deletePatient(int patientId) throws SQLException {
        String query = "DELETE FROM O_PATIENT WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(query);
        psPatient.setInt(1, patientId);

        psPatient.executeUpdate();
        psPatient.close();

        System.out.println("Patient deleted successfully!");
    }

    private Adresse parseAddress(STRUCT addressStruct) throws SQLException {
        Object[] attrs = addressStruct.getAttributes();
        Adresse adresse = new Adresse();
        adresse.setNUMERO(((BigDecimal) attrs[0]).intValue());
        adresse.setRUE((String) attrs[1]);
        adresse.setCODE_POSTAL(((BigDecimal) attrs[2]).intValue());
        adresse.setVILLE((String) attrs[3]);
        return adresse;
    }
}
