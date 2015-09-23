function plotQuery(topic, data, query, years) {
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
    if (data[i][2] > 0) { // count relevant documents
      var bucket = Math.floor(data[i][1] / interval);
      total++;
      arr[interval_count - bucket]++;
    }
  }
  console.log("total:" + total);
  console.log(arr);
  for (var i=0; i<interval_count; i++) {
    if (total != 0) {
      arr[i] /= total;
    } else {
      arr[i] = 0;
    }
  }
  var maxBarValue = 0;
  for (var i=0; i<interval_count; i++) {
    if ( arr[i] > maxBarValue) {
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
       .attr("stroke", "rgba(0, 0, 255, 0.75)");

  svg.selectAll("circle")
     .data(data)
     .enter()
     .append("circle")
     .attr("class",
       function(d) { 
        if ( d[2] == 2 ) return "highly_relevant";
        if ( d[2] == 1 ) return "relevant";
        return "not_relevant"; 
       })
     .attr("cx", function(d) {
        return xScale(d[1]/interval);
      })
     .attr("cy", function(d) {
        return topPadding + Math.floor((Math.random()* (h-bottomPadding-topPadding-10))+1);;
       })
     .attr("r", function(d) { if ( d[2] > 0 ) return "2"; return "1"; });

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

}
