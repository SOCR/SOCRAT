
//A six-sided die
function Die(canvas){
  //Properties
  this.value;
  this.backColor = "red";
  this.spotColor = "white";
  this.prob = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6];
  //Local variables
  var ctx = canvas.getContext("2d");
  var size = canvas.width;
  var r = Math.round(size / 9);   //Spot radius
  var s = Math.round(size / 12);  //Space
  var d1 = s + r;         //First position
  var d2 = 2 * s + 3 * r;     //Seccond position;
  var d3 = 3 * s + 5 * r;     //Third positon
  
  //Methods
  this.setValue = function(v) {
    this.value = v;
    if (v == 0) ctx.fillStyle = "rgb(100,100,100)";
    else if (v > 0) ctx.fillStyle = this.backColor;
    else ctx.fillStyle = "rgba(200, 200, 200, 1)";
    ctx.fillRect(0, 0, size, size);
    ctx.fillStyle = this.spotColor;
    ctx.beginPath();
    switch(v){
    case 1:
      ctx.arc(d2, d2, r, 0, 2 * Math.PI, true);
      ctx.fill();
      break;
    case 2:
      ctx.arc(d1, d1, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d3, r, 0, 2 * Math.PI, true);
      ctx.fill();
      break;
    case 3:
      ctx.arc(d1, d1, r, 0, 2 * Math.PI, true);
      ctx.arc(d2, d2, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d3, r, 0, 2 * Math.PI, true);
      ctx.fill();
      break;
    case 4:
      ctx.beginPath();
      ctx.arc(d1, d1, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d1, r, 0, 2 * Math.PI, true);
      ctx.fill(); ctx.beginPath();
      ctx.arc(d1, d3, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d3, r, 0, 2 * Math.PI, true);
      ctx.fill();
      break;
    case 5:
      ctx.arc(d1, d1, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d1, r, 0, 2 * Math.PI, true);
      ctx.fill(); ctx.beginPath();
      ctx.arc(d1, d3, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d3, r, 0, 2 * Math.PI, true);
      ctx.fill(); ctx.beginPath();
      ctx.arc(d2, d2, r, 0, 2 * Math.PI, true);
      ctx.fill();
      break;
    case 6:
      ctx.arc(d1, d1, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d1, r, 0, 2 * Math.PI, true);
      ctx.fill(); ctx.beginPath();
      ctx.arc(d1, d3, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d3, r, 0, 2 * Math.PI, true);
      ctx.fill(); ctx.beginPath();
      ctx.arc(d1, d2, r, 0, 2 * Math.PI, true);
      ctx.arc(d3, d2, r, 0, 2 * Math.PI, true);
      ctx.fill();
      break;
    }
  }
  
  this.roll = function(){
    var p = Math.random(), sum = 0, x;
    for (var i = 0; i < 6; i++){
      if ((sum < p) && (p <= sum + this.prob[i])) x = i + 1;
      sum = sum + this.prob[i];
    }
    this.setValue(x);
  }
}

//A coin
function Coin(canvas){
  //Properties
  this.backColor;
  this.labelColor = "white";
  this.label = "";
  this.value; //1 heads, 0 tails, otherwise not tossed
  this.prob = 0.5
  //Local variables
  var ctx = canvas.getContext("2d");
  var size = canvas.width, r = size / 2;
  
  //Methods
  this.setValue = function(v) {
    ctx.clearRect(0, 0, size, size);
    this.value = v;
    if (this.value == 1){
      this.backColor = "red";
      this.label = "H";
    }
    else if (this.value == 0){
      this.backColor = "green";
      this.label = "T";
    }
    else if (this.value == -1){
      this.backColor = "rgb(100,100,100)";
      this.label = "";
    }
    else{
      this.backColor = "rgba(200, 200, 200, 1)";
      this.label = "";
    }
    ctx.fillStyle = this.backColor;
    ctx.beginPath();
    ctx.arc(r, r, r, 0, 2 * Math.PI, true);
    ctx.fill();
    ctx.fillStyle = this.labelColor;
    ctx.fillText(this.label, r - 5, r + 5);
  }
  
  this.toss = function(){
    var p = Math.random(), v;
    if (p <= this.prob) v = 1; else v = 0;
    this.setValue(v);
  }
}

//Ball
function Ball(canvas){
  //Properties
  this.ballColor = "red";
  this.labelColor = "white";
  this.value;
  //Local variables
  var ctx = canvas.getContext("2d");
  var size = canvas.width, r = size / 2;
  var label;
  //Methods
  this.setValue = function(v) {
    ctx.clearRect(0, 0, size, size);
    this.value = v;
    if (v >= 0){
      ctx.fillStyle = this.ballColor;
      label = v;
    }
    else if (v == -1){
      ctx.fillStyle = "rgb(100, 100, 100)";
      label = "";
    }
    else{
      ctx.fillStyle = "rgba(200, 200, 200, 1)";
      label = "";
    }
    ctx.beginPath();
    ctx.arc(r, r, r, 0, 2 * Math.PI, true);
    ctx.fill();
    ctx.fillStyle = this.labelColor;
    ctx.fillText(label, r - 5, r + 5);
  }
}
  

//A playing card
function Card(canvas){
  //Properties
  this.value;
  this.suit;
  this.suitSymbol;
  this.denomination;  
  var ctx = canvas.getContext("2d");
  var cardImages =  new Image(1027, 615);
  var width = 79, height = 123;
  var symbol = ["\u2663", "\u2666", "\u2665", "\u2660"];
  cardImages.src = "cards.png";
  ctx.fillStyle = "gray";

  cardImages.onload = function(){
    ctx.drawImage(cardImages, 2 * width, 4 * height, width, height, 0, 0, width, height);
  }
  
  this.setValue = function(x){
    this.value = Math.round(x);
    if (this.value > 0 && this.value < 53){
      this.suit = Math.ceil(this.value / 13);
      this.suitSymbol = symbol[this.suit - 1];
      this.denomination = this.value - 13 * (this.suit - 1);
      ctx.drawImage(cardImages, (this.denomination - 1) * width, (this.suit - 1) * height, width, height, 0, 0, width, height);
    }
    else if (this.value == 0) ctx.drawImage(cardImages, 2 * width, 4 * height, width, height, 0, 0, width, height);
    else ctx.clearRect(0, 0, width, height);
  }
}


