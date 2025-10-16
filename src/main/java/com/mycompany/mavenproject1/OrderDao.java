/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.mavenproject1;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author Xkalk
 */
public class OrderDao {
    
    public DefaultTableModel getAllOrders(Connection connection){
        String query = PropertyLoader.get("get.orders");
        DefaultTableModel model = new DefaultTableModel(){
            @Override 
            public boolean isCellEditable(int row, int column){
                return false;
            }
        };
        
        try (Statement statement = connection.createStatement();
            ResultSet rs = statement.executeQuery(query);){ 
            
            ResultSetMetaData rsmd = rs.getMetaData();
            int cols = rsmd.getColumnCount();

            // Column headers
            String[] colNames = new String[cols];
            for (int i = 0; i < cols; i++)
                colNames[i] = rsmd.getColumnName(i + 1);
            model.setColumnIdentifiers(colNames);

            // Data rows
            while (rs.next()) {
                Object[] row = new Object[cols];
                for (int i = 1; i <= cols; i++)
                    row[i - 1] = rs.getObject(i);
                model.addRow(row);
            }

            }catch(SQLException ex){
                System.out.println("\n -- SQL Exception --- \n");
                while(ex != null) {
                    System.out.println("Message: " + ex.getMessage());
                    ex = ex.getNextException();
                }
            }
        return model;
    }
    
    public DefaultTableModel getOrderItems(Connection connection, int orderID){
        String query = PropertyLoader.get("get.orderItems");
        DefaultTableModel model = new DefaultTableModel();
        
        try(PreparedStatement prst = connection.prepareStatement(query);){
            
            prst.setInt(1, orderID);
            try(ResultSet rs = prst.executeQuery();){
                ResultSetMetaData rsmd = rs.getMetaData();
                int cols =  rsmd.getColumnCount();

                // Col Headers
                String[] colNames = new String[cols];
                for (int i = 0; i < cols; i++)
                    colNames[i] = rsmd.getColumnName(i + 1);
                model.setColumnIdentifiers(colNames);

                // Data rows
                while (rs.next()) {
                    Object[] row = new Object[cols];
                    for (int i = 1; i <= cols; i++)
                        row[i - 1] = rs.getObject(i);
                    model.addRow(row);
                }
            }
            
            
        }catch(SQLException ex){
            System.out.println("\n -- SQL Exception --- \n");
                while(ex != null) {
                    System.out.println("Message: " + ex.getMessage());
                    ex = ex.getNextException();
                }
        }
        return model;   
    }

    void deleteOrder(Connection connection, int orderID) {
        
    }

    void updateOrder(Connection connection, int orderID, String status) {
        
    }
}
