<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head><title>Word Count Query</title></head>
<body>
<p>Enter Word:</p>
<form method="GET" action=""/>
<input name="word" type="text" size="20"/><br/><br/>
<input type="submit" value="Submit" />
</form>
<B>This is <%= new java.util.Date() %>.</B>


<!--<c:out value="word"></c:out>
<c:out value="${word}"></c:out>
<c:if test="not empty word">
	<ul>
		<c:forEach items="${word.count}" var="count">
			<li><c:out value="${count}"></c:out></li>
		</c:forEach>
	</ul>
</c:if> -->
</body>
</html>
