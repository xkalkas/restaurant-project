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
public class MenuDao {
    
    public DefaultTableModel getAllMenuItems(Connection connection){
        String query = PropertyLoader.get("get.menuItems");
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

    void addMenuItem(Connection connection, String itemName, String category, int price) {
        String query = PropertyLoader.get("add.menuItem");
        try(PreparedStatement prst = connection.prepareStatement(query);) { 
            prst.setString(1, itemName);
            prst.setString(2, category);
            prst.setInt(3, price);
            prst.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
    }

    void updateMenuItem(Connection connection, int menuID, String itemName, String category, int price) {
        String query = PropertyLoader.get("update.menuItem");
        try(PreparedStatement prst = connection.prepareStatement(query);) { 
            prst.setInt(1, menuID);
            prst.setString(2, itemName);
            prst.setString(3, category);
            prst.setInt(4, price);
            prst.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
    }

    void deleteMenuItem(Connection connection, int menuID) {
        String query = PropertyLoader.get("delete.menuItem");
        try(PreparedStatement prst = connection.prepareStatement(query);){
            prst.setInt(1, menuID);
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
