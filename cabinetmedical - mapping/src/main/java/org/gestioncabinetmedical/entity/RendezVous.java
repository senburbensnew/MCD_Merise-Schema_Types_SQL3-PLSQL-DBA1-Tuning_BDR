package org.gestioncabinetmedical.entity;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

import oracle.sql.REF;

public class RendezVous implements SQLData {
    protected String sql_type;
    private int Id_Rendez_Vous;
    private REF refPatient;
    private REF refMedecin;
    private Date Date_Rendez_Vous;
    private String Motif;

    public RendezVous(){}

    public RendezVous(String sql_type, int id_Rendez_Vous, REF refPatient, REF refMedecin, Date date_Rendez_Vous, String motif) {
        this.sql_type = sql_type;
        this.Id_Rendez_Vous = id_Rendez_Vous;
        this.refPatient = refPatient;
        this.refMedecin = refMedecin;
        this.Date_Rendez_Vous = date_Rendez_Vous;
        this.Motif = motif;
    }

    public String getSql_type() {
        return sql_type;
    }

    public int getId_Rendez_Vous() {
        return Id_Rendez_Vous;
    }

    public void setId_Rendez_Vous(int id_Rendez_Vous) {
        Id_Rendez_Vous = id_Rendez_Vous;
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

    public void setRefMedecin(REF refMedecin) {
        this.refMedecin = refMedecin;
    }

    public Date getDate_Rendez_Vous() {
        return Date_Rendez_Vous;
    }

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
    }

    public void setDate_Rendez_Vous(Date date_Rendez_Vous) {
        Date_Rendez_Vous = date_Rendez_Vous;
    }

    public String getMotif() {
        return Motif;
    }

    public void setMotif(String motif) {
        Motif = motif;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return this.getSql_type();
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.setSql_type(typeName);
        this.Id_Rendez_Vous = stream.readInt();
        this.refPatient = (REF)stream.readRef();
        this.refMedecin = (REF)stream.readRef();
        this.Date_Rendez_Vous = stream.readDate();
        this.Motif = stream.readString();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(this.Id_Rendez_Vous);
        stream.writeRef(this.refPatient);
        stream.writeRef(this.refMedecin);
        stream.writeDate((java.sql.Date) this.Date_Rendez_Vous);
        stream.writeString(this.Motif);
    }
}
