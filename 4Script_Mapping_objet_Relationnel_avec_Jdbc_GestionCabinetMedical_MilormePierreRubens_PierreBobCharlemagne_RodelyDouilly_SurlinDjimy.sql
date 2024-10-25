-- CLASSE ADRESSE
package org.gestioncabinetmedical.entity;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;

public class Adresse implements SQLData {
    private String sql_type = "ADRESSE_T";
    private int NUMERO;
    private String RUE;
    private int CODE_POSTAL;
    private String VILLE;

    public Adresse() {}

    public Adresse(int NUMERO, String RUE, int CODE_POSTAL, String VILLE) {
        this.NUMERO = NUMERO;
        this.RUE = RUE;
        this.CODE_POSTAL = CODE_POSTAL;
        this.VILLE = VILLE;
    }

    public int getNUMERO() {
        return NUMERO;
    }

    public void setNUMERO(int NUMERO) {
        this.NUMERO = NUMERO;
    }

    public String getRUE() {
        return RUE;
    }

    public void setRUE(String RUE) {
        this.RUE = RUE;
    }

    public int getCODE_POSTAL() {
        return CODE_POSTAL;
    }

    public void setCODE_POSTAL(int CODE_POSTAL) {
        this.CODE_POSTAL = CODE_POSTAL;
    }

    public String getVILLE() {
        return VILLE;
    }

    public void setVILLE(String VILLE) {
        this.VILLE = VILLE;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return this.sql_type;
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {
        this.sql_type=typeName;
        this.NUMERO=stream.readInt();
        this.CODE_POSTAL = stream.readInt();
        this.RUE = stream.readString();
        this.VILLE = stream.readString();
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        stream.writeInt(this.NUMERO);
        stream.writeInt(this.CODE_POSTAL);
        stream.writeString(this.RUE);
        stream.writeString(this.VILLE);
    }

    public void display() throws SQLException {
        System.out.println(this.NUMERO + ", " + this.RUE + ", " + this.VILLE + ", " + this.CODE_POSTAL);
    }
}

-- CLASSE PERSONNE
package org.gestioncabinetmedical.entity;

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

    public void setNOM(String NOM) {
        this.NOM = NOM;
    }

    public void setEMAIL(String EMAIL) {
        this.EMAIL = EMAIL;
    }

    public void setADRESSE(Adresse ADRESSE) {
        this.ADRESSE = ADRESSE;
    }

    public void setSEXE(String SEXE) {
        this.SEXE = SEXE;
    }

    public void setDATE_NAISSANCE(Date DATE_NAISSANCE) {
        this.DATE_NAISSANCE = DATE_NAISSANCE;
    }

    public void setLIST_TELEPHONES(ARRAY LIST_TELEPHONES) {
        this.LIST_TELEPHONES = LIST_TELEPHONES;
    }

    public void setLIST_PRENOMS(ARRAY LIST_PRENOMS) {
        this.LIST_PRENOMS = LIST_PRENOMS;
    }

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

    public void setID_PERSONNE(int ID_PERSONNE) {
        this.ID_PERSONNE = ID_PERSONNE;
    }

    public String getNUMERO_SECURITE_SOCIALE() {
        return NUMERO_SECURITE_SOCIALE;
    }

    public void setNUMERO_SECURITE_SOCIALE(String numeroSecuriteSociale){
        this.NUMERO_SECURITE_SOCIALE = numeroSecuriteSociale;
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
        if(this.getADRESSE() == null) return;
        this.getADRESSE().display();
    }

    public void displayListTelephones() throws SQLException{
        if(this.getLIST_TELEPHONES() == null) return;
        String[] telephones= (String[])this.getLIST_TELEPHONES().getArray();
        for (int i=0; i<telephones.length;i++){
            System.out.println("Telephones["+i+"]="+telephones[i]);
        }
    }

    public void displayListPrenoms() throws SQLException{
        if(this.getLIST_PRENOMS() == null) return;
        String [] prenoms= ( String [])this.getLIST_PRENOMS().getArray();
        for (int i=0; i<prenoms.length;i++){
            System.out.println("Prenoms["+i+"]="+prenoms[i]);
        }
    }
}


-- CLASSE PATIENT
package org.gestioncabinetmedical.entity;

