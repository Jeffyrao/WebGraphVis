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
    //private static String dbURL = "jdbc:derby://localhost:1527/";
	private static String dbURL = "jdbc:derby:";
    private static Connection conn = null;
    private static Statement stmt = null;
    //private static String driverName = "org.apache.derby.jdbc.ClientDriver";
    private static String driverName = "org.apache.derby.jdbc.EmbeddedDriver";
    private static int max = 10;
    
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
        	//Class.forName(driverName);
            Class.forName(driverName).newInstance(); //load embedded driver
            System.out.println("Loaded the embedded driver");
            Properties dbProps = new Properties();
            dbProps.put("user", userName);
            dbProps.put("password", password);
            conn = DriverManager.getConnection(dbURL + dbLocation, dbProps);
            //createDB(conn);
            System.out.println("Connection successful!");
        }
        catch (Exception except)
        {
            System.out.print("Could not connect to the database with username: " + userName);
            System.out.println(" password " + password);
            except.printStackTrace();
        }
        return conn;
    }
    
    private static void createDB(Connection conn) throws SQLException{
    	String createNodeTable = "CREATE TABLE APP.NODES( "
    			+ "id varchar(20) NOT NULL primary key,"
    			+ "name varchar(150),"
				+ "pagerank varchar(20) NOT NULL," 
				+ "url varchar(200) NOT NULL,"
				+ "party char(20),"
				+ "committee char(20),"
				+ "state varchar(20),"
				+ "district varchar(20) )";
    	String insertDataToNodeTable = "CALL SYSCS_UTIL.SYSCS_IMPORT_TABLE "
                                   +" ('APP', 'NODES','src/main/webapp/data/nodes.csv',',',null,null, 0)";
    	
    	String createLinkTable = "CREATE TABLE APP.LINKS("
				+ "src varchar(20) NOT NULL,"
				+ "dest varchar(20) NOT NULL,"
				+ "weight varchar(20) NOT NULL,"
				+ "subnodes varchar(20) NOT NULL,"
				+ "src_url varchar(200) NOT NULL,"
				+ "dest_url varchar(200) NOT NULL,"
				+ "primary key(src, dest) )";
    	String insertDataToLinkTable = "CALL SYSCS_UTIL.SYSCS_IMPORT_TABLE " +
    	"( 'APP', 'LINKS','src/main/webapp/data/links.csv',',',null,null,0 )";
    	
    	Statement s = conn.createStatement();
    	try {
            s.executeUpdate("DROP TABLE APP.NODES");
            s.executeUpdate("DROP TABLE APP.LINKS");
        } catch (SQLException e) {
            if (!e.getSQLState().equals("proper SQL-state for table does not exist"))
                throw e;
        }
    	s.execute(createNodeTable);
    	s.execute(insertDataToNodeTable);
    	s.execute(createLinkTable);
    	s.execute(insertDataToLinkTable);
    	System.out.println("create table NODES and LINKS successfully");
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
                        sbuf.append(";");
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
