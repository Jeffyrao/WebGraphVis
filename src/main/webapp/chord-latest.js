d3.chart = d3.chart || {};

d3.chart.chord = function(options) {
    var self = {};

    var svg;

    var w = 500, h = 800, r1 = 3*h / 7, r0 = r1 - 110;
    var pad = 0.01;
    var coloring="bigger";
    var nodes;
    
    var chord = d3.layout.chord()
    .padding(pad)
    .sortSubgroups(d3.descending);

    var arc_svg = d3.svg.arc().innerRadius(r0).outerRadius(r0+20);
    var chord_svg = d3.svg.chord().radius(r0);

    for (key in options) {
        self[key] = options[key];
    }
    
    d3.csv("./data/prefix.csv", function(error, prefix){
    	nodes = prefix;
    });
    
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
       }
    };

    self.clear = function() {
        d3.select(self.container).selectAll('svg').remove();
    };

    self.transition = function(old) {
        svg.selectAll(".ticks")
              .transition()
              .duration(200)
              .attr("opacity", 0);

        svg.selectAll(".arc")
          .data(chord.groups)
          .transition()
          .duration(1500)
          .attrTween("d", arcTween(arc_svg, old));

        svg.selectAll(".chord")
          .selectAll("path")
          .data(chord.chords)
          .transition()
          .duration(1500)
          .style("fill", function(d) { return self.fill(comp[coloring](d.source, d.target).index); })
          .attrTween("d", chordTween(chord_svg, old));

        setTimeout(self.drawTicks, 1100);
    };

    self.render = function() {
        self.clear();

        svg = d3.select(self.container)
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
        
        svg.append("g")
          .selectAll("path")
            .data(chord.groups)
          .enter().append("path")
            .attr("class", "arc")
            .style("fill", function(d) { return color(nodes[d.index]);)
            .style("stroke", "grey")
            .attr("d", arc_svg)
            .on("mouseover", mouseover)
            .on("mouseout", mouseout);

        svg.append("g")
            .attr("class", "chord")
          .selectAll("path")
            .data(chords)
          .enter().append("path")
          	.style("stroke", "grey")
            .style("fill", function(d) { return color(nodes[d.source.index]); })
            .attr("d", chord_svg)
            .on("mouseover", mouseover)
            .on("mouseout", mouseout);

        self.drawTicks();
    };


    self.drawTicks = function() {
        svg.selectAll(".ticks").remove();

        var ticks = svg.append("g")
          .attr("class", "ticks")
          .attr("opacity", 0.1)
          .selectAll("g")
            .data(chord.groups)
          .enter().append("g")
          .selectAll("g")
            .data(groupTicks)
          .enter().append("g")
            .attr("transform", function(d) {
              return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
                  + "translate(" + r1 + ",0)";
            });

        ticks.append("line")
            .attr("x1", 1)
            .attr("y1", 0)
            .attr("x2", 5)
            .attr("y2", 0)
            .style("stroke", "#000");

        ticks.append("text")
            .attr("x", 8)
            .attr("dy", ".35em")
            .attr("text-anchor", function(d) {
              return d.angle > Math.PI ? "end" : null;
            })
            .attr("transform", function(d) {
              return d.angle > Math.PI ? "rotate(180)translate(-16)" : null;
            })
            .text(function(d) { return d.label; });

        svg.selectAll(".ticks").transition()
          .duration(340)
          .attr("opacity", 1);

    };
    
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

    return self;
};


/* Utility functions */

/** Returns an array of tick angles and labels, given a group. */
function groupTicks(d) {
  var k = (d.endAngle - d.startAngle) / d.value;
  return d3.range(0, d.value, 20).map(function(v, i) {
    return {
      angle: v * k + d.startAngle,
      label: i % 5 ? null : v
    };
  });
}

/** Returns an event handler for fading a given chord group. */
function fade(opacity, svg) {
  return function(g, i) {
    svg.selectAll("g.chord path")
        .filter(function(d) {
          return d.source.index != i && d.target.index != i;
        })
      .transition()
        .style("opacity", opacity);
  };
}

// Interpolate the arcs
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