import java.io.IOException;
import java.sql.*;
import oracle.sql.ARRAY;

public class Patient extends Personne implements  SQLData{
    protected String sql_type = "PATIENT_T";
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
            ARRAY pListRefFactures
    ){
        super(ID_PERSONNE, NUMERO_SECURITE_SOCIALE, NOM, EMAIL, ADRESSE, SEXE, DATE_NAISSANCE, LIST_TELEPHONES, LIST_PRENOMS);
        this.POIDS = POIDS;
        this.HAUTEUR=HAUTEUR;
        this.pListRefRendezVous=pListRefRendezVous;
        this.pListRefConsultations=pListRefConsultations;
        this.pListRefFactures=pListRefFactures;
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
        return this.sql_type;
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
        if(this.getpListRefConsultations() == null) return;
        Ref[] lesRefConsultations= (Ref[])this.getpListRefConsultations().getArray();
        System.out.println("<Consultations:");
        for (Ref refConsultation : lesRefConsultations) {
            Consultation consultation = (Consultation) refConsultation.getObject();
            System.out.println(consultation.toString());
        }
        System.out.println(">");
    }

    private void displayPListRefRendezVous() throws SQLException {
        if(this.getpListRefRendezVous() == null) return;
        Ref[] lesRefRendezVous= (Ref[])this.getpListRefRendezVous().getArray();
        System.out.println("<Rendez Vous:");
        for (Ref refRendezVous : lesRefRendezVous) {
            RendezVous rendezVous = (RendezVous) refRendezVous.getObject();
            System.out.println(rendezVous.toString());
        }
        System.out.println(">");
    }

    public void displayPListRefFactures() throws SQLException{
        if(this.getpListRefFactures() == null) return;
        Ref[] lesRefFactures= (Ref[])this.getpListRefFactures().getArray();
        System.out.println("<Factures:");
        for (Ref refFacture : lesRefFactures) {
            Facture facture = (Facture) refFacture.getObject();
            System.out.println(facture.toString());
        }
        System.out.println(">");
    }
}


-- CLASSE MEDECIN
package org.gestioncabinetmedical.entity;

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


-- CLASSE RENDEZVOUS
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


-- CLASSE CONSULTATION
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


-- CLASSE EXAMEN
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


-- CLASSE FACTURE
package org.gestioncabinetmedical.entity;

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


-- CLASSE PRESCRIPTION
package org.gestioncabinetmedical.entity;

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

-- CLASSE ConsultationService

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

-- CLASSE ExamenService

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

-- Classe MedecinService

package org.gestioncabinetmedical.service;

import org.gestioncabinetmedical.entity.Medecin;
import java.sql.Connection;

public class MedecinService {

    public MedecinService(Connection conn) {}

    public void insertMedecin(Medecin medecin) {
    }

    public Medecin getMedecinById(int id) {
        return null;
    }

    public void updateMedecin(Medecin medecin) {
    }

    public void deleteMedecin(int id) {
    }
}

-- Classe PatientService

package org.gestioncabinetmedical.service;

import oracle.sql.REF;
import oracle.sql.STRUCT;
import oracle.sql.StructDescriptor;
import org.gestioncabinetmedical.entity.Adresse;
import org.gestioncabinetmedical.entity.Patient;
import java.math.BigDecimal;
import java.sql.*;

public class PatientService {
    private final Connection conn;

    public PatientService(Connection conn) {
        this.conn = conn;
    }

    public void insertPatient(Patient patient) throws SQLException {
        String sql = "INSERT INTO O_PATIENT (ID_PERSONNE#, NUMERO_SECURITE_SOCIALE, nom, EMAIL, sexe, date_naissance, poids, hauteur, adresse) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, patient.getID_PERSONNE());
        ps.setString(2, patient.getNUMERO_SECURITE_SOCIALE());
        ps.setString(3, patient.getNOM());
        ps.setString(4, patient.getEMAIL());
        ps.setString(5, patient.getSEXE());
        ps.setDate(6, patient.getDATE_NAISSANCE());
        ps.setFloat(7, patient.getPOIDS());
        ps.setFloat(8, patient.getHAUTEUR());

        // Map the Adresse object to STRUCT for Oracle
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor("ADRESSE_T", conn);
        Object[] adresseData = {
                patient.getADRESSE().getNUMERO(),
                patient.getADRESSE().getRUE(),
                patient.getADRESSE().getCODE_POSTAL(),
                patient.getADRESSE().getVILLE()
        };
        STRUCT struct = new STRUCT(structDescriptor, conn, adresseData);
        ps.setObject(9, struct);

        ps.executeUpdate();
        ps.close();

        System.out.println("Patient inserted successfully!");
    }

