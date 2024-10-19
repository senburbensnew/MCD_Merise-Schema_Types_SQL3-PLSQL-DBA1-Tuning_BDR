package org.gestioncabinetmedical.entity;

import oracle.sql.REF;

import java.io.IOException;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

public class Examen implements SQLData {
    private String sql_type = "EXAMEN_T";
    private int Id_Examen;
    private REF refConsultation;
    private String Details_Examen;
    private Date Date_Examen;

    public Examen() {}

    public Examen(int id_Examen, REF refConsultation, String details_Examen, Date date_Examen) {
        this.Id_Examen = id_Examen;
        this.refConsultation = refConsultation;
        this.Details_Examen = details_Examen;
        this.Date_Examen = date_Examen;
    }

    public int getId_Examen() {
        return Id_Examen;
    }

    public REF getRefConsultation() {
        return refConsultation;
    }

    public String getDetails_Examen() {
        return Details_Examen;
    }

    public Date getDate_Examen() {
        return Date_Examen;
    }

    public void setId_Examen(int id_Examen) {
        Id_Examen = id_Examen;
    }

    public void setRefConsultation(REF refConsultation) {
        this.refConsultation = refConsultation;
    }

    public void setDetails_Examen(String details_Examen) {
        Details_Examen = details_Examen;
    }

    public void setDate_Examen(Date date_Examen) {
        Date_Examen = date_Examen;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return this.sql_type;
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.sql_type = typeName;
        this.Id_Examen = stream.readInt();
        this.refConsultation = (REF)stream.readRef();
        this.Details_Examen = stream.readString();
        this.Date_Examen = (Date)stream.readRef();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(this.Id_Examen);
        stream.writeRef(this.refConsultation);
        stream.writeString(this.Details_Examen);
        stream.writeDate((java.sql.Date) this.Date_Examen);
    }

    public void display() throws SQLException, IOException {
        System.out.println(this.sql_type);
        System.out.println(this.getId_Examen());
        // this.displayInfoConsultationFromRef();
        System.out.println(this.getDetails_Examen());
        System.out.println(this.getDate_Examen());
    }

    public void displayInfoConsultationFromRef() throws SQLException{
        REF refConsultation = this.getRefConsultation();
        Consultation consultation = (Consultation) refConsultation.getObject();
        System.out.println("Consultation = " + consultation.toString());
    }
}
