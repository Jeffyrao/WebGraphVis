package web.graph.vis;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Properties;

public class DerbyDatabase {
	private static String dbLocation = "warcbase";
    private static String dbURL = "jdbc:derby://localhost:1527/";
    private static Connection conn = null;
    private static Statement stmt = null;
    private static String driverName = "org.apache.derby.jdbc.ClientDriver";
    
    public static Connection getConnInstance()
    {
    	if (conn == null)
    	{
    		conn = createConnection("rjf","rjf");
    	}
    	return conn;
    }
    
    private static Connection createConnection(String userName, String password)
    {
        try
        {
            Class.forName(driverName);
            Properties dbProps = new Properties();
            dbProps.put("user", userName);
            dbProps.put("password", password);
            conn = DriverManager.getConnection(dbURL + dbLocation, dbProps);
            System.out.println("Connection successful!");
        }
        catch (Exception except)
        {
            System.out.print("Could not connect to the database with username: " + userName);
            System.out.println(" password " + password);
            System.out.println("Check that the Derby Network Server is running on localhost.");
            except.printStackTrace();
        }
        return conn;
    }
    public static int executeUpdate(Connection conn, String sql)
    {
        // the number of rows affected by the update or insert
        int numRows = 0;
       
        try
        {
            stmt = conn.createStatement();
            numRows = stmt.executeUpdate(sql);
            stmt.close();
        }
        catch (SQLException sqlExcept)
        {
            sqlExcept.printStackTrace();
        }
        return numRows;
    }
    
    public static String[] runQuery(Connection conn, String sql)
    {
        List list = Collections.synchronizedList(new ArrayList(10));
        try
        {
            stmt = conn.createStatement();
            ResultSet results = stmt.executeQuery(sql);
            ResultSetMetaData rsmd = results.getMetaData();
            int numberCols = rsmd.getColumnCount();
       
            while(results.next())
            {
                    StringBuffer sbuf = new StringBuffer(200);
                    for (int i = 1; i <= numberCols; i++)
                    {
                        sbuf.append(results.getString(i));
                        sbuf.append(", ");
                    }
                list.add(sbuf.toString());
            }
            results.close();
            stmt.close();
        }
        catch (SQLException sqlExcept)
        {
            sqlExcept.printStackTrace();
        }
        return (String[])list.toArray(new String[list.size()]);
    }
}
