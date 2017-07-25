## SOCRAT: [SOCR](http://socr.umich.edu) Analytics Toolbox

A Dynamic Web Toolbox for Interactive Data Processing, Analysis, and Visualization

* [Web site](http://socr.umich.edu)
* [Relevant publications](#publications)
* [Issue-tracking and project management](https://github.com/SOCR/SOCRAT-issues)
* [Contribution guidelines](https://github.com/SOCR/SOCRAT/blob/master/CONTRIBUTE.md)
* **Note: project is under development, new features are in pending Pull Requests, unit tests currently are not passing, bugs are possible**

Installation
------------
In case you wish to run SOCRAT locally, or create your own module, or contribute
to the project, follow these steps to setup your environment.

First, install [Node.js](http://nodejs.org/) if you haven't yet. `npm` is the package manager for `Node.js` and comes bundled with it.

Install Webpack:

    $> sudo npm install webpack -g

Clone the repository:

    $> git clone https://github.com/SOCR/SOCRAT.git
    $> cd SOCRAT

Switch to the `dev` branch to see latest changes or to contribute to the project:

    $> git checkout dev
    $> git pull

Now, install all the dependencies:

    $> npm install

After that build the project and start the web-server:

    $> npm run build
    $> node server.js

Now you shoule be able to access SOCRAT at `localhost:3000`.

Start the development server with:

    $> npm run serve

You will see the application running at `localhost:8080` and the page will live
reload on saved changes in source code.
Also see how to [add test datasets](https://github.com/SOCR/SOCRAT/blob/dev/CONTRIBUTE.md#socr-datasets-for-testing) and general [contrubition instructions](https://github.com/SOCR/SOCRAT/blob/dev/CONTRIBUTE.md).

Motivation
--------------
The modern web is a successful platform for large scale interactive web applications, including visualizations. Statistics Online Computational Resource ([SOCR](http://socr.umich.edu)) provides a
web-based collection of tools for interactive modeling and visual data analysis that has a large user base. However, most of SOCR applets eventually became practically unavailable to end users as new versions of browsers disabled Java by default as a response to numerous vulnerability reports.
Thus, we designed an open-source platform to build Statistics Online Computational Resource
Analytical Toolbox (SOCRAT). Platform design defines: (1) a specification for an architecture for building VA applications with multi-level modularity, and (2) methods for optimizing module
interaction, re-usage, and extension. SOCRAT relies on this platform for integration of a number of data management, analysis, and visualization modules into an easily customizable web application including interfaces for merging third-party components. This ability allows SOCRAT to balance expressive, interactive and processing capabilities, efficiency, compatibility, and accessibility. Multi-level modularity and declarative specifications enable easy customizations of the application, for instance, for a specific project. Online demo demonstrates how SOCRAT can be used for data input, display, and storage, with interactive visualization and analysis.
For more details see the publication list below.

Publications
------

If you find our work useful, please cite our paper:

Alexandr A. Kalinin, Selvam Palanimalai, and Ivo D. Dinov. 2017. SOCRAT Platform Design: A Web Architecture for Interactive Visual Analytics Applications. In Proceedings of HILDA’17, Chicago, IL, USA, May 14, 2017, 6 pages. [DOI:10.1145/3077257.3077262](http://dx.doi.org/10.1145/3077257.3077262)

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

Copyright (c) 2013-2017 Statistics Online Computational Resource [(SOCR)](http://www.StatisticsResource.org)

All SOCR programs, materials, tools and resources are developed by and freely disseminated to the entire community.
Users may revise, extend, redistribute, modify under the terms of the Lesser GNU General Public License
as published by the [Open Source Initiative](http://opensource.org/licenses/). All efforts should be made to develop and distribute
factually correct, useful, portable and extensible resource all available in all digital formats for free over the Internet.

SOCR resources are distributed in the hope that they will be useful, but without
any warranty; without any explicit, implicit or implied warranty for merchantability or
fitness for a particular purpose. See the GNU Lesser General Public License for
more details see http://opensource.org/licenses/LGPL-3.0.
