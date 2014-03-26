package web.graph.vis;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GetLinksServlet extends HttpServlet implements Servlet {
	
	public static Connection conn = DerbyDatabase.getConnInstance();
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
		String id = request.getParameter("id");
		if(id == null) id = "1";
		request.getSession().setAttribute("id",id);
		
		String sql = "";
		
		//Get all outgoing links
		sql = "select dest from APP.LINKS where src = '"+id+"'";
		String[] outlinks = DerbyDatabase.runQuery(conn, sql);
		request.getSession().setAttribute("outlinks",deleteComma(outlinks));
		
		//Get all incoming links
		sql = "select src from APP.LINKS where dest = '"+id+"'";
		String[] inlinks = DerbyDatabase.runQuery(conn, sql);
		request.getSession().setAttribute("inlinks",deleteComma(inlinks));
		
		getServletContext().getRequestDispatcher("/index.jsp").forward(request, response);
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
    {
        doPost(request,response);
    }
	
	protected String[] deleteComma(String[] input){
		String[] output = new String[input.length];
		for(int i=0; i< input.length; i++){
			output[i] = input[i].replace(',', ' ').trim();
		}
		return output;
	}

}
