package org.gestioncabinetmedical;

import oracle.sql.REF;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

public class Prescription implements SQLData {
    protected String sql_type;
    private int Id_Prescription;
    private REF refConsultation;
    private String Details_Prescription;
    private Date Date_Prescription;

    public Prescription(){}

    public Prescription(String sql_type, int id_Prescription, REF refConsultation, String details_Prescription, Date date_Prescription) {
        this.sql_type = sql_type;
        this.Id_Prescription = id_Prescription;
        this.refConsultation = refConsultation;
        this.Details_Prescription = details_Prescription;
        this.Date_Prescription = date_Prescription;
    }

    public String getSql_type() {
        return sql_type;
    }

    public int getId_Prescription() {
        return Id_Prescription;
    }

    public REF getRefConsultation() {
        return refConsultation;
    }

    public String getDetails_Prescription() {
        return Details_Prescription;
    }

    public Date getDate_Prescription() {
        return Date_Prescription;
    }

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
    }

    public void setId_Prescription(int id_Prescription) {
        Id_Prescription = id_Prescription;
    }

    public void setRefConsultation(REF refConsultation) {
        this.refConsultation = refConsultation;
    }

    public void setDetails_Prescription(String details_Prescription) {
        Details_Prescription = details_Prescription;
    }

    public void setDate_Prescription(Date date_Prescription) {
        Date_Prescription = date_Prescription;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return this.getSql_type();
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.setSql_type(typeName);
        this.Id_Prescription = stream.readInt();
        this.Details_Prescription = stream.readString();
        this.Date_Prescription = stream.readDate();
        this.refConsultation = (REF)stream.readObject();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(this.Id_Prescription);
        stream.writeString(this.Details_Prescription);
        stream.writeDate((java.sql.Date) this.Date_Prescription);
        stream.writeRef(this.refConsultation);
    }
}
