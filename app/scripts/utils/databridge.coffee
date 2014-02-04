###

Convert json returns to chart input format

###

colA = [1,2,3,4,5];
colB = [1,3,5,3,1];

tab1 = dv.table([
    {name:"A", values:colA, type:dv.type.numeric},
    {name:"B", values:colB, type:dv.type.numeric}
]);

#Input type: line chart, scatter, cumulative line, discrete bar
#Data: tab1
#Create function

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
function (chart,label)->

# code to get data from datavore.
-------------------
colA = [1,2,3,4,5];
colB = [1,3,5,3,1];

tab1 = dv.table([
    {name:"A", values:colA, type:dv.type.numeric},
    {name:"B", values:colB, type:dv.type.numeric}
]);
-------------------
data = tab1

# generic computation

retobj = {}

mand = ['value','color','key']

case chart
    when "line"
        chart = nv.models.lineChart();
        i = 0;
        _color = "#eee"   
        _val = [] 
        _x = "we"
        retobj.push ("x":_x)

        while i < data[0].length
            _val.push({x: tab1[0][i], y: tab1[1][i]});
           i++;

         
    when "bubble"
        chart = nv.models.lineChart();
        _color = "#eee"
        
        
        

# 
for (i in mand)
    retobj.push (i:_val);



return retobj;
###

###
ERROR: IF SAME DATA POINT OCCURS MORE THAN ONCE (https://github.com/novus/nvd3/issues/330)

Are we given just the data to convert? (they deal with x-axis, y-axis and other stuff)

which graph, which data to use, project::fork 
given graph type, project::fork (gives data using this key)

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