//A basic graph
function graph(canvas, x0, x1, y0, y1){
  //Properties
  this.xMin = x0; this.xMax = x1; this.yMin = y0; this.yMax = y1;
  this.leftMargin = 30; this.rightMargin = 20; this.bottomMargin = 20; this.topMargin = 20;
  this.xFormat = 2; this.yFormat = 2;
  this.context = canvas.getContext("2d");
  //Local variables
  var ctx = canvas.getContext("2d");
  var width = canvas.width, height = canvas.height;

  this.clear = function(){
    ctx.clearRect(0, 0, width, height);
  }
  
  this.setMargins = function(lm, rm, bm, tm){
    this.leftMargin = lm; this.rightMargin = rm; this.bottomMargin = bm; this.topMargin = tm;
  }
  
  //This function returns the horizontal coordinate in cavnas units for a given x in scaled units
  this.xCanvas = function(x){
    return this.leftMargin + Math.round(((x - this.xMin)/(this.xMax - this.xMin)) * (width - this.leftMargin - this.rightMargin));
  }
  
  //This function returns the vertical coordinate in canvas units for a given y in scaled units
  this.yCanvas = function(y){
    return height - this.bottomMargin - Math.round(((y - this.yMin)/(this.yMax - this.yMin)) * (height - this.bottomMargin - this.topMargin));
  }
  
  //This function returns the horizontal coordinate in scaled units for a given x in canvas units.
  this.xScale = function(x){
    return this.xMin + ((x - this.leftMargin)/(width - this.leftMargin - this.rightMargin)) * (this.xMax - this.xMin);
  }
  
  //This funciton returns the vertical coordinate in scaled units for a given y in canvas units.
  this.yScale = function(y){
    return this.yMin + ((height - y - this.bottomMargin)/(height  - this.bottomMargin - this.topMargin)) * (this.yMax - this.yMin);
  }
  
  this.beginPath = function(){
    ctx.beginPath();
  }
  
  this.strokeStyle = function(c){
    ctx.strokeStyle = c;
  }
  
  this.stroke = function(){
    ctx.stroke();
  }

  this.moveTo = function(x, y){
    ctx.moveTo(this.xCanvas(x), this.yCanvas(y));
  }

  this.lineTo = function(x, y){
    ctx.lineTo(this.xCanvas(x), this.yCanvas(y));
  }

  this.drawLine = function(x0, y0, x1, y1){
    ctx.beginPath();
    ctx.moveTo(this.xCanvas(x0), this.yCanvas(y0));
    ctx.lineTo(this.xCanvas(x1), this.yCanvas(y1));
    ctx.stroke();
  }
  
  this.drawAxis = function(l, u, p, s, b){
    //l: lower bound, u: upper bound, p: position, s: step size, b: boolean (true horizontal)
    var x, y, k;
    var tickWidth = 3;
    ctx.beginPath();
    ctx.strokeStyle = "gray";
    ctx.fillStyle = "gray";
    ctx.lineWidth = 1;
    if (b){
      y = this.yCanvas(p);
      k = this.xFormat + 1;
      ctx.fillText(l.toFixed(this.xFormat), this.xCanvas(l) - 5 * k, y + 15);
      ctx.fillText(u.toFixed(this.xFormat), this.xCanvas(u) - 5 * k, y + 15);
      ctx.moveTo(this.xCanvas(l), y);
      ctx.lineTo(this.xCanvas(u), y);
      for (var t = l; t <= u; t = t + s){
        x = this.xCanvas(t);
        ctx.moveTo(x, y - tickWidth);
        ctx.lineTo(x, y + tickWidth);
      }
    }
    else {
      k = this.yFormat + 3;
      x = this.xCanvas(p);
      ctx.fillText(l.toFixed(this.yFormat), x - 5 * k, this.yCanvas(l) + 5);
      ctx.fillText(u.toFixed(this.yFormat), x - 5 * k, this.yCanvas(u) + 5);
      ctx.moveTo(x, this.yCanvas(l));
      ctx.lineTo(x, this.yCanvas(u));
      for (t = l; t <= u; t = t + s){
        y = this.yCanvas(t);
        ctx.moveTo(x - tickWidth, y);
        ctx.lineTo(x + tickWidth, y);
      }
    }
    ctx.stroke();
  }
  
  this.drawPoint = function(x, y, r, c){
    //(x, y): position in scale units, r: radius in pixels, c: color
    ctx.beginPath();
    ctx.fillStyle = c;
    ctx.arc(this.xCanvas(x), this.yCanvas(y), r, 0, 2 * Math.PI, true);
    ctx.fill();
  }
  
  this.fillCircle = function(x, y, r, c){
    ctx.beginPath();
    ctx.fillStyle = c;
    var x0 = this.xCanvas(x), y0 = this.yCanvas(y), r0 = this.xCanvas(x + r) - x0;
    ctx.arc(x0, y0, r0, 0, 2 * Math.PI, true);
    ctx.fill();
  }
    
  this.strokeCircle = function(x, y, r, c){
    ctx.beginPath();
    ctx.strokeStyle = c;
    var x0 = this.xCanvas(x), y0 = this.yCanvas(y), r0 = this.xCanvas(x + r) - x0;
    ctx.arc(x0, y0, r0, 0, 2 * Math.PI, true);
    ctx.stroke();
  }
  
  this.strokeRect = function(x0, y0, x1, y1, c){
    ctx.beginPath();
    ctx.strokeStyle = c;
    var x = this.xCanvas(x0), y = this.yCanvas(y0), w = this.xCanvas(x1) - x, h = this.yCanvas(y1) - y; 
    ctx.strokeRect(x, y, w, h);
  }
}

function DistributionGraph(canvas, dist, label){
  //Properties
  this.dist = dist; this.label = label;
  this.distColor = "blue"; this.dataColor = "rgba(255, 0, 0, 0.7)";
  this.xFormat = 0; this.xAxisFormat = 0; this.momentFormat = 3;
  this.yFormat = 3; this.yAxisFormat = 3;
  var leftMargin = 30, rightMargin = 20, topMargin = 20, bottomMargin = 30;
  var yMax = dist.maxDensity()
  //Local variables
  var moments = true, showDist = true;
  var data = this.dist.data;
  var ctx = canvas.getContext("2d");
  var width = canvas.width, height = canvas.height;
  var minValue = this.dist.minValue, maxValue = this.dist.maxValue, step = this.dist.step;
  var xMin = minValue - step / 2, xMax = maxValue + step / 2;
  var type = dist.type;
    
  //This function returns the horizontal coordinate in cavnas units for a given x in scaled units
  function xCanvas(x){
    return leftMargin + Math.round(((x - xMin)/(xMax - xMin)) * (width - leftMargin - rightMargin));
  }
  
  //This function returns the vertical coordinate in canvas units for a given y in scaled units
  function yCanvas(y){
    return height - bottomMargin - Math.round((y / yMax) * (height - bottomMargin - topMargin));
  }
  
  this.draw = function(){
    var xc, yc, x, y, xc1, y1, yc1, w, h, n;
    ctx.clearRect(0, 0, width, height);
    //Axes
    ctx.strokeStyle = "gray";
    ctx.fillStyle = "gray";
    //Horizontal axis
    ctx.beginPath();
    yc = yCanvas(0);
    ctx.moveTo(xCanvas(xMin), yc);
    ctx.lineTo(xCanvas(xMax), yc);
    for (x = minValue; x < maxValue + step / 2; x = x + step){
      xc = xCanvas(x);
      ctx.moveTo(xc, yc - 5);
      ctx.lineTo(xc, yc + 5);
    }
    ctx.stroke();
    n = this.xAxisFormat
    ctx.fillText(minValue.toFixed(n), xCanvas(minValue) - 3 * (n + 1), yc + 15);
    ctx.fillText(maxValue.toFixed(n), xCanvas(maxValue) - 3 * (n + 1), yc + 15);
    //Vertical axis
    n = this.yAxisFormat;
    ctx.beginPath();
    xc = xCanvas(xMin);
    yc = yCanvas(yMax);
    ctx.moveTo(xc, yCanvas(0));
    ctx.lineTo(xc, yc);
    ctx.moveTo(xc - 5, yc);
    ctx.lineTo(xc + 5, yc);
    ctx.stroke();
    ctx.fillText(0, xc - 10, yCanvas(0) + 5);
    ctx.fillText(yMax.toFixed(n), xc - 5 * (n + 3), yc + 5);
    //Distribution graph
    w = xCanvas(xMin + step) - xCanvas(xMin);   
    if (showDist){
      ctx.strokeStyle = this.distColor;
      if (type == 0){
        for (x = minValue; x < maxValue + step / 2; x = x + step){
          y = this.dist.density(x);
          xc = xCanvas(x - step / 2);
          yc = yCanvas(y); 
          h = yCanvas(0) - yc;
          ctx.strokeRect(xc, yc, w, h);
        }
      }
      else if (type == 1){
        ctx.beginPath();
        x = minValue;
        y = this.dist.density(x);
        xc = xCanvas(x);
        yc = yCanvas(y);
        ctx.moveTo(xc, yc);
        for (x = minValue; x < maxValue; x = x + step){
          y = this.dist.density(x);
          x1 = x + step;
          y1 = this.dist.density(x1);
          xc = xCanvas(x);
          xc1 = xCanvas(x1)
          yc1 = yCanvas(y1);
          ctx.lineTo(xc1, yc1);
        }
        ctx.stroke();
      }
    }
    //Data graph
    ctx.fillStyle = this.dataColor;
    if (data.getSize() > 0){
      for (x = minValue; x < maxValue + step / 2; x = x + step){
        if (type == 0) y = data.relFreq(x);
        else if (type == 1) y = data.density(x);
        xc = xCanvas(x - step / 2);
        yc = yCanvas(y); 
        h = yCanvas(0) - yc;
        ctx.fillRect(xc, yc, w, h);
      }
    }
      
    //Moments
    if (moments){
      yc = height - 15;
      if (showDist){
        ctx.strokeStyle = this.distColor;
        xc = xCanvas(this.dist.mean() - this.dist.stdDev());
        w = xCanvas(this.dist.mean() + this.dist.stdDev()) - xc;
        ctx.strokeRect(xc, yc, w, 10);
        xc = xCanvas(this.dist.mean());
        ctx.beginPath();
        ctx.moveTo(xc, yc + 15);
        ctx.lineTo(xc, yc - 5);
        ctx.stroke();
      }
      if (data.getSize() > 1){
        ctx.strokeStyle = this.dataColor;
        xc = xCanvas(data.mean() - data.stdDev());
        w = xCanvas(data.mean() + data.stdDev()) - xc;
        ctx.fillRect(xc, yc, w, 10);
        xc = xCanvas(data.mean());
        ctx.beginPath();
        ctx.moveTo(xc, yc + 15);
        ctx.lineTo(xc, yc - 5);
        ctx.stroke();
      }
    }
    //Text
    this.text = label;
    if (showDist) this.text = this.text + "\tDist";
    this.text = this.text + "\tData";
    for (var x = minValue; x <= maxValue; x = x + step){
      this.text = this.text + "\n" + x.toFixed(this.xFormat);
      if (showDist) this.text = this.text + "\t" + dist.density(x).toFixed(this.yFormat);
      if (data.getSize() > 0){
        if (type == 0) y = data.relFreq(x);
        else y = data.density(x);
        this.text = this.text + "\t" + y.toFixed(this.yFormat);
      }
    }
    if (moments){
      this.text = this.text + "\nMean";
      if (showDist) this.text = this.text + "\t" + dist.mean().toFixed(this.momentFormat);
      if (data.getSize() > 0) this.text = this.text + "\t" + data.mean().toFixed(this.momentFormat);
      this.text = this.text + "\nSD";
      if (showDist) this.text = this.text + "\t" + dist.stdDev().toFixed(this.momentFormat);
      if (data.getSize() > 1) this.text = this.text + "\t" + data.stdDev().toFixed(this.momentFormat);
    }
  }
  
  this.showMoments = function(b){
    moments = b;
    if (moments) this.bottomMargin = 30;
    else this.bottomMargin = 20;
  }
  
  this.showDist = function(b){
    showDist = b;
    this.draw();
  }
}
    
