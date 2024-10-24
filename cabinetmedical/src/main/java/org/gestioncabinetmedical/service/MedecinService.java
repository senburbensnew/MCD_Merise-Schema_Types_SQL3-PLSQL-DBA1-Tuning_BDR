package org.gestioncabinetmedical.service;

import oracle.sql.REF;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;
import org.gestioncabinetmedical.entity.Adresse;
import org.gestioncabinetmedical.entity.Medecin;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class MedecinService {

    private final Connection conn;

    public MedecinService(Connection conn) {
        this.conn = conn;
    }

    public void insertMedecin(Medecin medecin) throws SQLException {
        String sql = "INSERT INTO O_MEDECIN (ID_PERSONNE#, NUMERO_SECURITE_SOCIALE, nom, EMAIL, sexe, date_naissance, specialite, adresse) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, medecin.getID_PERSONNE());
        ps.setString(2, medecin.getNUMERO_SECURITE_SOCIALE());
        ps.setString(3, medecin.getNOM());
        ps.setString(4, medecin.getEMAIL());
        ps.setString(5, medecin.getSEXE());
        ps.setDate(6, medecin.getDATE_NAISSANCE());
        ps.setString(7, medecin.getSpecialite());

        // Map the Adresse object to STRUCT for Oracle
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor("ADRESSE_T", conn);
        Object[] adresseData = {
                medecin.getADRESSE().getNUMERO(),
                medecin.getADRESSE().getRUE(),
                medecin.getADRESSE().getCODE_POSTAL(),
                medecin.getADRESSE().getVILLE()
        };
        STRUCT struct = new STRUCT(structDescriptor, conn, adresseData);
        ps.setObject(8, struct);

        ps.executeUpdate();
        ps.close();

        System.out.println("Medecin inserted successfully!");
    }

    public Medecin getMedecinById(int id) throws SQLException {
        String query = "SELECT * FROM O_MEDECIN WHERE ID_PERSONNE# = ?";
        PreparedStatement psMedecin = conn.prepareStatement(query);
        psMedecin.setInt(1, id);

        ResultSet rs = psMedecin.executeQuery();
        Medecin medecin = null;

        if (rs.next()) {
            medecin = new Medecin();
            medecin.setID_PERSONNE(rs.getInt("ID_PERSONNE#"));
            medecin.setNOM(rs.getString("NOM"));
            medecin.setNUMERO_SECURITE_SOCIALE(rs.getString("NUMERO_SECURITE_SOCIALE"));
            medecin.setSpecialite(rs.getString("SPECIALITE"));
            medecin.setSEXE(rs.getString("SEXE"));
            medecin.setEMAIL(rs.getString("EMAIL"));
            medecin.setDATE_NAISSANCE(rs.getDate("date_naissance"));

            STRUCT addressStruct = (STRUCT) rs.getObject("adresse");
            medecin.setADRESSE(parseAddress(addressStruct));
        }

        rs.close();
        psMedecin.close();

        return medecin;
    }

    public void updateMedecin(Medecin medecin) throws SQLException {
        String sql = "UPDATE O_MEDECIN SET ID_PERSONNE# = ?, NUMERO_SECURITE_SOCIALE = ?, nom = ?, EMAIL = ?, sexe = ?, date_naissance = ?, specialite = ?, adresse = ? WHERE ID_PERSONNE# = ?";
        PreparedStatement psMedecin = conn.prepareStatement(sql);
        psMedecin.setInt(1, medecin.getID_PERSONNE());
        psMedecin.setString(2, medecin.getNUMERO_SECURITE_SOCIALE());
        psMedecin.setString(3, medecin.getNOM());
        psMedecin.setString(4, medecin.getEMAIL());
        psMedecin.setString(5, medecin.getSEXE());
        psMedecin.setDate(6, medecin.getDATE_NAISSANCE());
        psMedecin.setString(7, medecin.getSpecialite());

        // Map the Adresse object to STRUCT for Oracle
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor("ADRESSE_T", conn);
        Object[] adresseData = {
                medecin.getADRESSE().getNUMERO(),
                medecin.getADRESSE().getRUE(),
                medecin.getADRESSE().getCODE_POSTAL(),
                medecin.getADRESSE().getVILLE()
        };
        STRUCT struct = new STRUCT(structDescriptor, conn, adresseData);
        psMedecin.setObject(8, struct);
        psMedecin.setInt(9, medecin.getID_PERSONNE());

        psMedecin.executeUpdate();
        psMedecin.close();

        System.out.println("Medecin updated successfully!");
    }

    public void deleteMedecin(int id) throws SQLException {
        String query = "DELETE FROM O_MEDECIN WHERE ID_PERSONNE# = ?";
        PreparedStatement psMedecin = conn.prepareStatement(query);
        psMedecin.setInt(1, id);

        psMedecin.executeUpdate();
        psMedecin.close();

        System.out.println("Medecin deleted successfully!");
    }

    public REF getRefMedecin(int id) throws SQLException {
        String query = "SELECT REF(om) FROM O_MEDECIN om WHERE ID_PERSONNE# = ?";
        PreparedStatement psMedecin = conn.prepareStatement(query);
        psMedecin.setInt(1, id);

        ResultSet rs = psMedecin.executeQuery();
        REF refMedecin = null;

        if (rs.next()) {
            refMedecin = (REF) rs.getRef(1);
        }

        rs.close();
        psMedecin.close();

        return refMedecin;
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
