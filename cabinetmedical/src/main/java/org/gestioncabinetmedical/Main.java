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