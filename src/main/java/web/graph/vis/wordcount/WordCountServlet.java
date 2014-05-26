package web.graph.vis.wordcount;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTableInterface;
import org.apache.hadoop.hbase.client.HTablePool;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.util.Bytes;

public class WordCountServlet extends HttpServlet {
	
	private static String tableName = "wordcount";
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
	    	searchByWord(resp,null);
	    	return;
	    }
	    
	    HTableInterface table = pool.getTable(tableName);
	    Get get = new Get(Bytes.toBytes(word));
	    Result rs = table.get(get);
	    WordCount w = new WordCount(word);
	    Pattern p = Pattern.compile("i\\d");
	    for(KeyValue kv: rs.raw()){
	    	String value = new String(kv.getValue(),"utf-8");
	    	String qualifier = new String(kv.getQualifier(),"utf-8");
	    	Matcher m = p.matcher(qualifier);
	    	if(m.find()){
	    		int interval = Integer.parseInt(qualifier.substring(1));
	    		w.setCount(interval, value);
	    	}
	    }
	    searchByWord(resp,w);
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
	
	public void searchByWord(HttpServletResponse resp, WordCount w) throws IOException{
		resp.setContentType("text/html");
	    resp.setStatus(HttpServletResponse.SC_OK);
	    PrintWriter out = null;
	    out = resp.getWriter();

	    out.println("<html>");
	    out.println("<body>");
	    out.println("<p>Enter Word:</p>");
	    out.println("<form method='GET' action=''/>");
	    out.println("<input name='word' type='text' size='20'/><br/><br/>");
	    out.println("<input type='submit' value='Submit' />");
	    out.println("</form>");
	    
	    if(w != null){
	    	out.println("<p>"+w.word+"</p>");
	    	out.println("<ul>");
	    	for(int i=0; i<w.NUM_INTERVALS; i++){
	    		out.println("<li>Interval"+i+":"+w.count[i]+"</li>");
	    	}
	    	out.println("</ul>");
	    }
	    out.println("</body>");
	    out.println("</html>");
	}
}
