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
	
	p.incoming {
		position: absolute;
		top: -15px;
		left: 200px;
		font-size:200%;	
	}
	
	p.outgoing {
		position: absolute;
		top: -15px;
		right: 200px;
		font-size:200%;	
	}
	
</style>
<body>
<div id="tooltip"></div>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script>

var graph = {};
var pad = 0.01;
var nodes;

var chord = d3.layout.chord()
	.padding(pad)
    .sortSubgroups(d3.descending)

var w = 1280, h = 800, r1 = 3*h / 7, r0 = r1 - 110;

var arc = d3.svg.arc()
.innerRadius(r0)
.outerRadius(r0 + 20);

var svg = d3.select("body").append("svg")
    .attr("width", w)
    .attr("height", h);
var inlink_svg = svg.append("g")
    .attr("transform", "translate(" + w / 4 + "," + h/2 + ")");
var outlink_svg = svg.append("g")
.attr("transform", "translate(" + 3*w / 4 + "," + h/2 + ")");

var linkDir = './data/matrixlinks/'
var defaultDate = '200401';
var myDate = location.search.split('date=')[1] ? location.search.split('date=')[1] : defaultDate;

LoadLink(linkDir+'inlinks-'+myDate+'.json',inlink_svg,"in");
LoadLink(linkDir+'outlinks-'+myDate+'.json',outlink_svg,"out");

function LoadLink(linkfile, svg, option){
	d3.csv("./data/prefix.csv", function(error, prefix){
			d3.json(linkfile, function(error,matrix) {
			 var sum=0, prev_angle=0;
			 nodes = prefix;
		     chord.matrix(matrix);
		     chord.chords()
		     .forEach(function(d){
		    	 d.option = option;
		     });
		     /*chord.groups()
		     .forEach(function(d){
		    	 d.sum = d.value;
		    	 d.value = log10(d.value+1)+1;
		    	 sum += d.value;
		     });
		     chord.groups()
		     .forEach(function(d){
		    	 d.startAngle = prev_angle;
		    	 d.endAngle = d.startAngle + 2*Math.PI*d.value/sum ;
		    	 d.angle = d.endAngle - d.startAngle;
		    	 prev_angle = d.endAngle + pad/nodes.length;
		     });
		     var groups = chord.groups();
		     var chords_mat = new Array(nodes.length);
		     for(var i=0; i<nodes.length; i++){
		    	 chords_mat[i] = new Array(nodes.length);
		    	 var start_angle = groups[i].startAngle;
		    	 for( var j=0; j<nodes.length; j++){
		    		 chords_mat[i][j]={};
		    		 if(matrix[i][j]!==0){
		    			 chords_mat[i][j].startAngle = start_angle;
		    			 chords_mat[i][j].endAngle = start_angle + 
		    			 	matrix[i][j]*(groups[i].endAngle-groups[i].startAngle)/groups[i].sum;
		    			 start_angle = chords_mat[i][j].endAngle;
		    		 }else{
		    			 chords_mat[i][j].startAngle = groups[i].endAngle;
		    			 chords_mat[i][j].endAngle = groups[i].endAngle;
		    		 }
		    	 }
		     }
		     
		     chord.chords()
		     .forEach(function(d){
		    	 d.source.startAngle = chords_mat[d.source.index][d.source.subindex].startAngle;
		    	 d.source.endAngle = chords_mat[d.source.index][d.source.subindex].endAngle;
		    	 d.target.startAngle = chords_mat[d.target.index][d.target.subindex].startAngle;
		    	 d.target.endAngle = chords_mat[d.target.index][d.target.subindex].endAngle;
		     })
		     console.log(chord.groups());
		     console.log(chord.chords());*/
		     chords = chord.chords()
			  .filter(function(d){
				  return d.source.index != d.target.index || d.source.value != 0.5;
			  });
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
	         .style("color", function(d){ return color(nodes[d.index]); })
	         .attr("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
	         .attr("transform", function(d) {
	           return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
	               + "translate(" + (r0 + 26) + ")"
	               + (d.angle > Math.PI ? "rotate(180)" : "");
	         })
	         .text(function(d) { return nodes.filter(function(n){ return parseInt(n.id) ===d.index+1; })[0].name; });
	
	       var chordPaths = svg.selectAll("path.chord")
	             .data(chords)
	           .enter().append("svg:path")
	             .attr("class", "chord")
	             .style("stroke", "grey")
	             .style("fill", function(d) { return color(nodes[d.source.index]); })
	             .attr("d", d3.svg.chord().radius(r0))
	             .on("mouseover", mouseover)
	             .on("mouseout", mouseout);
		  });
		});
	}
	
function chordTip (d) {
    var source = nodes.filter(function(n){ return parseInt(n.id) ===d.source.index+1; });
    var target = nodes.filter(function(n){ return parseInt(n.id) ===d.target.index+1; });
    if(d.option === "in"){
    	weight1 = parseInt(Math.pow(10,d.source.value)-1);
    	weight2 = parseInt(Math.pow(10,d.target.value)-1);
    	return "Chord Info:<br/>"
        +  target[0].name + " -> " + source[0].name
        + ": " + weight1 + "<br/>"
        + source[0].name + " -> " + target[0].name
        + ": " + weight2 + "<br/>";
    }else{
    	weight1 = parseInt(Math.pow(10,d.source.value)-1);
    	weight2 = parseInt(Math.pow(10,d.target.value)-1);
    	return "Chord Info:<br/>"
        +  source[0].name + " -> " + target[0].name
        + ": " + weight1 + "<br/>"
        + target[0].name + " -> " + source[0].name
        + ": " + weight2 + "<br/>";
    }
    
  }

  function groupTip (d) {
	  
    var node = nodes.filter(function(n){ return parseInt(n.id) ===d.index+1; });
    return "Group Info:<br/>"
        + node[0].name + " : " + node[0].url + "<br/>";
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
		console.log(d);
	}
    d3.select("#tooltip")
      .style("visibility", "visible")
      .html(tip)
      .style("top", function () { return (d3.event.pageY - 80)+"px"})
      .style("left", function () { return (d3.event.pageX - 130)+"px";})
    inlink_svg.selectAll("path.chord")
	   .filter(function(d) { 
		   if(sid === tid)
		   	   return d.source.index != sid; 
		   else
			   return d.source.index != sid || d.target.index != tid; })
	   .transition()
	   .style("opacity", 0);
    outlink_svg.selectAll("path.chord")
	   .filter(function(d) { 
		   if(sid === tid)
		   	   return d.source.index != sid; 
		   else
			   return d.source.index != sid || d.target.index != tid; })
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
	  if( d.party === "R") { return "red"; }
	  else if(d.party === "D"){return "blue";}
      else {return "grey";}
  }
  
  function log10(val) {
	  return Math.log(val) / Math.LN10;
  }
</script>
<p class="incoming"> Incoming Links </p>
<p class="outgoing"> Outgoing Links </p>
</body>
