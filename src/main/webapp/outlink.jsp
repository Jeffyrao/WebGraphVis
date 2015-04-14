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
	.chord path {
      fill-opacity: .67;
      stroke: #000;
      stroke-width: .5px;
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
	
	#incomingChart{
		float: left;
      	font: 10px sans-serif;
      	padding: 20px;
      	text-align: center;
      	width: 550px;
	}
	#outgoingChart{
		float: right;
      	font: 10px sans-serif;
      	padding: 20px;
      	text-align: center;
      	width: 550px;
	}
</style>
<body>
<div id="tooltip"></div>
<div id="incomingChart"></div>
<div id="outgoingChart"></div>

<p class="incoming"> Incoming Links </p>
<p class="outgoing"> Outgoing Links </p>
<button id="back">Back</button>
<div id="currentDate"></div>
<button id="forward">Forward</button>

<script src="http://d3js.org/d3.v3.min.js"></script>
<script src="./chord-latest.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min.js"></script>
<script src="./lib/jquery-ui-1.10.4.custom/js/jquery-ui-1.10.4.custom.js"></script>
<script src="./lib/jquery-ui-1.10.4.custom/js/jquery-ui-1.10.4.custom.min.js"></script>
<script>

var linkDir = './data/matrixlinks/';
var defaultYear = 2004;
var defaultMonth = 0;
var myDate = new Date(defaultYear, defaultMonth);

var incoming_chord = d3.chart.chord({
	container: "#incomingChart",
	option: "in"
});

var outgoing_chord = d3.chart.chord({
	container: "#outgoingChart",
	option: "out"
});

console.log(incoming_chord);

initChord(myDate);

d3.select('#back').on("click", function(){
	if(defaultMonth == 0){
		defaultYear -= 1;
		defaultMonth = 11;
	}else{
		defaultMonth -= 1;
	}
	myDate = new Date(defaultYear, defaultMonth);
	initChord(myDate);
});

d3.select('#forward').on("click", function(){
	if(defaultMonth == 12){
		defaultYear += 1;
		defaultMonth = 1;
	}else{
		defaultMonth += 1;
	}
	myDate = new Date(defaultYear, defaultMonth);
	initChord(myDate);
});

function initChord(myDate){
	document.getElementById("currentDate").innerHTML = $.datepicker.formatDate('yymm',myDate);
	var inLinkFile = linkDir+'inlinks-'+$.datepicker.formatDate('yymm',myDate)+'.json';
	var outLinkFile = linkDir+'outlinks-'+$.datepicker.formatDate('yymm',myDate)+'.json';
	d3.json(inLinkFile, function(error, data){
		incoming_chord.update(data);
	});	
	d3.json(outLinkFile, function(error, data){
		outgoing_chord.update(data);
	});
}
</script>
