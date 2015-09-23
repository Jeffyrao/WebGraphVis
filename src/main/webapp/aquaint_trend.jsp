<html lang="en">
<head>
<meta charset="utf-8">
<title>Scatterplot</title>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script type="text/javascript" src="lib/aquaint-query-trend.js"></script>
<script type="text/javascript" src="lib/visualize-aquaint.js"></script>
<link rel="stylesheet" href="lib/visualize.css" type="text/css" />
<style>
#tooltip {
	  color: white;
	  opacity: .9;
	  background: #333;
	  padding: 5px;
	  border: 1px solid lightgrey;
	  border-radius: 5px;
	  position: absolute;
	  z-index: 10;
	  visibility: hidden;
	  white-space: nowrap;
	  pointer-events: none;
	}
</style>
</head>
<body>
<div id="tooltip"></div>
</body>
<script>
	for(var queryId in aquaint_dataset) {
		var query = aquaint_dataset[queryId]["query"];
		var qrels = aquaint_dataset[queryId]["qrels"];
		plotQuery(queryId, qrels["APW"], "APW - " + query, 3);
		plotQuery(queryId, qrels["NYT"], "NYT - " + query, 3);
		plotQuery(queryId, qrels["XIE"], "XIE - " + query, 5);
	}
</script>
</html>