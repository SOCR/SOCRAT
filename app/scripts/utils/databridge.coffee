###

Convert json returns to chart input format

###

#Input type: line chart (x values, y values), scatter (x value, y value, size), cumulative line (x value, y value), discrete bar ()
#Data: tab1
#Create function
#Date : http://stackoverflow.com/questions/19459687/understanding-nvd3-x-axis-date-format

databridge = angular.module "app_utils", []

databridge.factory "app_utils_databridge",[

 (chart,labels)->

  # code to get data from datavore.

  colA = [1,2,3,4,5]
  colB = [1,3,5,3,1]

  tab1 = dv.table([
    {name:"A", values:colA, type:dv.type.numeric},
    {name:"B", values:colB, type:dv.type.numeric}
  ])

  data = tab1

# charts to implement: https://github.com/mbostock/d3/wiki/Gallery#wiki-basic-charts

# generic computation

  retobj = []

  for i in numCharts
    retobj.push({
      key: labels[i]
      values: []
    })

  switch chart
    when "line"
      for i in numCharts
        for j in data[2*i].length
          retobj[i].values.push(
            [data[2*i][j], data[2*i + 1][j]]
          )
      #Javascript required ({x: val,y: val})
       
    when "cumulative"
      for i in numCharts
        for j in data[2*i].length
          retobj[i].values.push(
            [data[2*i][j], data[2*i + 1][j]]
          )

    when "scatter"
      for i in numCharts
        for j in data[3*i].length
          retobj[i].values.push({
            x: data[3*i]
            y: data[3*i + 1]
            size: data[3*i + 2]
          })

    when "area"
        for i in numCharts
            for j in data[3*i].length
                retobj[i].values.push({
                    x: data[3*i]
                    y: data[3*i + 1]
                    area: data[3*i + 2]
                })
    
    when "stackedbar"
        for i in numCharts
            for j in data[2*i].length
                retobj[i].values.push(
                    [data[2*i][j], data[2*i + 1][j]]
                )
  return retobj;
]

###
ERROR: IF SAME DATA POINT OCCURS MORE THAN ONCE (https://github.com/novus/nvd3/issues/330)

which graph, which data to use, project::fork
given graph type, project::fork (gives data using this key)
###

###
function to extract the data from datavore

different function for each type of graph
###