function showCopyright(title){
  alert(title + "\n\n" + "Distributome Project (www.Distributome.org) developed with support from the National Science Foundation under grants DUE-1022560, DUE-1022636, DUE-1023115")
}

function QuantileGraph(canvas, dist, label){
  var distColor = "blue", dataColor = "rgba(255, 0, 0, 0.7)";
  var leftMargin = 30, rightMargin = 20, topMargin = 20, bottomMargin = 30;
  var ctx = canvas.getContext("2d");
  var width = canvas.width, height = canvas.height;
  var minValue = dist.minValue, maxValue = dist.maxValue, step = dist.step;
  var xMin = minValue - step / 2, xMax = maxValue + step / 2;
  var value = xMin, prob = 0;
  var xFormat = Math.max(Math.round(Math.log(1 / step) / Math.log(10)), 0);
  var yFormat = 3;
  var graphType = "pdf";
  var yMax = dist.maxDensity();
    
  //This function returns the horizontal coordinate in cavnas units for a given x in scaled units
  function xCanvas(x){
    return leftMargin + Math.round(((x - xMin)/(xMax - xMin)) * (width - leftMargin - rightMargin));
  }
  
  //This function returns the vertical coordinate in canvas units for a given y in scaled units
  function yCanvas(y){
    return height - bottomMargin - Math.round((y / yMax) * (height - bottomMargin - topMargin));
  }
  
  this.draw = function(){
    var xc, yc, x, y, xc1, y1, yc1, w, h, n;
    ctx.clearRect(0, 0, width, height);
    //Draw axes
    ctx.strokeStyle = "gray";
    ctx.fillStyle = "gray";
    //Horizontal axis
    ctx.beginPath();
    ctx.moveTo(xCanvas(xMin), yCanvas(0));
    ctx.lineTo(xCanvas(xMax), yCanvas(0));
    for (x = minValue; x < maxValue + step / 2; x = x + step){
      xc = xCanvas(x), yc = yCanvas(0);
      ctx.moveTo(xc, yc - 5);
      ctx.lineTo(xc, yc + 5);
    }
    ctx.stroke();
    ctx.fillText(minValue.toFixed(xFormat), xCanvas(minValue) - 3 * (xFormat + 1), yc + 15);
    ctx.fillText(maxValue.toFixed(xFormat), xCanvas(maxValue) - 3 * (xFormat + 1), yc + 15);
    //Vertical axis
    ctx.beginPath();
    xc = xCanvas(xMin);
    yc = yCanvas(yMax);
    ctx.moveTo(xc, yCanvas(0));
    ctx.lineTo(xc, yc);
    ctx.moveTo(xc - 5, yc);
    ctx.lineTo(xc + 5, yc);
    ctx.stroke();
    ctx.fillText(0, xc - 10, yCanvas(0) + 5);
    ctx.fillText(yMax.toFixed(yFormat), xc - 5 * (yFormat + 3), yc + 5);
    //Draw distribution graph
    ctx.strokeStyle = distColor;
    ctx.fillStyle = dataColor;
    w = xCanvas(xMin + step) - xCanvas(xMin);
    if (dist.type == 0){
      for (x = minValue; x < maxValue + step / 2; x = x + step){
        if (graphType == "cdf") y = dist.CDF(x); else y = dist.density(x);
        xc = xCanvas(x - step / 2);
        yc = yCanvas(y); 
        h = yCanvas(0) - yc;
        ctx.strokeRect(xc, yc, w, h);
      }
    }
    else{
      ctx.beginPath();
      x = minValue;
      if (graphType == "cdf") y = dist.CDF(x); else y = dist.density(x);
      ctx.moveTo(xCanvas(x), yCanvas(y));
      for (x = minValue; x < maxValue; x = x + step){
        x1 = x + step;
        if (graphType == "cdf") y1 = dist.CDF(x1); else y1 = dist.density(x1);
        ctx.lineTo(xCanvas(x1), yCanvas(y1));
      }
      ctx.stroke();
      ctx.beginPath();
      if (graphType == "cdf"){
        ctx.strokeStyle = dataColor;
        ctx.moveTo(xCanvas(minValue), yCanvas(dist.CDF(value)));
        ctx.lineTo(xCanvas(value), yCanvas(dist.CDF(value)));
        ctx.lineTo(xCanvas(value), yCanvas(0));
        ctx.stroke();
      }
      else{
        x = minValue;
        ctx.moveTo(xCanvas(x), yCanvas(0));
        y = dist.density(x);
        ctx.lineTo(xCanvas(x), yCanvas(y));
        for (x = minValue; x < value; x = x + step){
          x1 = x + step;
          y1 = dist.density(x1);
          ctx.lineTo(xCanvas(x1), yCanvas(y1));
        }
        ctx.lineTo(xCanvas(x), yCanvas(0))
        ctx.fill();
      }
    }
  }

  this.setValue = function(x){
    value = x;
    prob = dist.CDF(x);
    this.draw();
  }

  this.setProb = function(p){
    prob = p;
    value = dist.quantile(p);
    this.draw();
  }

  this.setXFormat = function(n){
    xFormat = n;
    this.draw();
  }

  this.setYFormat = function(n){
    yFormat = n;
    this.draw();
  }

  this.setColors = function(c1, c2){
    distColor = c1;
    dataColor = c2;
    this.draw();
  }

  this.setMargins = function(l, r, t, b){
    leftMargin = l;
    rightMargin = r;
    topMargin = t;
    bottomMargin = b;
    this.draw();
  }

  this.setGraphType = function(t){
    graphType = t;
    if (graphType == "cdf") yMax = 1
    else yMax = dist.maxDensity();
    this.draw();
  }
}

