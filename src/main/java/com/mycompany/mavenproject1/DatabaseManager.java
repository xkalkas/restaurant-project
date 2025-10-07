package com.mycompany.mavenproject1;

import java.sql.*;

public class DatabaseManager {
    private static Connection connection;

    public static void connect() throws SQLException {
        if (connection == null || connection.isClosed()) {
            String url = PropertyLoader.get("db.url");
            String user = PropertyLoader.get("db.user");
            String password = PropertyLoader.get("db.password");

            connection = DriverManager.getConnection(url, user, password);
            System.out.println("Connected to DB: " + url);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connect();
        }
        return connection;
    }
    
    public static void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("Database connection closed.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
