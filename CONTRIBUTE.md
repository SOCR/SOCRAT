We are currently few developers actively contributing to the project. Feel free to reach out to us for any help.

## Technology stack

The technology stack used in this framework is described below.

### Bare Essentials

**Git** - You guessed it right, we use git for our code versioning following the [git branching model](http://nvie.com/posts/a-successful-git-branching-model/) suggested by Vincent.

**CoffeeScript** - For cleaner code, we have adopted [CoffeeScript](http://coffeescript.org). Please use the below resources to familiarise yourselves.
  - http://coffeescript.org/ 
  - http://js2coffee.org

**Jade** - For HTML, we use jade templating engine.
  - http://jade-lang.com/
  - http://html2jade.org/

**AngularJS** - JavaScript framework that we employ. Very elegant. [Official website](https://angularjs.org/) has the best documentation.

**[WebPack](https://webpack.github.io/)** - module bundler. 

### Optional

**[D3](http://d3js.org)** - Data driven charts
  
## Commit message format

We loosely follow [AngularJs Commit Message Format](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#commit):

First line of the git message has to be in the following format: `<type>(<scope>): <subject>`
* `<type>` here is from [this list](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#type)
* `<scope>` is a specific module within SOCRAT you're contributing to, i.e. `Core` or `Charts` or `PowerCalc`
* `<subject>` is a description of the change starting with a verb in imperative form, present tense, not capitalized, without period in the end; when commiting unfinished work (e.g. with known bugs), prepend `<subject>` with `WIP`.

Second line of the message should contain reference to the corresponding issue (if such exists) in format: `SOCR/SOCRAT-issues#<issue>`
* `<issue>` here is a number of issue from SOCR/SOCRAT-issues repository

Example of commit message:

```
fix(AppMainMenu): add missing Login button

SOCR/SOCRAT-issues#1
```

## SOCR Datasets for testing

**Iris** - famous dataset in machine learning [1]. To be able to use it locally for testing, download [CSV file](https://drive.google.com/file/d/0BzJubeARG-hsdTdRTC03RFdhRTg/view?usp=sharing) and place it under ``_build/datasets/iris.csv``

[1] Lichman, M. (2013). [UCI Machine Learning Repository](http://archive.ics.uci.edu/ml). Irvine, CA: University of California, School of Information and Computer Science.
