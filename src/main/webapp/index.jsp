<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<meta charset="utf-8">
<head>
  <script src="lib/d3.v3.min.js"></script>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
  <script src="./lib/jquery-ui-1.10.4.custom/js/jquery-ui-1.10.4.custom.js"></script>
  <script src="./lib/jquery-ui-1.10.4.custom/js/jquery-ui-1.10.4.custom.min.js"></script>
  <link rel="stylesheet" href="/lib/jquery-ui-1.10.4.custom/development-bundle/themes/base/jquery.ui.all.css">
  <link rel="stylesheet" href="/lib/jquery-ui-1.10.4.custom/development-bundle/demos/demos.css">
</head>
<style>

.node {
  stroke: #fff;
  stroke-width: 1.5px;
}

.link {
  stroke: #999;
  stroke-opacity: .6;
}

.svg {
    width:100%;
    height:100%;
    margin:0px;
    padding:0px;
}

#contents2 { 
    position:absolute;
    background-color:#fff;
    border-radius:15px;
    color:#000;
    display:none; 
    padding:20px;
    min-width:250px;
    min-height: 200px;
}
#myIframe{
  height: 580px;
}

</style>
<body>
<div id="contents" style="display:none">
  <img id="image" src="" />
</div>
<script>

var width = 1600,
    height = 1400,
    graph = {};

var radius = d3.scale.linear()
            .range([5,15]);

var force = d3.layout.force()
    .charge(-500)
    .linkDistance(30)
    .size([width-400, height]);

var svg = d3.select("body").append("svg")
    .attr("height", height).attr("width", width);

d3.csv("./data/nodes.csv", function(d){
  return {
    id: +d.id,
    name: d.name,
    url: d.url,
    pagerank: +d.pagerank,
    party: d.party,
    committee: d.committee,
    state: d.state,
    district: d.district
  }; 
}, function(error, nodes){
  graph.nodes = nodes
  radius.domain([0,d3.max(nodes,function(d){return d.pagerank;})]);
   d3.csv("./data/links.csv", function(d){
    return {
      source: +d.Source-1,
      target: +d.Target-1,
      weight: +d.Weight
    }; 
  }, function(error, links){
     graph.links = links;
     update();
  });
});