    public Patient getPatientById(int patientId) throws SQLException {
        String query = "SELECT * FROM O_PATIENT WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(query);
        psPatient.setInt(1, patientId);

        ResultSet rs = psPatient.executeQuery();
        Patient patient = null;

        if (rs.next()) {
            patient = new Patient();
            patient.setID_PERSONNE(rs.getInt("ID_PERSONNE#"));
            patient.setNOM(rs.getString("NOM"));
            patient.setNUMERO_SECURITE_SOCIALE(rs.getString("NUMERO_SECURITE_SOCIALE"));
            patient.setHAUTEUR(rs.getFloat("HAUTEUR"));
            patient.setPOIDS(rs.getFloat("POIDS"));
            patient.setSEXE(rs.getString("SEXE"));
            patient.setEMAIL(rs.getString("EMAIL"));
            patient.setDATE_NAISSANCE(rs.getDate("date_naissance"));

            STRUCT addressStruct = (STRUCT) rs.getObject("adresse");
            patient.setADRESSE(parseAddress(addressStruct));

            // Array phoneArray = rs.getArray("List_Telephones");
            // patient.setLIST_TELEPHONES((ARRAY) phoneArray.getArray());

            // Array prenomArray = rs.getArray("List_Prenoms");
            // patient.setLIST_PRENOMS((ARRAY) prenomArray.getArray());
        }

        rs.close();
        psPatient.close();

        return patient;
    }

    public REF getRefPatient(int patientId) throws SQLException {
        String query = "SELECT REF(op) FROM O_PATIENT op WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(query);
        psPatient.setInt(1, patientId);

        ResultSet rs = psPatient.executeQuery();
        REF refPatient = null;

        if (rs.next()) {
            refPatient = (REF) rs.getRef(1);
        }

        rs.close();
        psPatient.close();

        return refPatient;
    }

    public void updatePatient(Patient patient) throws SQLException {
        String sql = "UPDATE O_PATIENT SET ID_PERSONNE# = ?, NUMERO_SECURITE_SOCIALE = ?, nom = ?, EMAIL = ?, sexe = ?, date_naissance = ?, poids = ?, hauteur = ?, adresse = ? WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(sql);
        psPatient.setInt(1, patient.getID_PERSONNE());
        psPatient.setString(2, patient.getNUMERO_SECURITE_SOCIALE());
        psPatient.setString(3, patient.getNOM());
        psPatient.setString(4, patient.getEMAIL());
        psPatient.setString(5, patient.getSEXE());
        psPatient.setDate(6, patient.getDATE_NAISSANCE());
        psPatient.setFloat(7, patient.getPOIDS());
        psPatient.setFloat(8, patient.getHAUTEUR());

        // Map the Adresse object to STRUCT for Oracle
        StructDescriptor structDescriptor = StructDescriptor.createDescriptor("ADRESSE_T", conn);
        Object[] adresseData = {
                patient.getADRESSE().getNUMERO(),
                patient.getADRESSE().getRUE(),
                patient.getADRESSE().getCODE_POSTAL(),
                patient.getADRESSE().getVILLE()
        };
        STRUCT struct = new STRUCT(structDescriptor, conn, adresseData);
        psPatient.setObject(9, struct);
        psPatient.setInt(10, patient.getID_PERSONNE());

        psPatient.executeUpdate();
        psPatient.close();

        System.out.println("Patient updated successfully!");
    }

    public void deletePatient(int patientId) throws SQLException {
        String query = "DELETE FROM O_PATIENT WHERE ID_PERSONNE# = ?";
        PreparedStatement psPatient = conn.prepareStatement(query);
        psPatient.setInt(1, patientId);

        psPatient.executeUpdate();
        psPatient.close();

        System.out.println("Patient deleted successfully!");
    }

