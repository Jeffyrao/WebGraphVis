package web.graph.vis;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ClickServlet extends HttpServlet implements Servlet {
	
	public static Connection conn = DerbyDatabase.getConnInstance();
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
		String id = request.getParameter("id");
		String sql = "";
		if(id == null) id = "-1";
		
		JSONObject returnObject = new JSONObject();
		sql = "select * from APP.NODES where id='"+id+"'";
		String[] node = DerbyDatabase.runQuery(conn, sql);
		returnObject.put("nodes", parseResults(node));
		
		//Get all outgoing links
		sql = "select APP.NODES.* from APP.LINKS JOIN APP.NODES on APP.LINKS.src = '"+id
				+"' and APP.NODES.id = APP.LINKS.dest ORDER BY APP.NODES.pagerank DESC";
		String[] outlinks = DerbyDatabase.runQuery(conn, sql);
		returnObject.put("outlinks",parseResults(outlinks));
		//Get all incoming links
		sql =  "select APP.NODES.* from APP.LINKS JOIN APP.NODES on APP.LINKS.dest = '"+id
				+"' and APP.NODES.id = APP.LINKS.src ORDER BY APP.NODES.pagerank DESC";
		String[] inlinks = DerbyDatabase.runQuery(conn, sql);
		returnObject.put("inlinks",parseResults(inlinks));
		
		response.setContentType("application/json");
		response.getWriter().write(returnObject.toString());
		
		//getServletContext().getRequestDispatcher("/index.jsp").forward(request, response);
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
    {
        doPost(request,response);
    }
	
	protected JSONArray parseResults(String[] input){
		JSONArray nodes = new JSONArray();
		JSONObject node;
		for(int i=0; i< input.length; i++){
			node = new JSONObject();
			String[] attr = input[i].split(";");
			node.put("id", attr[0].trim());
			node.put("name", attr[1].trim());
			node.put("pagerank", attr[2].trim());
			node.put("url", attr[3].trim());
			node.put("party", attr[4].trim());
			node.put("committee", attr[5].trim());
			node.put("state", attr[6].trim());
			node.put("district", attr[7].trim());
			nodes.add(node);
		}
		return nodes;
	}

}
