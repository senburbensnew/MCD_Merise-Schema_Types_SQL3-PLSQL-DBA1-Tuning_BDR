package org.gestioncabinetmedical.entity;

import oracle.sql.REF;

import java.sql.*;

import oracle.sql.ARRAY;

public class Consultation implements SQLData {
    protected String sql_type;
    private int Id_Consultation;
    private REF refPatient;
    private REF refMedecin;
    private String Raison;
    private String Diagnostic;
    private Date Date_Consultation;
    private ARRAY pListRefExamens;
    private ARRAY pListRefPrescriptions;

    public Consultation() {}

    public Consultation(String sql_type, int id_Consultation, REF refPatient, REF refMedecin, String raison, String diagnostic, Date date_Consultation, ARRAY pListRefExamens, ARRAY pListRefPrescriptions) {
        this.sql_type = sql_type;
        this.Id_Consultation = id_Consultation;
        this.refPatient = refPatient;
        this.refMedecin = refMedecin;
        this.Raison = raison;
        this.Diagnostic = diagnostic;
        this.Date_Consultation = date_Consultation;
        this.pListRefExamens = pListRefExamens;
        this.pListRefPrescriptions = pListRefPrescriptions;
    }

    public String getSql_type() {
        return sql_type;
    }

    public int getId_Consultation() {
        return Id_Consultation;
    }

    public void setId_Consultation(int id_Consultation) {
        Id_Consultation = id_Consultation;
    }

    public REF getRefPatient() {
        return refPatient;
    }

    public void setRefPatient(REF refPatient) {
        this.refPatient = refPatient;
    }

    public REF getRefMedecin() {
        return refMedecin;
    }

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
    }

    public void setRefMedecin(REF refMedecin) {
        this.refMedecin = refMedecin;
    }

    public String getRaison() {
        return Raison;
    }

    public void setRaison(String raison) {
        Raison = raison;
    }

    public String getDiagnostic() {
        return Diagnostic;
    }

    public void setDiagnostic(String diagnostic) {
        Diagnostic = diagnostic;
    }

    public Date getDate_Consultation() {
        return Date_Consultation;
    }

    public void setDate_Consultation(Date date_Consultation) {
        Date_Consultation = date_Consultation;
    }

    public ARRAY getpListRefExamens(){
        return pListRefExamens;
    }

    public void setpListRefExamens(ARRAY pListRefExamens) {
        this.pListRefExamens = pListRefExamens;
    }

    public ARRAY getpListRefPrescriptions() {
        return pListRefPrescriptions;
    }

    public void setpListRefPrescriptions(ARRAY pListRefPrescriptions) {
        this.pListRefPrescriptions = pListRefPrescriptions;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return this.getSql_type();
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.setSql_type(typeName);
        this.Id_Consultation = stream.readInt();
        this.refPatient = (REF)stream.readRef();
        this.refMedecin = (REF)stream.readRef();
        this.Raison = stream.readString();
        this.Diagnostic = stream.readString();
        this.Date_Consultation = stream.readDate();
        this.pListRefExamens = (ARRAY)stream.readArray();
        this.pListRefPrescriptions = (ARRAY)stream.readArray();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(this.Id_Consultation);
        stream.writeRef(this.refPatient);
        stream.writeRef(this.refMedecin);
        stream.writeString(this.Raison);
        stream.writeString(this.Diagnostic);
        stream.writeDate(this.Date_Consultation);
        stream.writeArray(this.pListRefExamens);
        stream.writeArray(this.pListRefPrescriptions);
    }
}