function Parameter(input, label){
  var min, max, step, value, symbol, format;
  
  this.setProperties = function(mn, mx, st, v, sy){
    min = mn; max = mx; step = st; symbol = sy;
    input.min = min;
    input.max = max;
    input.step = step;
    format = Math.round(Math.log(1 / step) / Math.log(10));
    this.setValue(v);
  }
  
  this.setValue = function(x){
    if (min <= x && x <= max){
      var n = Math.round((x - min) / step);
      value = min + n * step;
    }
    else if (x < min) value = min;
    else if (x > max) value = max;
    input.value = value.toFixed(format);
    if (input.type == "range") label.innerHTML = "<var>" + symbol + "</var> = " + value.toFixed(format);
    else if (input.type == "hidden") label.innerHTML = "";
    else label.innerHTML = "<var>" + symbol + "</var> = ";
  }
  
  this.getValue = function(){
    this.setValue(Number(input.value));
    return value;
  }
  
  this.setType = function(t){
    input.type = t;
    this.setValue(Number(input.value));
  }
}

function Timeline(canvas, min, max, step){
  var ctx = canvas.getContext("2d");
  var width = canvas.width, height = canvas.height;
  var arrival = new Array(0);
  var color = new Array(0);
  var n = 0;
  var r = 2;
  var currentTime = min;
  var leftMargin = 10, rightMargin = 10;
  var xFormat = Math.max(Math.round(Math.log(1 / step) / Math.log(10)), 0);
  
  
  this.addArrival = function(t, c){
    n++;
    arrival.length = n;
    arrival[n - 1] = t;
    color.length = n;
    color[n - 1] = c;
  }
  
  this.reset = function(){
    n = 0;
    arrival.length = 0;
    color.length = 0;
  }
  
  function xCanvas(x){
    return leftMargin + Math.round(((x - min)/(max - min)) * (width - leftMargin - rightMargin));
  }
  
  this.draw = function(t){
    if (t > max) t = max;
    var y = height / 2;
    ctx.clearRect(0, 0, width, height);
    //Axis
    ctx.strokeStyle = "gray";
    ctx.fillStyle = "gray";
    ctx.beginPath();
    ctx.moveTo(xCanvas(min), y);
    ctx.lineTo(xCanvas(max), y);
    for (var x = min; x <= max; x = x + step){
      xc = xCanvas(x);
      ctx.moveTo(xc, y - 5);
      ctx.lineTo(xc, y + 5);
    }
    ctx.stroke();
    ctx.fillText(min.toFixed(xFormat), xCanvas(min) - 3 * (xFormat + 1), y + 15);
    ctx.fillText(max.toFixed(xFormat), xCanvas(max) - 3 * (xFormat + 1), y + 15);
    //Arrivals
    for (var i = 0; i < n; i++){
      if (arrival[i] <= t){
        ctx.beginPath();
        ctx.fillStyle = color[i];
        ctx.arc(xCanvas(arrival[i]), y, r, 0, 2 * Math.PI, true);
        ctx.fill();
      }
    }
    //current time
    ctx.beginPath();
    ctx.strokeStyle = "blue";
    var x = xCanvas(t);
    ctx.moveTo(x, y - 10);
    ctx.lineTo(x, y + 10);
    ctx.stroke();
  }
  
  this.setPointSize = function(s){
    r = s;
  }
  
  this.setXFormat = function(n){
    xFormat = n;
  }
  
  this.setMargins = function(l, r){
    leftMargin = l;
    rightMargin = r;
  }
}
    
//Galton Board
function GaltonBoard(canvas, n){
  var ctx = canvas.getContext("2d");
  var w = canvas.width, h = canvas.height;
  var lm = 30, rm = 20, bm = 20, tm = 20;
  var x, y, r = 2;
  var xMin = -1/2, xMax = n + 1/2, yMin = 0, yMax = n/2;
  
  this.setMargins = function(l, r, t, b){
    lm = l; rm = r; tm = t; bm = b;
  }
  
  this.setRadius = function(t){
    r = t;
  }
  
  function xCanvas(x){
    return  lm + Math.round(((x - xMin)/(xMax - xMin)) * (w - lm - rm))
  }
  
  function yCanvas(y){
    return h - bm - Math.round(((y - yMin)/(yMax - yMin)) * (h - bm - tm));
  }
  
  this.reset = function(){
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = "blue";
    ctx.beginPath();
    for (y = 0; y <= n / 2; y = y + 1/2) 
    for (x = y; x <= n - y; x++) ctx.arc(xCanvas(x), yCanvas(y), r, 0, 2 * Math.PI, true);
    ctx.fill();
    x = n/2; y = n/2;
    ctx.fillStyle = "red";
    ctx.beginPath();
    ctx.arc(xCanvas(x), yCanvas(y) - 2 * r, r, 0, 2 * Math.PI, true);
    ctx.fill();
    
  }
  
  this.setPath = function(p){
    ctx.fillStyle = "red";
    ctx.beginPath();
    ctx.arc(xCanvas(x), yCanvas(y) - 2 * r, r, 0, 2 * Math.PI, true);
    for (var i = 0; i < n; i++){
      y = y - 1/2;
      x = x - 1/2 + p[i];
      ctx.arc(xCanvas(x), yCanvas(y) - 2 * r, r, 0, 2 * Math.PI, true);
    }
    ctx.fill();
  }
  
  this.move = function(j){
    x = x - 1/2 + j;
    y = y - 1/2;
    ctx.beginPath();
    ctx.arc(xCanvas(x), yCanvas(y) - 2 * r, r, 0, 2 * Math.PI, true);
    ctx.fill();
  }
  
}

//Functions to use when sorting
function ascend(a, b){
  return a - b;
}

function descend(a, b){
  return b - a;
}

//The falling power function that gives the number of permutations of k objects chosen from n objects.
function perm(n, k){
  var product = 1;
  for (i = 0; i < k; i++) product = product * (n - i);
  return product;
}

//The factorial function that gives the number of permutations of n objects
function factorial(n){
  return perm(n, n);
}

//The binomial coefficient that gives the number of combinations of k objects chosen from n objects
function binomial(n, k){
  return perm(n, k) / factorial(k);
}

//This function gets a sample of a given size from a given population
function sample(p, n, type){
  var m = p.length; //population size
  var t, k, u;
  var s = new Array(n);
  if (type == 1){
    for (var i = 0; i < n; i++){
      u = Math.floor(m * Math.random());
      s[i] = p[u];
    }
  }
  else{
    for (var i = 0; i < n; i++){
      //Select a random index from 0 to m - i - 1;
      k = m - i;
      u = Math.floor(k * Math.random());
      //Define the sample element
      s[i] = p[u];
      //Interchange the sampled element p[u] with p[k - 1], at the end of the population so that it will not be sampled again.
      t = p[k - 1];
      p[k - 1] = p[u];
      p[u] = t;
    }
  }
  return s;
}

