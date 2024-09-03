package org.gestioncabinetmedical;

import java.io.IOException;
import java.sql.*;
import oracle.sql.ARRAY;
import oracle.sql.CLOB;

public class Medecin extends Personne implements SQLData {
    protected String sql_type;
    private String Specialite;
    private CLOB CV;
    private ARRAY pListRefRendezVous;
    private ARRAY pListRefConsultations;

    public Medecin() {}

    public Medecin(
            int ID_PERSONNE,
            String NUMERO_SECURITE_SOCIALE,
            String NOM,
            String EMAIL,
            Adresse ADRESSE,
            String SEXE,
            Date DATE_NAISSANCE,
            ARRAY LIST_TELEPHONES,
            ARRAY LIST_PRENOMS,
            String sql_type,
            String Specialite,
            CLOB CV,
            ARRAY pListRefRendezVous,
            ARRAY pListRefConsultations
    ) {
        super(ID_PERSONNE, NUMERO_SECURITE_SOCIALE, NOM, EMAIL, ADRESSE, SEXE, DATE_NAISSANCE, LIST_TELEPHONES, LIST_PRENOMS);
        this.sql_type = sql_type;
        this.Specialite = Specialite;
        this.CV = CV;
        this.pListRefRendezVous = pListRefRendezVous;
        this.pListRefConsultations = pListRefConsultations;
    }

    public String getSql_type() {
        return sql_type;
    }

    public String getSpecialite() {
        return Specialite;
    }

    public CLOB getCV() {
        return CV;
    }

    public ARRAY getpListRefRendezVous() {
        return pListRefRendezVous;
    }

    public ARRAY getpListRefConsultations() {
        return pListRefConsultations;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return "";
    }

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
    }

    public void setSpecialite(String specialite) {
        Specialite = specialite;
    }

    public void setCV(CLOB CV) {
        this.CV = CV;
    }

    public void setpListRefRendezVous(ARRAY pListRefRendezVous) {
        this.pListRefRendezVous = pListRefRendezVous;
    }

    public void setpListRefConsultations(ARRAY pListRefConsultations) {
        this.pListRefConsultations = pListRefConsultations;
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.sql_type=typeName;
        this.ID_PERSONNE=stream.readInt();
        this.NUMERO_SECURITE_SOCIALE=stream.readString();
        this.NOM=stream.readString();
        this.EMAIL=stream.readString();
        this.ADRESSE= (Adresse) stream.readObject();
        this.SEXE=stream.readString();
        this.DATE_NAISSANCE=stream.readDate();
        this.LIST_TELEPHONES= (ARRAY) stream.readArray();
        this.LIST_PRENOMS= (ARRAY) stream.readArray();
        this.sql_type = typeName;
        this.Specialite = stream.readString();
        this.CV = (CLOB) stream.readClob();
        this.pListRefRendezVous = (ARRAY) stream.readArray();
        this.pListRefConsultations = (ARRAY) stream.readArray();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(ID_PERSONNE);
        stream.writeString(NUMERO_SECURITE_SOCIALE);
        stream.writeString(NOM);
        stream.writeString(EMAIL);
        stream.writeObject((SQLData) ADRESSE);
        stream.writeString(SEXE);
        stream.writeDate(DATE_NAISSANCE);
        stream.writeArray(LIST_TELEPHONES);
        stream.writeArray(LIST_PRENOMS);
        stream.writeString(Specialite);
        stream.writeClob(CV);
        stream.writeArray(pListRefRendezVous);
        stream.writeArray(pListRefConsultations);
    }

    public void display() throws SQLException, IOException {
        System.out.println("");
        System.out.println("{");
        super.display();
        System.out.println("SPECIALITE = "+this.getSpecialite());
        System.out.println("CV = "+this.getCV());
        this.displayPListRefRendezVous();
        this.displayPListRefConsultations();
        System.out.println("}");
        System.out.println("");
    }

    private void displayPListRefConsultations() throws SQLException {
        Ref[] lesRefConsultations= (Ref[])this.getpListRefConsultations().getArray();
        System.out.println("<Consultations:");
        for (Ref refConsultation : lesRefConsultations) {
            Consultation consultation = (Consultation) refConsultation.getObject();
            System.out.println(consultation.toString());
        }
        System.out.println(">");
    }

    private void displayPListRefRendezVous() throws SQLException {
        Ref[] lesRefRendezVous= (Ref[])this.getpListRefRendezVous().getArray();
        System.out.println("<Rendez Vous:");
        for (Ref refRendezVous : lesRefRendezVous) {
            RendezVous rendezVous = (RendezVous) refRendezVous.getObject();
            System.out.println(rendezVous.toString());
        }
        System.out.println(">");
    }
}
