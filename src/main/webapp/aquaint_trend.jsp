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
d3.json("lib/apw_query_counts.json", function(error, apw){
	d3.json("lib/nyt_query_counts.json", function(error, nyt){
		d3.json("lib/xie_query_counts.json", function(error, xie){
			for(var queryId in aquaint_dataset) {
				var query = aquaint_dataset[queryId]["query"];
				var qrels = aquaint_dataset[queryId]["qrels"];
				var apw_words = apw[queryId]['words']
				var nyt_words = nyt[queryId]['words']
				var xie_words = xie[queryId]['words']
				plotQuery(queryId, qrels["APW"], "APW - " + query, 3);
				for(var word in apw_words) {
					if (apw_words.hasOwnProperty(word)) {
						plotWord(queryId, apw_words[word].slice(150), word, 3);
					}
				}
				plotQuery(queryId, qrels["NYT"], "NYT - " + query, 3);
				for(var word in nyt_words) {
					if (nyt_words.hasOwnProperty(word)) {
						plotWord(queryId, nyt_words[word].slice(150), word, 3);
					}
				}
				plotQuery(queryId, qrels["XIE"], "XIE - " + query, 5);
				for(var word in xie_words) {
					if (xie_words.hasOwnProperty(word)) {
						plotWord(queryId, xie_words[word], word, 5);
					}
				}
			}
		});
	});
});

function plotWord(topic, data, query, years) {
  var w = 800;
  var h = 60;
  var topPadding = 5;
  var leftPadding = 10;
  var rightPadding = 50;
  var bottomPadding = 20;
  var interval = 15.0 // documents in 15 days are grouped together
  var interval_count = years * 12 * 30 / interval

  var arr = new Array();
  for (var i=0; i<interval_count; i++) {
    arr[i] = 0;
  }
  var total = 0;
  for (var i=0; i<data.length; i++) {
	  var bucket = Math.floor(i / interval);
	  total = total + data[i]
	  arr[interval_count - bucket - 1] += data[i];
	  //arr[bucket] += data[i];
  }
  console.log("total:" + total);
  //console.log(arr);
  for (var i=0; i<interval_count; i++) {
    if (total != 0) {
      arr[i] /= total;
    } else {
      arr[i] = 0;
    }
  }
  var maxBarValue = 0;
  for (var i=0; i<interval_count; i++) {
    if (arr[i] > maxBarValue) {
      maxBarValue = arr[i];
    }
  }


  // Create scale functions
  var xScale =
    d3.scale.linear()
      .domain([0, interval_count])
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

  var barWidth = (w - leftPadding - rightPadding) / (interval_count);
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
    .text(topic + ": " + query).attr("x", w-rightPadding+5).attr("y", h-bottomPadding)
    .attr("font-family", "sans-serif")
    .attr("font-size", "14px")
    .attr("fill", "black");

  d3.select("body").append("br");

  function mouseover(d, i) {
	d3.select("#tooltip")
      .style("visibility", "visible")
      .html(Math.floor(arr[i]*total))
      .style("top", function () { return (d3.event.pageY -10)+"px"})
      .style("left", function () { return (d3.event.pageX - 10)+"px";})
  }

  function mouseout(d) {
	d3.select("#tooltip").style("visibility", "hidden");
  }
}

</script>
</html>