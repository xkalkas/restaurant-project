package com.mycompany.mavenproject1;

import javax.swing.table.DefaultTableModel;
import java.sql.*;

public class CustomerDao {
            
    public DefaultTableModel getAllCustomers(Connection connection) {
        String query = PropertyLoader.get("get.customers");
        DefaultTableModel model = new DefaultTableModel();
        try { 
            
            Statement statement = connection.createStatement();
            ResultSet rs = statement.executeQuery(query);
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
}
