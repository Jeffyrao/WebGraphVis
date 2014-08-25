<html lang="en">
<head>
<meta charset="utf-8">
<title>Scatterplot</title>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script type="text/javascript" src="lib/trec2011-data.js"></script>
<script type="text/javascript" src="lib/visualize.js"></script>
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
var topic = location.search.split('topic=')[1] ? topic = location.search.split('topic=')[1] : "";

d3.json("data/query-words.json", function(error, wordset){
	d3.json("data/query-bigrams.json", function(error, bigramset){
		if (topic != "") {
			var words = wordset[topic]['words'];
			plotQuery(topic, dataset[topic]["qrels"], dataset[topic]["query"])
			for (var word in words){
				if (words.hasOwnProperty(word)) {
					plot(topic, words[word], word);
				}
			}
			var bigrams = bigramset[i]['words'];
			for (var bigram in bigrams){
				if (bigrams.hasOwnProperty(bigram)) {
					plot(i, bigrams[bigram], bigram);
				}
			}
		} else {
			for(var i = 1; i <= 49; i++) {
				var words = wordset[i]['words'];
				plotQuery(i, dataset[i]["qrels"], dataset[i]["query"]);
				for (var word in words){
					if (words.hasOwnProperty(word)) {
						plot(i, words[word], word);
					}
				}
				var bigrams = bigramset[i]['words'];
				for (var bigram in bigrams){
					if (bigrams.hasOwnProperty(bigram)) {
						plot(i, bigrams[bigram], bigram);
					}
				}
			}
		}
	});
});

function plot(topic, data, word) {
	var w = 800;
	var h = 60;
	var days = 18;
	var topPadding = 5;
	var leftPadding = 10;
	var rightPadding = 50;
	var bottomPadding = 20;
	
	data = data.reverse();
	var arr = new Array();
	var maxBarValue = 0;
	var total = 0;
	for (var i=0; i<days; i++) {
		total += data[i];
	}
	for (var i=0; i<days; i++) {
		arr[i] = (total == 0)? 0 : (data[i] / total);
		if (arr[i] > maxBarValue) {
		    maxBarValue = arr[i];
		}
	}
	
	var xScale =
		  d3.scale.linear()
		    .domain([0, days])
		    .range([w-rightPadding, leftPadding]);

		var yBarScale =
		  d3.scale.linear()
		    .domain([0, maxBarValue])
		    .range([0, h-bottomPadding-5]);

		// Define X axis
		var xAxis = d3.svg.axis()
		  .scale(xScale)
		  .orient("bottom");

		// Create SVG element
		var svg =
		  d3.select("body")
		    .append("svg")
		    .attr("width", w + 200)
		    .attr("height", h);

		var barWidth = (w - leftPadding - rightPadding) / (days);
		svg.selectAll("rect")
		     .data(arr)
		     .enter().append("rect")
		     .attr("x", function(d, i) { return i * barWidth + leftPadding; })
		     .attr("y", function(d) { return h - bottomPadding - yBarScale(d) })
		     .attr("width", barWidth)
		     .attr("height", function(d) { return yBarScale(d) })
		     .attr("fill", "rgba(0, 0, 255, 0.25)")
		     .attr("stroke", "rgba(0, 0, 255, 0.75)")
		     .on("mouseover", mouseover)
	         .on("mouseout", mouseout);

		// Create X axis
		svg.append("g")
		   .attr("class", "axis")
		   .attr("transform", "translate(0," + (h-bottomPadding) + ")")
		   .call(xAxis);

		svg.append("text")
		  .text(topic + ": " + word).attr("x", w-rightPadding+5).attr("y", h-bottomPadding)
		  .attr("font-family", "sans-serif")
		  .attr("font-size", "14px")
		  .attr("fill", "black");

		d3.select("body").append("br");
		
		function mouseover(d, i) {
			d3.select("#tooltip")
		      .style("visibility", "visible")
		      .html(data[i])
		      .style("top", function () { return (d3.event.pageY -10)+"px"})
		      .style("left", function () { return (d3.event.pageX - 10)+"px";})
		}
		
		function mouseout(d) {
			d3.select("#tooltip").style("visibility", "hidden");
		}
}

</script>
</html>