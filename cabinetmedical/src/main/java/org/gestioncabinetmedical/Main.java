package org.gestioncabinetmedical;

import oracle.sql.REF;
import oracle.sql.STRUCT;

import java.io.IOException;
import java.util.Date;
import java.sql.*;

public class Main{
    public static void main(String[] args) throws SQLException, ClassNotFoundException{
        Connection conn = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521/xe", "Oracle", "password");

            java.util.Map mapOraObjType = conn.getTypeMap();

            mapOraObjType.put("Adresse_T", Adresse.class);
            mapOraObjType.put("Patient_t", Patient.class);
            mapOraObjType.put("Medecin_T", Medecin.class);
            mapOraObjType.put("Examen_T", Examen.class);

            Statement stmt = conn.createStatement();

            String sqlAdressesPatients = "SELECT op.adresse FROM o_patient op";
            ResultSet resultsetAdressesPatients = stmt.executeQuery(sqlAdressesPatients);
            System.out.println("********INFOS ADRESSES PATIENTS ******************");
            while(resultsetAdressesPatients.next()){
                STRUCT struct = (STRUCT) resultsetAdressesPatients.getObject("ADRESSE");
                Object[] attributes = struct.getAttributes();
                Adresse adresse = new Adresse(
                        "Adresse",
                        ((Number) attributes[0]).intValue(),
                        (String) attributes[1],
                        ((Number) attributes[2]).intValue(),
                        (String) attributes[3]
                );

                System.out.println(adresse.getNUMERO() + ", " + adresse.getRUE() +  ", " + adresse.getVILLE() + ", " + adresse.getCODE_POSTAL());
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
                // Medecin medecin = (Medecin) resultsetMedecins.getObject(1, mapOraObjType);
                // medecin.display();
            }

            String sqlExamens = "SELECT value(oe) AS EXAMEN FROM o_examen oe";
            ResultSet resultsetExamens = stmt.executeQuery(sqlExamens);
            System.out.println("******** INFOS EXAMENS ******************");
            while(resultsetExamens.next()){
                STRUCT struct = (STRUCT) resultsetExamens.getObject(1);
                Examen exam = castToExamen(struct);
                exam.display();
            }
        }catch(ClassNotFoundException | SQLException | IOException e){
            System.out.println("Echec du mapping");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }finally {
            conn.close();
        }
    }

    private static Examen castToExamen(STRUCT struct) throws SQLException {
        Object[] attributes = struct.getAttributes();
        Examen examen  = new Examen(
                "Examen",
                ((Number) attributes[0]).intValue(),
                (REF) attributes[1],
                ((String) attributes[2]),
                (Date) attributes[3]
        );
        return examen;
    }
}