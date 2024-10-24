package org.gestioncabinetmedical.service;

import oracle.sql.REF;
import org.gestioncabinetmedical.entity.Examen;

import java.sql.*;

public class ExamenService {
    private final Connection conn;

    public ExamenService(Connection conn){
        this.conn = conn;
    }

    public void insertExamen(Examen examen) throws SQLException {
        String examenSQL = "INSERT INTO O_EXAMEN (Id_Examen#, refConsultation, Details_Examen, Date_Examen) VALUES (?, ?, ?, ?)";
        PreparedStatement psExamen = conn.prepareStatement(examenSQL);

        psExamen.setInt(1, examen.getId_Examen());
        psExamen.setRef(2, examen.getRefConsultation());
        psExamen.setString(3, examen.getDetails_Examen());
        psExamen.setDate(4, (Date) examen.getDate_Examen());

        psExamen.executeUpdate();
        psExamen.close();

        System.out.println("Examen inserted successfully!");
    }

    public Examen getExamenById(int examenId) throws SQLException {
        String query = "SELECT Id_Examen#, refConsultation, Details_Examen, Date_Examen FROM O_EXAMEN WHERE Id_Examen# = ?";
        PreparedStatement psExamen = conn.prepareStatement(query);
        psExamen.setInt(1, examenId);

        ResultSet rs = psExamen.executeQuery();
        Examen examen = null;

        if (rs.next()) {
            examen = new Examen();
            examen.setId_Examen(rs.getInt("Id_Examen#"));
            examen.setRefConsultation((REF) rs.getRef("refConsultation"));
            examen.setDetails_Examen(rs.getString("Details_Examen"));
            examen.setDate_Examen(rs.getDate("Date_Examen"));
        }

        rs.close();
        psExamen.close();

        return examen;
    }
}
