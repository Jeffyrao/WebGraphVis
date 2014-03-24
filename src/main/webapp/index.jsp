<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<html>
<body>

<b>Node:</b><c:out value="${ id }"></c:out><br/>

<b>Outgoing Links:</b>
<ul>
<c:forEach items="${outlinks}" var="outlink">
	<li>
		<a href="<%=request.getContextPath()%>/LinkServlet?id=${ outlink }" >
			<c:out value="${outlink}"></c:out>
		</a>
	</li>
</c:forEach>
</ul>

<b>Incoming Links:</b>
<ul>
<c:forEach items="${ inlinks }" var="inlink">
	<li>
		<a href="<%=request.getContextPath()%>/LinkServlet?id=${inlink}" >
			<c:out value="${inlink}"></c:out>
		</a>
	</li>
</c:forEach>
</ul>
</body>
</html>
