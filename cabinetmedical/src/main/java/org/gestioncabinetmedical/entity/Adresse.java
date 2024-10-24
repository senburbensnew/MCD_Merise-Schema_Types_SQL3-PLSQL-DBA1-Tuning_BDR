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