//log gamma function
function logGamma(x){
  var coef = [76.18009173, -86.50532033, 24.01409822, -1.231739516, 0.00120858003, -0.00000536382];
  var step = 2.50662827465, fpf = 5.5, t, tmp, ser;
  t = x - 1;
  tmp = t + fpf;
  tmp = (t + 0.5) * Math.log(tmp) - tmp;
  ser = 1;
  for (var i = 1; i <= 6; i++){
    t = t + 1;
    ser = ser + coef[i - 1] / t;
  }
  return tmp + Math.log(step * ser);
}

function gamma(x){
  return Math.exp(logGamma(x));
}

//Gamma series function
function gammaSeries(x, a){
  //Constants
  var maxit = 100, eps = 0.0000003;
  //Variables
  var sum = 1 / a, ap = a, gln = logGamma(a), del = sum;
  for (var n = 1; n <= maxit; n++){
    ap++;
    del = del * x / ap;
    sum = sum + del;
    if (Math.abs(del) < Math.abs(sum) * eps) break;
  }
  return sum * Math.exp(-x + a * Math.log(x) - gln);
}

//Gamma continued fraction function
function gammaCF(x, a){
  //Constants
  maxit = 100, eps = 0.0000003;
  //Variables
  var gln = logGamma(a), g = 0, gOld = 0, a0 = 1, a1 = x, b0 = 0, b1 = 1, fac = 1;
  var an, ana, anf;
  for (var n = 1; n <= maxit; n++){
    an = 1.0 * n;
    ana = an - a;
    a0 = (a1 + a0 * ana) * fac;
    b0 = (b1 + b0 * ana) * fac;
    anf = an * fac;
    a1 = x * a0 + anf * a1;
    b1 = x * b0 + anf * b1;
    if (a1 != 0){
      fac = 1.0 / a1;
      g = b1 * fac;
      if (Math.abs((g - gOld) / g) < eps) break;
      gOld = g;
    }
  }
  return Math.exp(-x + a * Math.log(x) - gln) * g;
}

//Gamma cdf with shape parameter a and scale parameter 1
function gammaCDF(x, a){
  if (x <= 0) return 0;
  else if (x < a + 1) return gammaSeries(x, a);
  else return 1 - gammaCF(x, a);
}

//Beta continued fraction function
  function betaCF(x, a, b){
  var maxit = 100, eps = 0.0000003, am = 1, bm = 1, az = 1, qab = a + b, qap = a + 1, qam = a - 1, bz = 1 - qab * x / qap, tem, em, d, bpp, bp, app, aOld, ap;
  for (var m = 1; m <= maxit; m++){
    em = m;
    tem = em + em;
    d = em * (b - m) * x / ((qam + tem) * (a + tem));
    ap = az + d * am;
    bp = bz + d * bm;
    d = -(a + em) *(qab + em) * x / ((a + tem) * (qap + tem));
    app = ap + d * az;
    bpp = bp + d * bz;
    aOld = az;
    am = ap / bpp;
    bm = bp / bpp;
    az = app / bpp;
    bz = 1;
    if (Math.abs(az - aOld) < eps * Math.abs(az)) break;
  }
  return az;
}

function betaCDF(x, a, b){
  var bt;
  if ((x == 0) | (x == 1)) bt = 0;
  else bt = Math.exp(logGamma(a + b) - logGamma(a) - logGamma(b) + a * Math.log(x) + b * Math.log(1 - x));
  if (x < (a + 1) / (a + b + 2)) return bt * betaCF(x, a, b) / a;
  else return 1 - bt * betaCF(1 - x, b, a) / b;
}

//This object models a data distribution
function Data(a, b, s){
  this.lowerValue = a;
  this.upperValue = b;
  this.step = s;
  var size = 0, value, sum = 0, sumSquares = 0, mode, minValue, maxValue;
  var n = Math.round((this.upperValue - this.lowerValue) / this.step) + 1;
  var freq = new Array(n);
  for(i = 0; i < n; i++) freq[i] = 0;
  
  this.setValue = function(x){
    size++;
    sum = sum + x;
    sumSquares = sumSquares + x * x;
    if (x < minValue) minValue = x;
    if (x > maxValue) maxValue = x;
    freq[this.index(x)]++;
  }
  
  this.index = function(x){
    return Math.round((x - this.lowerValue) / this.step);
  }
  
  this.mean = function(){
    return sum / size;
  }
  
  this.variance = function(){
    return sumSquares / (size - 1) - sum * sum /(size * (size - 1));
  }
  
  this.stdDev = function(){
    return Math.sqrt(this.variance());
  }
  
  this.getFreq = function(x){
    return freq[this.index(x)];
  }
  
  this.relFreq = function(x){
    return freq[this.index(x)] / size;
  }
  
  this.density = function(x){
    return this.getFreq(x) / (size * this.step);
  }
  
  this.getSize = function(){
    return size;
  }
  
  this.reset = function(){
    sum = 0; sumSquares = 0; size = 0;
    minValue = this.upperValue; maxValue = this.lowerValue;
    for(i = 0; i < n; i++) freq[i] = 0;
  }
}

//Generic probability distribution
function Distribution(){
  this.minValue = 1;
  this.maxValue = 6;
  this.step = 1;
  this.type = 0;
  this.data = new Data(this.minValue, this.maxValue, this.step);
    
  this.maxDensity = function(){
    var d = 0;
    for (var x = this.minValue; x <= this.maxValue; x = x + this.step) if (this.density(x) > d) d = this.density(x);
    return d;
  }
  
  this.density = function(x){
    return 1 / 6;
  }
  
  this.CDF = function(y){
    var p = 0, dx;
    if (this.type == 0) dx = 1; else dx = this.step;
    for (var x = this.minValue; x <= y; x = x + this.step) p = p + this.density(x) * dx;
    return p;
  }
  
  this.quantile = function(p){
    var x, x1, x2, error, q, n, i;
    if (p <= 0) return this.minValue;
    else if (p >= 1) return this.maxValue;
    else{
      x1 = this.minValue; x2 = this.maxValue;
      x = (x1 + x2) / 2;
      q = this.CDF(x);
      error = Math.abs(q - p);
      n = 1;
      while (error > 0.0001 && n < 100){
        n++;
        if (q < p) x1 = x; else x2 = x;
        x = (x1 + x2) / 2;
        q = this.CDF(x);
        error = Math.abs(q - p);
      }
      return x;
    }
  }
  
  this.mean = function(){
    var m = 0, dx;
    if (this.type == 0) dx = 1; else dx = this.step;
    for (var x = this.minValue; x <= this.maxValue; x = x + this.step) m = m + x * this.density(x) * dx;
    return m;
  }
  
  this.variance = function(){
    var m = this.mean(), m2 = 0, dx;
    if (this.type == 0) dx = 1; else dx = this.step;
    for (var x = this.minValue; x <= this.maxValue; x = x + this.step) m2 = m2 + x * x * this.density(x) * dx;
    return m2 - m * m;
  }
    
  this.stdDev = function(){
    return Math.sqrt(this.variance());
  }
  
  this.simulate = function(){
    var x = this.quantile(Math.random());
    this.setValue(x);
    return x;
  }   
  
  this.setValue = function(x){
    this.data.setValue(x);
  } 
  
}
  
