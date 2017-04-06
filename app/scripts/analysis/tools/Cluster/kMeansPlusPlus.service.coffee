'use strict'

initialize: ->

# Select a random point

initCentroids: (data, k) ->
    nRows = data.length
    centroids = []
    ctrIdx = Math.floor(Math.random() * nRows)
    centroids.push
        val: data[ctrIdx]
        idx: ctrIdx
    centroids
    # For each data point x, compute D(x)

    var distances = [];

for (i = 0, len = data.length; i < len; i++) {
  row = data[i];
  distances[i] = this.metrics.distance(row, centroids.val, distanceType);
}
    
  
  

 
 function getRandom(){
	for (var j = 0, len1 = data.length; j < len1; j++) {
      row = data[j];
      results.push(this.metrics.distance(row, centroids.val, 'euclidean'));
    }
     return results;
    #distance
      for (i = 0, len = result.length; i < len; i++) {
 			var sum = 0;
  		sum = sum + result[i]
  	}
  # sum of distance
    var potential;
    for (var i = 0, len = result.length; i < len; i++){
    potential[i] = result.length/sum
  }
 #potential of each points
    var num = Math.random(),
    var s = 0,
    var lastIndex = result.length - 1;

    for (i = 0; i < lastIndex; i++) {
        sum += potential[i];
        if (num < s) {
            return potential[i];
        }
    }
  return results[lastIndex];
};
  
  
