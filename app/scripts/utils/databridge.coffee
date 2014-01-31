###
	
Convert json returns to chart input format

###


###

Import datavore

Import datavore chart

Take the input as datavore json object
	-Call datavore
	-Get response as json object (need to understand json object)
	-Pull parameters out from json object and put variables in some array to be modified

Start with simple line chart
-Sample line chart code for reference
 1 nv.addGraph(function() {  
 2   var chart = nv.models.lineChart();
 3 
 4   chart.xAxis
 5       .axisLabel('Time (ms)')
 6       .tickFormat(d3.format(',r'));
 7 
 8   chart.yAxis
 9       .axisLabel('Voltage (v)')
10       .tickFormat(d3.format('.02f'));
11 
12   d3.select('#chart svg')
13       .datum(sinAndCos())
14     .transition().duration(500)
15       .call(chart);
16 
17   nv.utils.windowResize(function() { d3.select('#chart svg').call(chart) });
18 
19   return chart;
20 });
21 
22 
23 
24 
28 
29 
30 function sinAndCos() {
31   var sin = [],
32       cos = [];
33 
34   for (var i = 0; i < 100; i++) {
35     sin.push({x: i, y: Math.sin(i/10)});
36     cos.push({x: i, y: .5 * Math.cos(i/10)});
37   }
38 
39   return [
40     {
41       values: sin,
42       key: 'Sine Wave',
43       color: '#ff7f0e'
44     },
45     {
46       values: cos,
47       key: 'Cosine Wave',
48       color: '#2ca02c'
49     }
50   ];
51 }

###

###
function to extract the data from datavore



different function for each type of graph
###