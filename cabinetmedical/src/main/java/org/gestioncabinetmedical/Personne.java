package org.gestioncabinetmedical;

import oracle.sql.ARRAY;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

public abstract class Personne {
    protected int ID_PERSONNE;
    protected String NUMERO_SECURITE_SOCIALE;
    protected String NOM;
    protected String EMAIL;
    protected Adresse ADRESSE;
    protected String SEXE;
    protected Date DATE_NAISSANCE;
    protected ARRAY LIST_TELEPHONES;
    protected ARRAY LIST_PRENOMS;

    public Personne(){}

    public Personne(
            int ID_PERSONNE,
            String NUMERO_SECURITE_SOCIALE,
            String NOM,
            String EMAIL,
            Adresse ADRESSE,
            String SEXE,
            Date DATE_NAISSANCE,
            ARRAY LIST_TELEPHONES,
            ARRAY LIST_PRENOMS
    ) {
        this.ID_PERSONNE = ID_PERSONNE;
        this.NUMERO_SECURITE_SOCIALE = NUMERO_SECURITE_SOCIALE;
        this.ADRESSE = ADRESSE;
        this.SEXE = SEXE;
        this.DATE_NAISSANCE = DATE_NAISSANCE;
        this.LIST_TELEPHONES = LIST_TELEPHONES;
        this.LIST_PRENOMS = LIST_PRENOMS;
        this.EMAIL = EMAIL;
        this.NOM = NOM;
    }

    public int getID_PERSONNE() {
        return ID_PERSONNE;
    }

    public String getNUMERO_SECURITE_SOCIALE() {
        return NUMERO_SECURITE_SOCIALE;
    }

    public String getNOM() {
        return NOM;
    }

    public String getEMAIL() {
        return EMAIL;
    }

    public Adresse getADRESSE() {
        return ADRESSE;
    }

    public String getSEXE() {
        return SEXE;
    }

    public Date getDATE_NAISSANCE() {
        return DATE_NAISSANCE;
    }

    public ARRAY getLIST_TELEPHONES() {
        return LIST_TELEPHONES;
    }

    public ARRAY getLIST_PRENOMS() {
        return LIST_PRENOMS;
    }

    public void display() throws SQLException, IOException {
        System.out.println("ID = "+this.getID_PERSONNE());
        System.out.println("NUMERO_SECURITE_SOCIALE = "+this.getNUMERO_SECURITE_SOCIALE());
        System.out.println("NOM = "+this.getNOM());
        this.displayListPrenoms();
        System.out.println("SEXE = "+this.getSEXE());
        System.out.println("DATE_NAISSANCE = "+this.getDATE_NAISSANCE());
        this.displayAdresse();
        this.displayListTelephones();
    }

    private void displayAdresse() throws SQLException{
        System.out.println(this.getADRESSE().toString());
    }

    public void displayListTelephones() throws SQLException{
        String[] telephones= (String[])this.getLIST_TELEPHONES().getArray();
        for (int i=0; i<telephones.length;i++){
            System.out.println("Telephones["+i+"]="+telephones[i]);
        }
    }

    public void displayListPrenoms() throws SQLException{
        String [] prenoms= ( String [])this.getLIST_PRENOMS().getArray();
        for (int i=0; i<prenoms.length;i++){
            System.out.println("Prenoms["+i+"]="+prenoms[i]);
        }
    }
}
