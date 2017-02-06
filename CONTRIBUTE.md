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
* `<subject>` is a description of the change starting with a verb in imperative form, present tense, not capitalized, without period in the end

Additional details can be added on a second line of the message.
