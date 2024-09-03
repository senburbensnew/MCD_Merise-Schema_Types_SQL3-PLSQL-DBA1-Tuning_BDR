package org.gestioncabinetmedical;

import oracle.sql.REF;

import java.sql.*;
import java.util.Date;

public class Facture implements SQLData {
    protected String sql_type;
    private int Id_Facture;
    private REF refPatient;
    private REF refConsultation;
    private float Montant_Total;
    private Date Date_Facture;

    public Facture() {}

    public Facture(String sql_type, int id_Facture, REF refPatient, REF refConsultation, float montant_Total, Date date_Facture) {
        this.Id_Facture = id_Facture;
        this.refPatient = refPatient;
        this.refConsultation = refConsultation;
        Montant_Total = montant_Total;
        Date_Facture = date_Facture;
    }

    public String getSql_type() {
        return sql_type;
    }

    public int getId_Facture() {
        return Id_Facture;
    }

    public void setId_Facture(int id_Facture) {
        Id_Facture = id_Facture;
    }

    public REF getRefPatient() {
        return refPatient;
    }

    public void setRefPatient(REF refPatient) {
        this.refPatient = refPatient;
    }

    public REF getRefConsultation() {
        return refConsultation;
    }

    public void setRefConsultation(REF refConsultation) {
        this.refConsultation = refConsultation;
    }

    public float getMontant_Total() {
        return Montant_Total;
    }

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
    }

    public void setMontant_Total(float montant_Total) {
        Montant_Total = montant_Total;
    }

    public Date getDate_Facture() {
        return Date_Facture;
    }

    public void setDate_Facture(Date date_Facture) {
        Date_Facture = date_Facture;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return this.getSql_type();
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.setSql_type(typeName);
        this.Id_Facture = stream.readInt();
        this.refPatient = (REF) stream.readObject();
        this.refConsultation = (REF) stream.readObject();
        this.Montant_Total = stream.readFloat();
        this.Date_Facture = stream.readDate();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(Id_Facture);
        stream.writeRef(refPatient);
        stream.writeRef(refConsultation);
        stream.writeFloat(Montant_Total);
        stream.writeDate((java.sql.Date) this.Date_Facture);
    }

    public void display() throws SQLException {
        System.out.println(this.getSql_type());
        System.out.println("ID " + this.getId_Facture());
        this.displayInfoPatientFromRef();
        this.displayInfoConsultationFromRef();
        System.out.println("Montant total " + this.getMontant_Total());
        System.out.println("Date Facture " + this.getDate_Facture());
    }

    public void displayInfoPatientFromRef() throws SQLException{
        REF refPatient = this.getRefPatient();
        Patient patient = (Patient) refPatient.getObject();
        System.out.println("Patient = " + patient.toString());
    }

    public void displayInfoConsultationFromRef() throws SQLException{
        REF refConsultation = this.getRefConsultation();
        Consultation consultation = (Consultation) refConsultation.getObject();
        System.out.println("Consultation = " + consultation.toString());
    }
}
