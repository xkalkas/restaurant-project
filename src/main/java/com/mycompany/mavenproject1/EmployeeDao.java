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
public class EmployeeDao {
    
    public DefaultTableModel getAllEmployees(Connection connection){
        String query = PropertyLoader.get("get.employees");
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

    void addEmployee(Connection connection, String username, String role) {
        String query = PropertyLoader.get("add.employee");
        try(PreparedStatement prst = connection.prepareStatement(query);) { 
            prst.setString(1, username);
            prst.setString(2, role);
            prst.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
    }

    void updateEmployee(Connection connection, int empID, String username, String role) {
        String query = PropertyLoader.get("update.employee");
        try(PreparedStatement prst = connection.prepareStatement(query);) { 
            prst.setInt(1, empID);
            prst.setString(2, username);
            prst.setString(3, role);
            prst.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
    }

    void deleteEmployee(Connection connection, int empID) {
        String query = PropertyLoader.get("delete.employee");
        try(PreparedStatement prst = connection.prepareStatement(query);){
            prst.setInt(1, empID);
            prst.executeUpdate();
        } catch (SQLException ex){
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
    }
    
    
}
