package web.graph.vis;

import java.io.IOException;
import java.sql.Connection;

import javax.servlet.Servlet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

public class GetLinksServlet extends HttpServlet implements Servlet {
	
	public static Connection conn = DerbyDatabase.getConnInstance();
	public static String server = "http://tibanna.umiacs.umd.edu:9191/c108"; 
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
		String id = request.getParameter("id");
		String url = request.getParameter("url");
		String sql = "";
		if(id == null) id = "-1";
		
		sql = "select * from APP.NODES where id='"+id+"'";
		String[] node = DerbyDatabase.runQuery(conn, sql);
		request.getSession().setAttribute("nodes",parseResults(node));
		
		
		
		//Get all outgoing links
		sql = "select APP.NODES.* from APP.LINKS JOIN APP.NODES on APP.LINKS.src = '"+id
				+"' and APP.NODES.id = APP.LINKS.dest ORDER BY APP.NODES.pagerank DESC";
		String[] outlinks = DerbyDatabase.runQuery(conn, sql);
		request.getSession().setAttribute("outlinks",parseResults(outlinks));
		//Get all incoming links
		sql =  "select APP.NODES.* from APP.LINKS JOIN APP.NODES on APP.LINKS.dest = '"+id
				+"' and APP.NODES.id = APP.LINKS.src ORDER BY APP.NODES.pagerank DESC";
		String[] inlinks = DerbyDatabase.runQuery(conn, sql);
		request.getSession().setAttribute("inlinks",parseResults(inlinks));
		
		if(url != null){
			Document doc = Jsoup.connect(server+"?query="+url).get();
			Element link = doc.select("a[href]").first();
			String linkHref = link.attr("href");
			if(linkHref.equals(server)){
				linkHref = server+url;
			}
			request.getSession().setAttribute("href",linkHref);
		}
		
		getServletContext().getRequestDispatcher("/index.jsp").forward(request, response);
    }
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException
    {
        doPost(request,response);
    }
	
	protected Node[] parseResults(String[] input){
		Node[] output = new Node[input.length];
		for(int i=0; i< input.length; i++){
			String[] attr = input[i].split(";");
			output[i] = new Node(attr[0].trim(), attr[1].trim(), attr[2].trim(), attr[3].trim(),
					attr[4].trim(), attr[5].trim(), attr[6].trim(), attr[7].trim());
		}
		return output;
	}

}
