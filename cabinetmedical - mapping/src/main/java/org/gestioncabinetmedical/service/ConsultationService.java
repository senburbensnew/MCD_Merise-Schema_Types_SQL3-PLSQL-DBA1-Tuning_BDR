package org.gestioncabinetmedical.service;

import oracle.sql.REF;
import org.gestioncabinetmedical.entity.Consultation;

import java.sql.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ConsultationService {
    private final Connection conn;

    public ConsultationService(Connection conn){
        this.conn = conn;
    }

    public void insertConsultation(Consultation consultation){
        // 1. Insert Consultation
        // String consultationSQL = "INSERT INTO O_CONSULTATION (Id_Consultation#, PatientName, MedecinName, Date_Consultation) VALUES (?, ?, ?, ?)";
        // PreparedStatement psConsultation = conn.prepareStatement(consultationSQL);

        // psConsultation.setInt(1, 1);
        // psConsultation.setString(2, "John Doe");
        // psConsultation.setString(3, "Dr. Smith");
        // psConsultation.setDate(4, Date.valueOf("2024-01-15"));
        // psConsultation.executeUpdate();
    }

    public REF getRefConsultation(int consultationId) throws SQLException {
        String refQuery = "SELECT REF(c) FROM O_CONSULTATION c WHERE c.Id_Consultation# = ?";
        PreparedStatement psRef = conn.prepareStatement(refQuery);
        psRef.setInt(1, consultationId);
        ResultSet rsRef = psRef.executeQuery();
        REF refConsultation = null;

        if (rsRef.next()) {
            refConsultation = (REF) rsRef.getRef(1);
        }

        psRef.close();
        rsRef.close();

        return refConsultation;
    }

    public Consultation getConsultationById(int consultationId){
        return null;
    }
}
