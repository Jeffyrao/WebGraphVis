package web.graph.vis.wordcount;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTablePool;
import org.warcbase.data.TextDocument2;

public class WordCountServlet extends HttpServlet {
	
	private String tableName;
	private final Configuration hbaseConfig;
	private HBaseAdmin hbaseAdmin;
	private static HTablePool pool = new HTablePool();
	
	public WordCountServlet() throws MasterNotRunningException, ZooKeeperConnectionException{
		this.hbaseConfig = HBaseConfiguration.create();
	    hbaseAdmin = new HBaseAdmin(hbaseConfig);
	}
	
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
		    throws ServletException, IOException
	{
		String word = req.getParameter("word");
		if (req.getPathInfo() == null || req.getPathInfo() == "/") {
	      writeTables(resp);
	      return;
	 	}
	    String pathInfo = req.getPathInfo();
	    String[] splits = pathInfo.split("\\/");

	    if (splits.length < 2) {
	      writeTables(resp);
	      return;
	    }
	    this.tableName = splits[1];
	    if (splits.length == 2 && word == null) {
	    	getServletContext().getRequestDispatcher("/wordcount.jsp").forward(req, resp);
	    	return;
	    }
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
		doGet(request, response);
    }
	
	public void writeTables(HttpServletResponse resp) throws IOException {
	    HTableDescriptor[] htableDescriptors = null;
	    htableDescriptors = hbaseAdmin.listTables();

	    resp.setContentType("text/html");
	    resp.setStatus(HttpServletResponse.SC_OK);
	    PrintWriter out = null;
	    out = resp.getWriter();

	    out.println("<html>");
	    out.println("<body>");
	    for (HTableDescriptor htableDescriptor : htableDescriptors) {
	      String tableNameTmp = htableDescriptor.getNameAsString();
	      out.println("<br/> <a href='" + WordCountBrowser.serverAddr + tableNameTmp + "'>"
	          + tableNameTmp + "</a>");
	    }
	    out.println("</body>");
	    out.println("</html>");
	  }
}
