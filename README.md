## SOCRAT: [SOCR](http://socr.umich.edu) Analytics Toolbox

A scalable and highly flexible HTML5/JS platform to build and run in-browser applications for interactive data analysis and visualization.

* Web site: http://socr.umich.edu
* Issue-tracking and project management: https://socredu.atlassian.net/browse/SOCRFW
* **Note: project is under active development, unit tests currently are not passing, bugs are possible**

[![Build Status](https://travis-ci.org/SOCR/SOCRAT.svg?branch=master)](https://travis-ci.org/SOCR/SOCRAT)
[![Dependency Status](https://gemnasium.com/SOCR/SOCRAT.png?branch=master)](https://gemnasium.com/SOCR/SOCRAT)

Installation
------------
In case you wish to create your own module or contribute to the project, follow these steps to setup your environment.

First, install [Node.js](http://nodejs.org/) if you haven't yet. `npm` is the package manager for `Node.js` and comes bundled with it.

Install Webpack:

    $> sudo npm install webpack -g

Clone the repository:

    $> git clone https://github.com/SOCR/SOCRAT.git
    $> cd SOCRAT
    
If you're interested in latest changes or want to contribute to the project, switch to the `dev` branch:

    $> git checkout dev
    $> git pull

Now, lets install all the dependencies:

    $> npm install

This will install all the dependencies mentioned in package.json files.

Start the development server and see the application running at `localhost:8080`:

    $> npm run serve


Motivation 
--------------
[SOCR](http://socr.umich.edu), Statistics Online Computational Resource has a huge user base who constantly access the educational data present and java tools which use these data to aid in understanding statistics.
As far as the technology is concerned, currently all the applications are written in `java` and are presented as java applets. The reach of these applications is bottlenecked by technology.

Goal
------
The world is going the HTML5 way. Browsers are becoming more powerful. 
We intend to create a toolbox which will serve users on all platforms. We are primarily using `CoffeeScript` (compiles to `JavaScript`) for all the computations and presentation. Given the fact that today’s browsers have powerful javaScript engines (`v8`, `SpiderMonkey`), we perform all the calculations on the browser with no server dependency. File management, database, computation will be performed inside the browser.

 Technologies/Packages
----------------
 [`CoffeeScript`](http://coffeescript.org/)
 [`Jade`](http://jade-lang.com/)
 [`Less`](http://lesscss.org/)
 [`Webpack`](https://webpack.github.io/) 
 [`Node.js`](http://nodejs.org/)

 Dependencies
--------------
 [`Bootstrap`](http://getbootstrap.com/)
 [`jQuery`](https://jquery.com/)
 [`AngularJS`](http://angularjs.org) with [`AngularUI`](https://angular-ui.github.io/)
 [`D3.js`](http://d3js.org)
 [`Handsontable`](http://handsontable.com/) with [`ngHandsontable`](https://handsontable.github.io/ngHandsontable/)
 [`jStat`](https://jstat.github.io/)
 [`Wrangler`](http://vis.stanford.edu/wrangler/)

Copyright and License 
----------------------

**The LGPL v3.0 License**

Copyright (c) 2013-2016 Statistics Online Computational Resource [(SOCR)](http://www.StatisticsResource.org)

All SOCR programs, materials, tools and resources are developed by and freely disseminated to the entire community.
Users may revise, extend, redistribute, modify under the terms of the Lesser GNU General Public License
as published by the [Open Source Initiative](http://opensource.org/licenses/). All efforts should be made to develop and distribute
factually correct, useful, portable and extensible resource all available in all digital formats for free over the Internet.

SOCR resources are distributed in the hope that they will be useful, but without
any warranty; without any explicit, implicit or implied warranty for merchantability or
fitness for a particular purpose. See the GNU Lesser General Public License for
more details see http://opensource.org/licenses/LGPL-3.0.