    private Adresse parseAddress(STRUCT addressStruct) throws SQLException {
        Object[] attrs = addressStruct.getAttributes();
        Adresse adresse = new Adresse();
        adresse.setNUMERO(((BigDecimal) attrs[0]).intValue());
        adresse.setRUE((String) attrs[1]);
        adresse.setCODE_POSTAL(((BigDecimal) attrs[2]).intValue());
        adresse.setVILLE((String) attrs[3]);
        return adresse;
    }
}




-- CLASSE MAIN
package org.gestioncabinetmedical;

import oracle.sql.REF;
import org.gestioncabinetmedical.entity.Adresse;
import java.io.IOException;
import java.sql.*;
import oracle.jdbc.pool.OracleDataSource;
import org.gestioncabinetmedical.entity.Medecin;
import org.gestioncabinetmedical.entity.Patient;
import org.gestioncabinetmedical.service.ConsultationService;
import org.gestioncabinetmedical.service.ExamenService;
import org.gestioncabinetmedical.service.MedecinService;
import org.gestioncabinetmedical.service.PatientService;

public class Main{
    public static void main(String[] args) throws SQLException {
        Connection conn = null;
        String jdbcUrl = "jdbc:oracle:thin:@localhost:1521:xe";
        String user = "Oracle";
        String password = "password";

        try {
            OracleDataSource ods = new OracleDataSource();
            ods.setURL(jdbcUrl);
            ods.setUser(user);
            ods.setPassword(password);

            conn = ods.getConnection();
            conn.setAutoCommit(true);

            ExamenService examenService = new ExamenService(conn);
            ConsultationService consultationService = new ConsultationService(conn);
            PatientService patientService = new PatientService(conn);
            MedecinService medecinService = new MedecinService(conn);

            /** Patient test */
            // Insert Patient
            Adresse adresse = new Adresse();
            adresse.setNUMERO(123);
            adresse.setRUE("Rue de Paris");
            adresse.setCODE_POSTAL(75000);
            adresse.setVILLE("Paris");

            Patient patient = new Patient();
            patient.setID_PERSONNE(2001);
            patient.setNUMERO_SECURITE_SOCIALE("66373578");
            patient.setSEXE("Masculin");
            patient.setEMAIL("eami5@gmail.com");
            patient.setDATE_NAISSANCE(Date.valueOf("2024-10-06"));
            patient.setPOIDS(56.4F);
            patient.setHAUTEUR(190.8F);
            patient.setNOM("John Doe");
            patient.setADRESSE(adresse);

            patientService.insertPatient(patient);

            // Get Patient by Id
            Patient retrievedPatient  = patientService.getPatientById(2001);
            retrievedPatient.display();

            // Get REF to patient by id
            REF refPatient = patientService.getRefPatient(2001);
            System.out.println(refPatient);

            // Update patient
            retrievedPatient.setPOIDS(140.6F);
            patientService.updatePatient(retrievedPatient);

            // Delete Patient
            patientService.deletePatient(2001);

            /** Medecin test */
            // Insert Medecin
            Adresse adresseMedecin = new Adresse();
            adresseMedecin.setNUMERO(7);
            adresseMedecin.setRUE("Rue de Marseille");
            adresseMedecin.setCODE_POSTAL(10000);
            adresseMedecin.setVILLE("Marseille");

            Medecin medecin = new Medecin();
            medecin.setID_PERSONNE(2001);
            medecin.setNUMERO_SECURITE_SOCIALE("234509");
            medecin.setSEXE("Feminin");
            medecin.setEMAIL("medein@gmail.com");
            medecin.setDATE_NAISSANCE(Date.valueOf("2025-09-01"));
            medecin.setNOM("John Doe medecin");
            medecin.setADRESSE(adresse);

            medecinService.insertMedecin(medecin);


            /*
                // Get REF of Consultation
                REF refConsultation = consultationService.getRefConsultation(1);

                // Insert Examen
                Examen examen = new Examen(3000, refConsultation, "Blood Test", Date.valueOf("2024-10-06"));
                examenService.insertExamen(examen);

                // Get Examen by Id and display
                Examen insertedExamen = examenService.getExamenById(3000);
                insertedExamen.display();
            */
        }catch(SQLException | IOException e){
            System.out.println("Echec du mapping");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }finally {
            conn.close();
        }
    }
}