//The binomial distribution
function BinomialDistribution(trials, prob){
  //Properties
  this.prob = prob;
  this.trials = trials;
  this.type = 0;
  this.minValue = 0;
  this.maxValue = this.trials;
  this.step = 1;
  this.data = new Data(0, this.trials, this.step);
  
  //Methods
  this.density = function(x){
    var k = Math.round(x);
    return binomial(this.trials, k) * Math.pow(this.prob, k) * Math.pow(1 - this.prob, this.trials - k);
  }
  
  this.mode = function(){
    if (prob == 1) return this.trials;
    else return Math.floor((this.trials + 1) * prob);
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
    
  this.mean = function(){
    return this.trials * this.prob;
  }
  
  this.variance = function(){
    return this.trials * this.prob * (1 - this.prob);
  }
    
  this.simulate = function(){
    var successes = 0;
    for (var i = 1; i <= this.trials; i++){
      if (Math.random() < this.prob) successes++;
    }
    this.setValue(successes);
    return successes;
  }
}
BinomialDistribution.prototype = new Distribution;
  
//The location scale distribution associated with a given distribution, location parameter a, scale parameter b

function LocationScaleDistribution(dist, location, scale){
  //Properties
  this.dist = dist;
  this.location = location;
  this.scale = scale;
  this.minValue = this.location + this.scale * this.dist.minValue;
  this.maxValue = this.location + this.scale * this.dist.maxValue;
  this.step = this.scale * this.dist.step;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  this.type = this.dist.type;
  
  //Methods
  this.density = function(x){
    var y = this.dist.minValue + Math.round((x - this.minValue) / this.step) * this.dist.step;
    if (this.type == 0) return this.dist.density(y);
    else return this.dist.density(y) / this.scale;
  }
  
  this.mode = function(){
    return this.location + this.scale * this.dist.mode;
  }
  
  this.maxDensity = function(){
    if (this.type == 0) return this.dist.maxDensity();
    else return this.dist.maxDensity() / this.scale;
  }
    
  this.mean = function(){
    return this.location + this.scale * this.dist.mean();
  }
  
  this.variance = function(){
    return this.scale * this.scale * this.dist.variance();
  }
    
  this.simulate = function(){
    var x = this.location + this.scale * this.dist.simulate();
    this.setValue(x);
    return x;
  } 
}

LocationScaleDistribution.prototype = new Distribution;


//Convolution power of a distribution
function Convolution(d, n){
  //Properties
  this.dist = d;
  this.power = n;
  this.minValue = this.power * this.dist.minValue;
  this.maxValue = this.power * this.dist.maxValue;
  this.step = this.dist.step;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  this.type = this.dist.type;
  
  //Compute and cache the convolution pdf
  var a = this.dist.minValue, b = this.dist.maxValue, s = this.dist.step;
  var m = Math.round((b - a) / s) + 1;
  var delta = 1;
  if (this.type == 1) delta = this.step;
  var pdf = new Array(this.power);
  for (var k = 0; k < n; k++) pdf[k] = new Array((k + 1) * m - k);
  for (var j = 0; j < m; j++) pdf[0][j] = this.dist.density(a + j * s);
  for (var k = 1; k < n; k++){
    for (var j = 0; j < (k + 1) * m - k; j++){
      var sum = 0;
      for (var i = Math.max(0, j - m + 1); i < Math.min(j + 1, k * m - k + 1); i++) sum = sum + pdf[k - 1][i] * pdf[0][j - i] * delta;
      pdf[k][j] = sum;
    }
  }
  
  //Methods
  this.density = function(x){
    var index = Math.round((x - this.minValue) / this.step);
    return pdf[this.power - 1][index];
  }
      
  this.mean = function(){
    return this.power * this.dist.mean();
  }
  
  this.variance = function(){
    return this.power * this.dist.variance();
  }
    
  this.simulate = function(){
    var sum = 0;
    for (i = 1; i <= this.power; i++) sum = sum + this.dist.simulate();
    this.setValue(sum);
    return sum;
  }
}

Convolution.prototype = new Distribution;

//Distribution of an order statistic from a given distribution
function OrderStatistic(dist, sample, order){
  //Properties
  this.dist = dist;
  this.sample = sample;
  this.order = order; 
  this.type = this.dist.type;
  this.minValue = this.dist.minValue;
  this.maxValue = this.dist.maxValue;
  this.step = this.dist.step;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  //Methods
  this.density =  function(x){
    if (this.type == 0) return this.CDF(x) - this.CDF(x - this.step);
    else {
      var p = this.CDF(x);
      return this.order * binomial(this.sample, this.order) * Math.pow(p, this.order - 1) * Math.pow(1 - p, this.sample - this.order) * this.dist.density(x);
    }
  }
    
  this.CDF = function(x){
    var sum = 0, p = this.dist.CDF(x);
    for (var j = this.order; j <= this.sample; j++) sum = sum + binomial(this.sample, j) * Math.pow(p, j) * Math.pow(1 - p, this.sample - j);
    return sum;
  }
  
      
  this.simulate = function(){
    sampleValues = new Array(this.sample);
    orderStats = new Array(this.sample);
    for (var i = 0; i < this.sample; i++) sampleValues[i] = this.dist.simulate();
    orderStats = sampleValues.sort(ascend);
    var x = orderStats[order - 1];
    this.setValue(x);
    return x;
  }
}

OrderStatistic.prototype = new Distribution;

//This binomial distribution with the number of trials randomized
function BinomialNDistribution(dist, prob){
  //Properties
  this.dist = dist;
  this.prob = prob;
  this.minValue = 0;
  this.maxValue = this.dist.maxValue;
  this.step = 1;
  this.type = 0;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  //Methods
  this.density = function(x){
    var sum = 0;
    for (var n = x; n <= this.maxValue; n = n + this.dist.step) sum = sum + this.dist.density(n) * binomial(n, x) * Math.pow(this.prob, x) * Math.pow(1 - this.prob, n - x);
    return sum;
  }
    
  this.mean = function(){
    return this.dist.mean() * this.prob;
  }
  
  this.variance = function(){
    return this.dist.mean() * this.prob * (1 - this.prob) + this.prob * this.prob * this.dist.variance();
  }
    
  this.simulate = function(){
    var trials = Math.round(this.dist.simulate());
    var successes = 0;
    for (var i = 0; i <= trials; i++) if (Math.random() <= this.prob) successes++;
    this.setValue(successes);
    return successes;
  }
}

BinomialNDistribution.prototype = new Distribution;

//A generic discrete distribution
function DiscreteDistribution(a, b, s, p){
  //Properties
  this.prob = p;
  this.minValue = a;
  this.maxValue = b;
  this.step = s;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  this.type = 0;
  
  //Methods
  this.density = function(x){
    if (x > this.maxValue || x < this.minValue) return 0;
    else{
      var k = Math.round((x - this.minValue) / this.step);
      return this.prob[k];
    }
  }
      
  this.simulate = function(){
    var p = Math.random(), sum = 0, y;
    for (var x = this.minValue; x <= this.maxValue; x++){
      if ((sum < p) && (p <= sum + this.density(x))) y = x;
      sum = sum + this.density(x);
    }
    this.setValue(y);
    return y;
  }
}

DiscreteDistribution.prototype = new Distribution;

//Negative binomial distribution
function NegativeBinomialDistribution(k, p){
  var mean = k / p, variance = k * (1 - p) / (p * p);
  var mode = Math.floor((k - 1) / p + 1);
  this.prob = p;
  this.successes = k;
  this.minValue = k;
  this.maxValue = mean + 4 * Math.sqrt(variance);
  this.step = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  this.type = 0;
  
  this.mode = function(){
    return mode;
  }
  
  this.maxDensity = function(){
    return this.density(mode);
  }
  
  this.density = function(x){
    var n = Math.round(x);
    return binomial(n - 1, k - 1) * Math.pow(p, k) * Math.pow(1 - p, n - k);
  }
    
  this.mean = function(){
    return mean;
  }
  
  this.variance = function(){
    return variance;
  }
    
  this.simulate = function(){
    var count = 0, trials = 0;
    while (count < successes){
      if (Math.random() < prob) count++;
      trials++;
    }
    this.setValue(trials);
    return trials;
  } 
}

NegativeBinomialDistribution.prototype = new Distribution;

//Normal distribution
function NormalDistribution(mu, sigma){
  this.mu = mu;
  this.sigma = sigma;
  this.minValue = mu - 4 * sigma;
  this.maxValue = mu + 4 * sigma;
  this.step = (this.maxValue - this.minValue) / 100;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  this.type = 1;
  var c = 1 / (sigma * Math.sqrt(2 * Math.PI));
  
  this.mode = function(){
    return mu;
  }
  
  this.maxDensity = function(){
    return c;
  }
  
  this.density = function(x){
    var z = (x - mu) / sigma;
    return c * Math.exp(-z * z / 2);
  }
  
  this.CDF = function(x){
    var z = (x - mu) / sigma;
    if (z >= 0) return 0.5 + 0.5 * gammaCDF(0.5 * z * z, 0.5);
    else return 0.5 - 0.5 * gammaCDF(0.5 * z * z, 0.5);
  } 
  
  this.simulate = function(){
    var r = Math.sqrt(-2 * Math.log(Math.random()));
    var theta = 2 * Math.PI * Math.random();
    var x = mu + sigma * r * Math.cos(theta);
    this.setValue(x); 
    return x;
  }
    
  this.mean = function(){
    return mu;
  }
  
  this.variance = function(){
    return sigma * sigma;
  }
  
  this.stdDev = function(){
    return sigma;
  }
}

NormalDistribution.prototype = new Distribution;

function GammaDistribution(shape, scale){
  this.shape = shape;
  this.scale = scale;
  if (shape >= 1) this.minValue = 0; else this.minValue = 0.01;
  var mean = shape * scale;
  var variance = shape * scale * scale;
  var stdDev = Math.sqrt(shape) * scale;
  var c = 1 / (gamma(shape) * Math.pow(scale, shape));
  this.maxValue = mean + 4 * stdDev;
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.mode = function(){
    if (shape < 1) return this.minValue;
    else return scale * (shape - 1);
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
  
  this.density = function(x){
    return c * Math.pow(x, shape - 1) * Math.exp(-x / scale);
  }
  
  this.CDF = function(x){
    return gammaCDF(x / scale, shape);
  }
    
  this.mean = function(){
    return mean;
  }
  
  this.variance = function(){
    return variance;
  }
  
  this.stdDev = function(){
    return stdDev;
  }
}

GammaDistribution.prototype = new Distribution; 

function ChiSquareDistribution(df){
  this.df = df;
  if (df == 1) this.minValue = 0.1;
  else this.minValue = 0;
  var c = 1 / (Math.pow(2, df / 2) * gamma(df / 2));
  this.maxValue = df + 4 * Math.sqrt(2 * df);
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.mode = function(){
    if (df < 2) return this.minValue;
    else return df - 2;
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
  
  this.density = function(x){
    return c * Math.pow(x, df / 2 - 1) * Math.exp(-x / 2);
  }

  this.CDF = function(x){
    return gammaCDF(x / 2, df / 2);
  }
      
  this.mean = function(){
    return df;
  }
  
  this.variance = function(){
    return 2 * df;
  }
      
  this.simulate = function(){
    var V, Z, r, theta;
    V = 0;
    for (var i = 1; i <= df; i++){
      r = Math.sqrt(-2 * Math.log(Math.random()));
      theta = 2 * Math.PI * Math.random();
      Z = r * Math.cos(theta);
      V = V + Z * Z;
    }
    this.setValue(V);
    return V;
  }
}

ChiSquareDistribution.prototype = new Distribution;

function StudentDistribution(df){
  this.df = df;
  var c = gamma((df + 1) / 2) / (Math.sqrt(df * Math.PI) * gamma(df / 2));
  if (df == 1){
    this.maxValue = 8;
    this.minValue = -8;
  }
  else if (df == 2){
    this.maxValue = 7;
    this.minValue = -7;
  }
  else{
    this.maxValue = 4 * Math.sqrt(df / (df - 2));
    this.minValue = -this.maxValue;
  }
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.mode = function(){
    return 0;
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
  
  this.density = function(x){
    return c * Math.pow(1 + x * x / df, -(df + 1) / 2);
  }

  this.CDF = function(x){
    var u = df / (df + x * x);
    if (x > 0) return 1 - 0.5 * betaCDF(u, 0.5 * df, 0.5);
    else return 0.5 * betaCDF(u, 0.5 * df, 0.5);
  }
    
  this.mean = function(){
    if (df == 1) return Number.NaN;
    else return 0;
  }
  
  this.variance = function(){
    if (df == 1) return Number.NaN;
    else if (df == 2) return Infinity;
    else return df / (df - 2);
  }
      
  this.simulate = function(){
    var x, v, z, r, theta;
    v = 0;
    for (var i = 1; i <= df; i++){
      r = Math.sqrt(-2 * Math.log(Math.random()));
      theta = 2 * Math.PI * Math.random();
      z = r * Math.cos(theta);
      v = v + z * z;
    }
    r = Math.sqrt(-2 * Math.log(Math.random()));
    theta = 2 * Math.PI * Math.random();
    z = r * Math.cos(theta);
    x = z / Math.sqrt(v / df);
    this.setValue(x);
    return x;
  }
}

StudentDistribution.prototype = new Distribution;

function FDistribution(n, d){
  this.n = n; this.d = d;
  var c = (gamma((n + d) / 2) / (gamma(n / 2) * gamma(d / 2))) * Math.pow(n / d, n / 2);
  if (d == 1) this.minValue = 0.1; else this.minValue = 0;
  if (d <= 4) this.maxValue = 20; else this.maxValue = d / (d - 2)  + 4 * Math.sqrt(2.0 * (d / (d - 2)) * (d / (d - 2)) * (d + n - 2) / (n * (d - 4)));
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.mode = function(){
    if (n <= 2) return this.minValue;
    else return ((n - 2) * d) / (n * (d + 2));
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
  
  this.density = function(x){
    return c * Math.pow(x, (n - 2) / 2) / Math.pow(1 + (n / d) * x, (n + d) / 2);

  }

  this.CDF = function(x){
    var u = d / (d + n * x);
    if (x < 0) return 0;
    else return 1 - betaCDF(u, 0.5 * d, 0.5 * n);
  }
    
  this.mean = function(){
    if (d <= 2) return Infinity;
    else return d / (d - 2);
  }
  
  this.variance = function(){
    if (d <= 2) return Number.NaN;
    else if (d <= 4) return Infinity;
    else return 2.0 * (d / (d - 2)) * (d / (d - 2)) * (d + n - 2) / (n * (d - 4));
  }
    
  this.simulate = function(){
    var x, U, V, Z, r, theta;
    U = 0;
    for (var i = 1; i <= n; i++){
      r = Math.sqrt(-2 * Math.log(Math.random()));
      theta = 2 * Math.PI * Math.random();
      Z = r * Math.cos(theta);
      U = U + Z * Z;
    }
    V = 0;
    for (var j = 1; j <= d; j++){
      r = Math.sqrt(-2 * Math.log(Math.random()));
      theta = 2 * Math.PI * Math.random();
      Z = r * Math.cos(theta);
      V = V + Z * Z;
    }
    x = (U / n) / (V / d);
    this.setValue(x);
    return x;
  } 
}

FDistribution.prototype = new Distribution;

function BetaDistribution(a, b){
  this.left = a;
  this.right = b;
  var c = gamma(a + b) / (gamma(a) * gamma(b));
  if (a < 1) this.minValue = 0.01; else this.minValue = 0;
  if (b < 1) this.maxValue = 0.99; else this.maxValue = 1;
  this.step = 0.01;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.mode = function(){
    var m;
    if (a < 1 && b < 1){
      if (a < b) m = 0.01; else m = 0.99;
    }
    else if (a < 1 && b >= 1) m = 0.01;
    else if (a >= 1 && b < 1) m = 0.99;
    else m = (a - 1) / (a + b - 2);
    return m;
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
  
  this.density = function(x){
    return c * Math.pow(x, a - 1) * Math.pow(1 - x, b - 1);
  }

  this.CDF = function(x){
    var bt;
    if ((x == 0) || (x == 1)) bt = 0;
    else bt = Math.exp(logGamma(a + b) - logGamma(a) - logGamma(b) + a * Math.log(x) + b * Math.log(1 - x));
    if (x < (a + 1) / (a + b + 2)) return bt * betaCF(x, a, b) / a;
    else return 1 - bt * betaCF(1 - x, b, a) / b;
  }
      
  this.mean = function(){
    return a / (a + b);
  }
  
  this.variance = function(){
    return a * b / ((a + b) * (a + b) * (a + b + 1));
  }
}

BetaDistribution.prototype = new Distribution;

function WeibullDistribution(k, b){
  var c = k / Math.pow(b, k);
  var mean = b * gamma(1 + 1 / k);
  var variance = b * b * gamma(1 + 2 / k) - mean * mean;
  this.minValue = 0;
  this.maxValue = mean + 4 * Math.sqrt(variance);
  this.step = this.maxValue / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);

  this.density = function(x){
    return c * Math.pow(x, k - 1) * Math.exp(-Math.pow(x / b, k));
  }
  
  this.maxDensity = function(x){
    var mode;
    if (k < 1) mode = this.minValue;
    else mode = b * Math.pow((k - 1) / k, 1 / k);
    return this.density(mode);
  }
  
  this.CDF = function(x){
    return 1 - Math.exp(-Math.pow(x / b, k));
  }
  
  this.quantile = function(p){
    return b * Math.pow(-Math.log(1 - p), 1 / k);
  }
    
  this.mean = function(){
    return mean;
  }
  
  this.variance = function(){
    return variance;
  }
}

WeibullDistribution.prototype = new Distribution;

function ParetoDistribution(k, b){
  var c = k * Math.pow(b, k);
  this.minValue = b;
  this.maxValue = b * (1 + 6 / k);
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);

  this.density = function(x){
    return c / Math.pow(x, k + 1);
  }
  
  this.maxDensity = function(x){
    return this.density(b);
  }
  
  this.CDF = function(x){
    return 1 - Math.pow(b / x, k);
  }
  
  this.quantile = function(p){
    return b / Math.pow((1 - p), 1 / k);
  }
    
  this.mean = function(){
    if (k <= 1) return Infinity;
    else return (k * b) / (k - 1);
  }
  
  this.variance = function(){
    if (k <= 1) return Number.NaN;
    else if (k > 1 && k <= 2) return Infinity;
    else return (k * b * b) / ((k - 1) * (k - 2) * (k - 2));
  }
}

ParetoDistribution.prototype = new Distribution;

function LogisticDistribution(a, b){
  var mean = a, variance = (b * b * Math.PI * Math.PI) / 3, stdDev = Math.sqrt(variance);
  this.minValue = mean - 4 * stdDev; 
  this.maxValue = mean + 4 * stdDev;
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.density = function(x){
    var e = Math.exp((x - a) / b);
    return e / (b * (1 + e) * (1 + e));
  }
  
  this.maxDensity = function(){
    return 1 / (4 * b);
  }
  
  this.CDF = function(x){
    var e = Math.exp((x - a) / b);
    return e / (1 + e);
  }
  
  this.quantile = function(p){
    return a + b * Math.log(p / (1 - p));
  }
  
  this.mean = function(){
    return mean;
  }
  
  this.variance = function(){
    return variance;
  }
}

LogisticDistribution.prototype = new Distribution;

function LogNormalDistribution(m, s){
  var mean = Math.exp(m + s * s / 2);
  var variance = Math.exp(2 * (m + s * s)) - Math.exp(2 * m + s * s);
  this.minValue = 0;
  this.maxValue = mean + 4 * Math.sqrt(variance);
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.density = function(x){
    if (x == 0) return 0; 
    else return Math.exp(-(Math.log(x) - m) * (Math.log(x) - m) / (2 * s * s)) / (Math.sqrt(2 * Math.PI) * s * x);
  }
  
  this.maxDensity = function(){
    var mode = Math.exp(m - s * s);
    return this.density(mode);
  }
  
  this.CDF = function(x){
    var z = (Math.log(x) - m) / s;
    if (z >= 0) return 0.5 + 0.5 * gammaCDF(0.5 * z * z, 0.5);
    else return 0.5 - 0.5 * gammaCDF(0.5 * z * z, 0.5);
  }
  
  this.mean = function(){
    return mean;
  }
  
  this.variance = function(){
    return variance;
  }
    
  this.simulate = function(){
    var r = Math.sqrt(-2 * Math.log(Math.random()));
    var theta = 2 * Math.PI * Math.random();
    var x = Math.exp(m + s * r * Math.cos(theta));
    this.setValue(x); 
    return x;
  } 
}

LogNormalDistribution.prototype = new Distribution;
  
function ExtremeValueDistribution(a, b){
  var g = 0.5772156649;
  var mean = a + b * g;
  var variance = (b * b * Math.PI * Math.PI) / 6;
  var stdDev = Math.sqrt(variance);
  this.minValue = mean - 4 * stdDev;
  this.maxValue = mean + 4 * stdDev;
  this.step = (this.maxValue - this.minValue) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.density = function(x){
    var e = Math.exp(-(x - a) / b);
    return e * Math.exp(-e) / b;
  }
  
  this.maxDensity = function(){
    return this.density(a);
  }
  
  this.CDF = function(x){
    return Math.exp(-Math.exp(-(x - a) / b));
  }
  
  this.quantile = function(p){
    return a - b * Math.log(-Math.log(p));
  }
  
  this.mean = function(){
    return mean;
  }
  
  this.variance = function(){
    return variance;
  }
}

ExtremeValueDistribution.prototype = new Distribution;

function PoissonDistribution(r){
  this.minValue = 0;
  this.maxValue = r + 4 * Math.sqrt(r);
  this.step = 1;
  this.type = 0;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.density = function(x){
    return Math.exp(-r) * Math.pow(r, x) / factorial(x);
  }
  
  this.mode = function(){
    return Math.floor(r);
  }
  
  this.maxDensity = function(){
    return this.density(this.mode());
  }
  
  this.CDF = function(x){
    return 1 - gammaCDF(r, x + 1);
  }
    
  this.mean = function(){
    return r;
  }
  
  this.variance = function(){
    return r;
  }
      
  this.simulate = function(){
    var arrivals = 0;
    var sum = -Math.log(1 - Math.random());
    while (sum <= r){
      arrivals++;
      sum = sum - Math.log(1 - Math.random());
    }
    this.setValue(arrivals);
    return arrivals;
  } 
}

PoissonDistribution.prototype = new Distribution;

function UniformDistribution(a, b){
  this.minValue = a;
  this.maxValue = b;
  this.step = (b - a) / 100;
  this.type = 1;
  this.data = new Data(this.minValue, this.maxValue, this.step);
  
  this.density = function(x){
    return 1 / (b - a);
  }
    
  this.maxDensity = function(){
    return 1 / (b - a);
  }
  
  this.CDF = function(x){
    return (x - a) / (b - a);
  }
  
  this.quantile = function(p){
    return a + p * (b - a);
  }
    
  this.mean = function(){
    return (a + b) / 2;
  }
  
  this.variance = function(){
    return (b - a) * (b - a) / 12;
  }
      
  this.simulate = function(){
    var x = a + b * Math.random();
    this.setValue(x);
    return x;
  } 
} 

UniformDistribution.prototype = new Distribution;