function update(){
    force.nodes(graph.nodes)
      .links(graph.links)
      .start();

    var linkedByIndex = {};
    graph.links.forEach(function(d) {
        linkedByIndex[d.source.index + "," + d.target.index] = 1;
    });

    function isConnected(a, b) {
        return linkedByIndex[a.index + "," + b.index] 
        || linkedByIndex[b.index + "," + a.index] 
        || a.index == b.index;
    }

    function isOutgoing(a, b){
       return linkedByIndex[a.index + "," + b.index]; 
    }

    function isIncoming(a, b){
      return linkedByIndex[b.index + "," + a.index];
    }

    var link = svg.selectAll(".link")
        .data(graph.links)
      .enter().append("line")
      .filter(function(d){return d !== null;})
        .attr("class", "link")
        .style("stroke-width", 1);

    var node = svg.selectAll(".node")
        .data(graph.nodes)
      .enter().append("circle")
      .filter(function(d){return d !== null;})
        .attr("class", "node")
        .attr("r", function(d){ return radius(d.pagerank); })
        .style("fill", function(d) { 
           if( d.party == "R" && d.committee =="H") { return "red"; }
           else if(d.party == "R" && d.committee =="S") { return "#990000"}
           else if (d.party == "D" && d.committee =="H") {return "blue"; }
           else if (d.party == "D" && d.committee =="S") {return "#000066"; }
           else {return "grey";}
        ;})
        .call(force.drag).on("mouseover", fade(.1)).on("mouseout", fade(1))
        .on("click", click);

    node.append("title")
        .text(function(d) { return d.url; });

    force.on("tick", function() {
      link.attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; });

      node.attr("cx", function(d) { return d.x; })
          .attr("cy", function(d) { return d.y; });
    });
  	var openflag = true;
	var curr_node = {
			<c:forEach items="${nodes}" var="node">
				id: "${node.id}",
				name:"${node.name}",
				url:"${node.url}",
				pagerank:"${node.pagerank}",
				state:"${node.state}",
				party:"${node.party}",
				committee:"${node.committee}",
				district:"${node.district}"
			</c:forEach>
	};
	if(!isEmpty(curr_node) && openflag){
		createDialog(curr_node);
	}
	
	function fade(opacity) {
        return function(d) {
            node.style("stroke-opacity", function(o) {
                thisOpacity = isConnected(d, o) ? 1 : opacity;
                this.setAttribute('fill-opacity', thisOpacity);
                return thisOpacity;
            });

            link.style("stroke-opacity", function(o) {
                return o.source === d || o.target === d ? 1 : opacity;
            }).style("stroke-width", function(o) {
                if (o.source ===d){ return 1;}
                else if(o.target ===d){ return 2;}
            }).style("stroke", function(o) {
                if (o.source ===d){ return "grey";}
                else if(o.target ===d){ return "green";}
            });
        };
    }

    function click(d,e) {
      $.ajax({  
    	    type: "POST",  
    	    url: "ClickServlet",  
    	    data: "id="+d.id,  
    	    success: function(data){ 
    	    	uri = './images/' + d.name.replace(',','') +".png";
    	    	var content = setContent(d);
    	  		content = setLinksViaJSONData(d,content,data);
    	        var popup = document.getElementById("contents")
    	        popup.innerHTML = content;
    	    
    	        $('#contents').attr("title",setTitle(d))
    	        .css({"font-size": +14+"px"})
    	        .dialog({
    	            width:'auto',
    	            height:500,
    	            modal: true,
    	            open: function(event, ui){
    	               $('#image').attr('src',uri);
    	            }
    	        });
    	    }  
      });  
    }
	
    function createDialog(d){
    	uri = './images/' + d.name.replace(',','') +".png";
  		var content = setContent(d);
  		content = setLinksViaRequestData(d,content);
        var popup = document.getElementById("contents")
        popup.innerHTML = content;
    
        $('#contents').attr("title",setTitle(d))
        .css({"font-size": +14+"px"})
        .dialog({
            width:'auto',
            height:500,
            modal: true,
            open: function(event, ui){
               $('#image').attr('src',uri);
            }
        });
    }
    
    function setContent(d){
    	var content = "";
        if(d.party ==='D' || d.party==='R'){
          content = "<img id='image' src='' /><br\>";
        }
        content += "<b> Name: </b>"+d.name;
        title = "Committee";
        if(d.party === 'D'){ 
            content += "<br\> <b> Party: </b>" + "Democratic";
            title = "Democratic Member";
        }
        else if (d.party === 'R'){ 
            content += "<br\> <b> Party: </b>" + "Republican"; 
            title = "Republican Member"
        }
        if(d.state && d.state !== "null"){content += "<br\><b>State: </b>" + d.state; }
        if(d.district && d.district !== "null"){content += "<br\><b> District: </b>" + d.district; }
        content += "<br\><b> Homepage: </b>" + d.url; 
  		return content;
    }
    
    function setLinksViaRequestData(d, content){
    	content += "<br\><br\><b> Outgoing Links: </b>";
        content += "<ul><c:forEach items='${outlinks}' var='outlink'>"
        			+"<li><a id='link' href='/LinkServlet?id=${ outlink.id }'>"
  				+"<c:out value='${outlink.name}'></c:out>"
  				+"</a></li></c:forEach></ul>";
		content += "<b> Incoming Links: </b>";
        content += "<ul><c:forEach items='${inlinks}' var='inlink'>"
        			+"<li><a id='link' href='/LinkServlet?id=${ inlink.id }'>"
  				+"<c:out value='${inlink.name}'></c:out>"
  				+"</a></li></c:forEach></ul>";
  		return content
    }
    
    function setLinksViaJSONData(d, content, jsondata){
    	content += "<br\><br\><b> Outgoing Links: </b> <ul>";
        for(var i=0; i<jsondata.outlinks.length; i++){
        	content += "<li><a id='link' href='/LinkServlet?id="+jsondata.outlinks[i].id+"'>"
        			+ jsondata.outlinks[i].name
        			+ "</a></li>";
        }
		content += "</ul>"
				+ "<b> Incoming Links: </b>"
				+ "<ul>";
		for(var i=0; i<jsondata.inlinks.length; i++){
        	content += "<li><a id='link' href='/LinkServlet?id="+jsondata.inlinks[i].id+"'>"
        			+ jsondata.inlinks[i].name
        			+ "</a></li>";
        }
        content +="</ul>";
  		return content;
    }
    
    function setTitle(d){
    	title = "Committee";
        if(d.party === 'D'){ 
            title = "Democratic Member";
        }
        else if (d.party === 'R'){ 
            title = "Republican Member"
        }
        return title;
    }
    
    function ImageExist(url) 
    {
        var img = new Image();
        img.src = url;
        console.log(url+" "+img.height);
        return img.height != 0;
    }
    
    function isEmpty(obj) {
    	var hasOwnProperty = Object.prototype.hasOwnProperty;
        // null and undefined are "empty"
        if (obj == null) return true;

        // Assume if it has a length property with a non-zero value
        // that that property is correct.
        if (obj.length > 0)    return false;
        if (obj.length === 0)  return true;

        // Otherwise, does it have any properties of its own?
        // Note that this doesn't handle
        // toString and valueOf enumeration bugs in IE < 9
        for (var key in obj) {
            if (hasOwnProperty.call(obj, key)) return false;
        }

        return true;
    }
  }

</script>