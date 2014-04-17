<!DOCTYPE html>
<meta charset="utf-8">
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
	#circle circle {
	  fill: none;
	  pointer-events: all;
	}
	path.group {
	  fill-opacity: .8;
	}
	path.chord {
	  fill-opacity: .8;
	  stroke: #000;
	  stroke-width: .25px;
	}
	#circle:hover path.fade {
	  display: none;
	}
</style>
<body>
<div id="tooltip"></div>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script>

var graph = {};

var chord = d3.layout.chord()
    .padding(.02)
    .sortSubgroups(d3.descending)

var w = 980, h = 800, r1 = h / 2, r0 = r1 - 110;

var arc = d3.svg.arc()
.innerRadius(r0)
.outerRadius(r0 + 20);

var svg = d3.select("body").append("svg")
    .attr("width", w)
    .attr("height", h)
  .append("g")
    .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")");
    
d3.csv("./data/prefix.csv", function(error, nodes){
		d3.json("./data/sitematrix.json", function(error,matrix) {
	     chord.matrix(matrix);
	     
	    var g = svg.selectAll("g.group")
         .data(chord.groups())
       	 .enter().append("svg:g")
         .attr("class", "group")
         .on("mouseover", mouseover)
         .on("mouseout", mouseout);
	     
	    g.append("svg:path")
         .style("stroke", "grey")
         .style("fill", function(d) { return color(nodes[d.index]); })
         .attr("d", arc);

     	g.append("svg:text")
         .each(function(d) { d.angle = (d.startAngle + d.endAngle) / 2; })
         .attr("dy", ".35em")
         .style("font-family", "helvetica, arial, sans-serif")
         .style("font-size", "9px")
         .attr("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
         .attr("transform", function(d) {
           return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
               + "translate(" + (r0 + 26) + ")"
               + (d.angle > Math.PI ? "rotate(180)" : "");
         })
         .text(function(d) { return nodes[d.index].name; });

       var chordPaths = svg.selectAll("path.chord")
             .data(chord.chords())
           .enter().append("svg:path")
             .attr("class", "chord")
             .style("stroke", "grey")
             .style("fill", function(d) { return color(nodes[d.source.index]); })
             .attr("d", d3.svg.chord().radius(r0))
             .on("mouseover", mouseover)
             .on("mouseout", mouseout);
		
       function chordTip (d) {
    	    var p = d3.format(".1%"), q = d3.format(",.2r")
    	    return "Chord Info:<br/>"
    	      +  nodes[d.source.index].name + " -> " + nodes[d.target.index].name
    	      + ": " + nodes[d.source.index].id + "<br/>"
    	      + nodes[d.target.index].name + " -> " + nodes[d.source.index].name
    	      + ": " + nodes[d.target.index].id + "<br/>";
    	  }

    	  function groupTip (d) {
    	    var p = d3.format(".1%"), q = d3.format(",.2r")
    	    return "Group Info:<br/>"
    	        + nodes[d.index].name + " : " + nodes[d.index].id + "<br/>";
    	    }

    	  function mouseover(d) {
    		
    		var sid, tid, tip;
    		if(d.source){
    			sid = d.source.index;
    			tid = d.target.index;
    			tip = chordTip(d);
    		}else{
    			sid = d.index;
    			tid = d.index;
    			tip = groupTip(d);
    		}
    	    d3.select("#tooltip")
    	      .style("visibility", "visible")
    	      .html(tip)
    	      .style("top", function () { return (d3.event.pageY - 80)+"px"})
    	      .style("left", function () { return (d3.event.pageX - 130)+"px";})
			
    	    svg.selectAll("path.chord")
    		   .filter(function(d) { 
    			   if(sid === tid)
    			   		return d.source.index != sid && d.target.index != tid;
    			   else
    				   return d.source.index != sid || d.target.index != tid;})
    		   .transition()
    		   .style("opacity", 0);
    	  }
    	  
    	  function mouseout(d, i){
    		  d3.select("#tooltip").style("visibility", "hidden");
    		  svg.selectAll("path.chord")
    		  	.transition()
    		  	.style("opacity", 1);
    	  }
    	  
    	  function color(d){
    		  if( d.party == "R" && d.committee =="H") { return "red"; }
    	      else if(d.party == "R" && d.committee =="S") { return "#990000"}
    	      else if (d.party == "D" && d.committee =="H") {return "blue"; }
    	      else if (d.party == "D" && d.committee =="S") {return "#000066"; }
    	      else {return "grey";}
    	  }
	  });
	});

</script>
