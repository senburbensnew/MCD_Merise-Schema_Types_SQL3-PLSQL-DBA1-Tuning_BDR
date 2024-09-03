package org.gestioncabinetmedical;

import java.io.IOException;
import java.sql.*;
import oracle.sql.ARRAY;

public class Patient extends Personne implements  SQLData{
    protected String sql_type;
    private float POIDS;
    private float HAUTEUR;
    private ARRAY pListRefRendezVous;
    private ARRAY pListRefConsultations;
    private ARRAY pListRefFactures;

    public Patient(){}

    public Patient(
            int ID_PERSONNE,
            String NUMERO_SECURITE_SOCIALE,
            String NOM,
            String EMAIL,
            Adresse ADRESSE,
            String SEXE,
            Date DATE_NAISSANCE,
            ARRAY LIST_TELEPHONES,
            ARRAY LIST_PRENOMS,
            float POIDS,
            float HAUTEUR,
            ARRAY pListRefRendezVous,
            ARRAY pListRefConsultations,
            ARRAY pListRefFactures,
            String sql_type
    ){
        super(ID_PERSONNE, NUMERO_SECURITE_SOCIALE, NOM, EMAIL, ADRESSE, SEXE, DATE_NAISSANCE, LIST_TELEPHONES, LIST_PRENOMS);
        this.sql_type = sql_type;
        this.POIDS = POIDS;
        this.HAUTEUR=HAUTEUR;
        this.pListRefRendezVous=pListRefRendezVous;
        this.pListRefConsultations=pListRefConsultations;
        this.pListRefFactures=pListRefFactures;
    }

    public String getSql_type() {
        return sql_type;
    }

    public float getPOIDS() {
        return POIDS;
    }

    public float getHAUTEUR() {
        return HAUTEUR;
    }

    public ARRAY getpListRefRendezVous() {
        return pListRefRendezVous;
    }

    public ARRAY getpListRefConsultations() {
        return pListRefConsultations;
    }

    public ARRAY getpListRefFactures() {
        return pListRefFactures;
    }

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
    }

    public void setPOIDS(float POIDS) {
        this.POIDS = POIDS;
    }

    public void setHAUTEUR(float HAUTEUR) {
        this.HAUTEUR = HAUTEUR;
    }

    public void setpListRefRendezVous(ARRAY pListRefRendezVous) {
        this.pListRefRendezVous = pListRefRendezVous;
    }

    public void setpListRefConsultations(ARRAY pListRefConsultations) {
        this.pListRefConsultations = pListRefConsultations;
    }

    public void setpListRefFactures(ARRAY pListRefFactures) {
        this.pListRefFactures = pListRefFactures;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return "";
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
        this.POIDS=stream.readFloat();
        this.HAUTEUR=stream.readFloat();
        this.pListRefRendezVous=(ARRAY) stream.readArray();
        this.pListRefConsultations=(ARRAY) stream.readArray();
        this.pListRefFactures=(ARRAY) stream.readArray();
        System.out.println("");
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
        stream.writeFloat(POIDS);
        stream.writeFloat(HAUTEUR);
        stream.writeArray(pListRefRendezVous);
        stream.writeArray(pListRefConsultations);
        stream.writeArray(pListRefFactures);
    }

    public void display() throws SQLException, IOException {
        System.out.println("");
        System.out.println("{");
        super.display();
        System.out.println("POIDS = "+this.getPOIDS());
        System.out.println("HAUTEUR = "+this.getHAUTEUR());
        this.displayPListRefRendezVous();
        this.displayPListRefConsultations();
        this.displayPListRefFactures();
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

    public void displayPListRefFactures() throws SQLException{
        Ref[] lesRefFactures= (Ref[])this.getpListRefFactures().getArray();
        System.out.println("<Factures:");
        for (Ref refFacture : lesRefFactures) {
            Facture facture = (Facture) refFacture.getObject();
            System.out.println(facture.toString());
        }
        System.out.println(">");
    }
}
