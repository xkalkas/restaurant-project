package com.mycompany.mavenproject1;


import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class PropertyLoader {
    private static final Properties properties = new Properties();

    static {
        try (InputStream input = PropertyLoader.class.getClassLoader()
                .getResourceAsStream("dbconfig.properties")) {
            if (input == null) {
                throw new RuntimeException("Cannot find dbconfig.properties in resources");
            }
            properties.load(input);
        } catch (IOException e) {
            throw new RuntimeException("Error loading dbconfig.properties", e);
        }
        
       try (InputStream input = PropertyLoader.class.getClassLoader()
                .getResourceAsStream("dbprocedures.properties")) {
            if (input == null) {
                throw new RuntimeException("Cannot find dbprocedures.properties in resources");
            }
            properties.load(input);
        } catch (IOException e) {
            throw new RuntimeException("Error loading dbprocedures.properties", e);
        }
    }

    public static String get(String key) {
        return properties.getProperty(key);
    }
}
