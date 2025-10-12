package com.mycompany.mavenproject1;

import javax.swing.table.DefaultTableModel;
import java.sql.*;

public class CustomerDao {
            
    public DefaultTableModel getAllCustomers(Connection connection) {
        String query = PropertyLoader.get("get.customers");
        DefaultTableModel model = new DefaultTableModel(){
            @Override 
            public boolean isCellEditable(int row, int column){
                return false;
            }
        };
        try(Statement statement = connection.createStatement();
            ResultSet rs = statement.executeQuery(query);) { 
            
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

        } catch (SQLException ex) {
            System.err.println("Error fetching customers:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
        return model;
    }

    public void addCustomer(Connection connection, String username, String phone){
        String query = PropertyLoader.get("add.customer");
        try(PreparedStatement prst = connection.prepareStatement(query);) { 
            prst.setString(1, username);
            prst.setString(2, phone);
            prst.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }

    }
    
    public void updateCustomer(Connection connection, int custID, String username, String phone){
        String query = PropertyLoader.get("update.customer");
        try(PreparedStatement prst = connection.prepareStatement(query);) { 
            prst.setInt(1, custID);
            prst.setString(2, username);
            prst.setString(3, phone);
            prst.executeUpdate();
        } catch (SQLException ex) {
            System.err.println("SQL Error:");
            while (ex != null) {
                System.err.println("Message: " + ex.getMessage());
                ex = ex.getNextException();
            }
        }
    }
    
    public void deleteCustomer(Connection connection, int custID){
        String query = PropertyLoader.get("delete.customer");
        try(PreparedStatement prst = connection.prepareStatement(query);){
            prst.setInt(1, custID);
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
