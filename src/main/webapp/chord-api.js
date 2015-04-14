d3.chart = d3.chart || {};

d3.chart.chord = function(options) {
    var self = {};

    var svg;
    var w = 500, h = 800, r1 = 3*h / 7, r0 = r1 - 110;
    var pad = 0.01;
    
    
    var chord = d3.layout.chord()
	.padding(pad)
    .sortSubgroups(d3.descending)
    
    var arc_svg = d3.svg.arc()
    .innerRadius(r0)
    .outerRadius(r0 + 20);
    var chord_svg = d3.svg.chord().radius(r0);
    var nodes;
    
    d3.csv("./data/prefix.csv", function(error, prefix){
    	nodes = prefix;
    });
    console.log(nodes);
    
    self.update = function(data) {
        if (!chord.matrix()) {
            chord.matrix(data);
            self.render();
        } else {
            var old = {
                groups: chord.groups(),
                chords: chord.chords()
            };
            chord.matrix(data);
            self.transition(old);
            console.log(old);
        }
        
     };

     self.clear = function() {
         d3.select(options.container).selectAll('svg').remove();
     };
     
     self.transition = function(old) {
         /*svg.selectAll(".ticks")
               .transition()
               .duration(200)
               .attr("opacity", 0);*/
         svg.selectAll("path.group")
           .data(chord.groups())
           .transition()
           .duration(1500)
           .attrTween("d", arcTween(arc_svg, old));

         svg.selectAll("path.chord")
           .data(chord.chords())
           .transition()
           .duration(1500)
           .attrTween("d", chordTween(chord_svg, old));

         //setTimeout(self.drawTicks, 1100);
     };
     
     self.render = function() {
    	 svg = d3.select(options.container)
         .append("svg")
           .attr("width", w)
           .attr("height", h)
         .append("g")
           .attr("transform", "translate(" + w / 2 + "," + h / 2 + ")");
    	 
    	 chord.chords()
	     .forEach(function(d){
	    	 d.option = options.option;
	     });
    	 
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
        .attr("d", arc_svg);
	    
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
            .attr("d", chord_svg)
            .on("mouseover", mouseover)
            .on("mouseout", mouseout);
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
    		}
    	    d3.select("#tooltip")
    	      .style("visibility", "visible")
    	      .html(tip)
    	      .style("top", function () { return (d3.event.pageY - 80)+"px"})
    	      .style("left", function () { return (d3.event.pageX - 130)+"px";})
    	    svg.selectAll("path.chord")
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
     
     return self;
};

//Interpolate the arcs
function arcTween(arc_svg, old) {
    return function(d,i) {
        var i = d3.interpolate(old.groups[i], d);
        return function(t) {
            return arc_svg(i(t));
        }
    }
}

// Interpolate the chords
function chordTween(chord_svg, old) {
    return function(d,i) {
        var i = d3.interpolate(old.chords[i], d);
        return function(t) {
            return chord_svg(i(t));
        }
    }
}
