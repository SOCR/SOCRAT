###
JIRA COMMIT
Convert json returns to chart input format

###

colA = [1,2,3,4,5];
colB = [1,3,5,3,1];

tab1 = dv.table([
    {name:"A", values:colA, type:dv.type.numeric},
    {name:"B", values:colB, type:dv.type.numeric}
]);

chart = nv.models.lineChart();
lineRet = [];

i = 0;

while i < tab1[0].length
	lineRet.push({x: tab1[0][i], y: tab1[1][i]});
	i++;

retChart = [
  	values: lineRet
  	key: "lineChart"
  	color: "#ff7f0e"
]
###
ERROR: IF SAME DATA POINT OCCURS MORE THAN ONCE (https://github.com/novus/nvd3/issues/330)

Can i place chart in index.html from databridge.coffee
Are we given just the data to convert? (they deal with x-axis, y-axis and other stuff)
Better way to run loop?
	for each in tab1[0].length
	lineRet.push({x: tab1[0][each], y: tab1[1][each]});

What other charts?
###

###
Import datavore chart

Take the input as datavore json object
	-Call datavore
	-Get response as json object (need to understand json object)
	-Pull parameters out from json object and put variables in some array to be modified


###

###
function to extract the data from datavore



different function for each type of graph
###