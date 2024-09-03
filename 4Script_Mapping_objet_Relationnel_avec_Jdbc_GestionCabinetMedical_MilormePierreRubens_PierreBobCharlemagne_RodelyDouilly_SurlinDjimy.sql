-- CLASSE ADRESSE
package org.cabinetmedical;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;

public class Adresse implements SQLData {
    protected String sql_type;
    private int NUMERO;
    private String RUE;
    private int CODE_POSTAL;
    private String VILLE;

    public Adresse() {}

    public Adresse(String sql_type, int NUMERO, String RUE, int CODE_POSTAL, String VILLE) {
        this.sql_type = sql_type;
        this.NUMERO = NUMERO;
        this.RUE = RUE;
        this.CODE_POSTAL = CODE_POSTAL;
        this.VILLE = VILLE;
    }

    public String getSql_type() {
        return sql_type;
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

    public void setSql_type(String sql_type) {
        this.sql_type = sql_type;
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
        return "";
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
}


-- CLASSE PERSONNE
package org.cabinetmedical;

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

-- CLASSE PATIENT
package org.cabinetmedical;

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

-- CLASSE MEDECIN
package org.cabinetmedical;

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
package org.cabinetmedical;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

import oracle.sql.REF;

public class RendezVous implements SQLData {
    private int Id_Rendez_Vous;
    private REF refPatient;
    private REF refMedecin;
    private Date Date_Rendez_Vous;
    private String Motif;

    public RendezVous(){}

    public RendezVous(int id_Rendez_Vous, REF refPatient, REF refMedecin, Date date_Rendez_Vous, String motif) {
        Id_Rendez_Vous = id_Rendez_Vous;
        this.refPatient = refPatient;
        this.refMedecin = refMedecin;
        Date_Rendez_Vous = date_Rendez_Vous;
        Motif = motif;
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
        return "";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {

    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {

    }
}

-- CLASSE CONSULTATION
package org.cabinetmedical;

import oracle.sql.REF;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;
import oracle.sql.ARRAY;

public class Consultation implements SQLData {
    private int Id_Consultation;
    private REF refPatient;
    private REF refMedecin;
    private String Raison;
    private String Diagnostic;
    private Date Date_Consultation;
    private ARRAY pListRefExamens;
    private ARRAY pListRefPrescriptions;

    public Consultation() {}

    public Consultation(int id_Consultation, REF refPatient, REF refMedecin, String raison, String diagnostic, Date date_Consultation, ARRAY pListRefExamens, ARRAY pListRefPrescriptions) {
        Id_Consultation = id_Consultation;
        this.refPatient = refPatient;
        this.refMedecin = refMedecin;
        Raison = raison;
        Diagnostic = diagnostic;
        Date_Consultation = date_Consultation;
        this.pListRefExamens = pListRefExamens;
        this.pListRefPrescriptions = pListRefPrescriptions;
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

    public ARRAY getpListRefExamens() {
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
        return "";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {

    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {

    }
}


-- CLASSE EXAMEN
package org.cabinetmedical;

import oracle.sql.REF;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

public class Examen implements SQLData {
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
        return "";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {

    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {

    }
}


-- CLASSE FACTURE
package org.cabinetmedical;

import oracle.sql.REF;

import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

public class Facture implements SQLData {
    private int Id_Facture;
    private REF refPatient;
    private REF refConsultation;
    private float Montant_Total;
    private Date Date_Facture;

    public Facture() {}

    public Facture(int id_Facture, REF refPatient, REF refConsultation, float montant_Total, Date date_Facture) {
        Id_Facture = id_Facture;
        this.refPatient = refPatient;
        this.refConsultation = refConsultation;
        Montant_Total = montant_Total;
        Date_Facture = date_Facture;
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
        return "";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {

    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {

    }
}


-- CLASSE PRESCRIPTION
package org.cabinetmedical;

import oracle.sql.REF;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Date;

public class Prescription implements SQLData {
    private int Id_Prescription;
    private REF refConsultation;
    private String Details_Prescription;
    private Date Date_Prescription;

    public Prescription(){}

    public Prescription(int id_Prescription, REF refConsultation, String details_Prescription, Date date_Prescription) {
        Id_Prescription = id_Prescription;
        this.refConsultation = refConsultation;
        Details_Prescription = details_Prescription;
        Date_Prescription = date_Prescription;
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
        return "";
    }

    @Override
    public void readSQL(SQLInput stream, String typeName) throws SQLException {

    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {

    }
}


-- CLASSE MAIN
package org.gestioncabinetmedical;

import java.io.IOException;
import java.sql.*;

public class Main{
    public static void main(String[] args) throws SQLException, ClassNotFoundException{
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@144.21.67.201:1521/PDBBDS1.631174089.oraclecloud.internal", "Oracle", "password");

            java.util.Map mapOraObjType = conn.getTypeMap();

            mapOraObjType.put("Adresse_T", Adresse.class);
            mapOraObjType.put("Examen_T", Examen.class);

            Statement stmt = conn.createStatement();

            String sqlAdressesPatients = "SELECT op.adresse FROM o_patient op";
            ResultSet resultsetAdressesPatients = stmt.executeQuery(sqlAdressesPatients);
            System.out.println("********INFOS ADRESSES PATIENTS ******************");
            while(resultsetAdressesPatients.next()){
                Adresse adresse = (Adresse) resultsetAdressesPatients.getObject(1, mapOraObjType);
                adresse.display();
            }

            String sqlPatients = "SELECT value(op) FROM o_patient op";
            ResultSet resultsetPatients = stmt.executeQuery(sqlPatients);
            System.out.println("********INFOS PATIENTS ******************");
            while(resultsetPatients.next()){
                Patient patient = (Patient) resultsetPatients.getObject(1, mapOraObjType);
                patient.display();
            }

            String sqlMedecins = "SELECT value(om) FROM o_medecin om";
            ResultSet resultsetMedecins = stmt.executeQuery(sqlMedecins);
            System.out.println("********INFOS MEDECINS ******************");
            while(resultsetMedecins.next()){
                Medecin medecin = (Medecin) resultsetMedecins.getObject(1, mapOraObjType);
                medecin.display();
            }
        }catch(ClassNotFoundException | SQLException | IOException e){
            System.out.println("Echec du mapping");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
    }
}