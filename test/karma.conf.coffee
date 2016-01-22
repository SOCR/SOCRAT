# Karma configuration
# http://karma-runner.github.io/0.12/config/configuration-file.html
# Generated on 2015-10-19 using
# generator-karma 1.0.0

module.exports = (config) ->
  config.set
    # base path, that will be used to resolve files and exclude
    basePath: '../'

    # testing framework to use (jasmine/mocha/qunit/...)
    # as well as any additional frameworks (requirejs/chai/sinon/...)
    frameworks: [
      "jasmine"
    ]

    # list of files / patterns to load in the browser
    files: [
      # bower:js
      'bower_components/jquery/dist/jquery.js'
      'bower_components/angular/angular.js'
      'bower_components/jquery-layout/source/stable/jquery.layout.js'
      'bower_components/jquery-highlight/jquery.highlight.js'
      'bower_components/jquery-hoverintent/jquery.hoverIntent.js'
      'bower_components/datatables/media/js/jquery.dataTables.js'
      'bower_components/d3/d3.js'
      'bower_components/angular-animate/angular-animate.js'
      'bower_components/angular-cookies/angular-cookies.js'
      'bower_components/angular-messages/angular-messages.js'
      'bower_components/angular-resource/angular-resource.js'
      'bower_components/angular-route/angular-route.js'
      'bower_components/angular-sanitize/angular-sanitize.js'
      'bower_components/angular-touch/angular-touch.js'
      'bower_components/angular-ui-router/release/angular-ui-router.js'
      'bower_components/zeroclipboard/dist/ZeroClipboard.js'
      'bower_components/moment/moment.js'
      'bower_components/pikaday/pikaday.js'
      'bower_components/handsontable/dist/handsontable.js'
      'bower_components/ngHandsontable/dist/ngHandsontable.js'
      'bower_components/wrangler/lib/datavore/datavore-d0.1.js'
      'bower_components/wrangler/dw.js'
      'bower_components/bootstrap/dist/js/bootstrap.js'
      'bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
      'bower_components/jstat/dist/jstat.js'
      'bower_components/jsfeat/build/jsfeat.js'
      'bower_components/angular-mocks/angular-mocks.js'
      # endbower
      # bower:coffee
      # endbower
      "app/scripts/**/*.coffee"
      "test/mock/**/*.coffee"
      "test/spec/**/*.coffee"
    ],

    # list of files / patterns to exclude
    exclude: [
    ]

    # web server port
    port: 8080

    # level of logging
    # possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO

    # Start these browsers, currently available:
    # - Chrome
    # - ChromeCanary
    # - Firefox
    # - Opera
    # - Safari (only Mac)
    # - PhantomJS
    # - IE (only Windows)
    browsers: [
      "PhantomJS2"
    ]

    # Which plugins to enable
    plugins: [
      "karma-phantomjs2-launcher",
      "karma-jasmine",
      "karma-coffee-preprocessor"
    ]

    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true

    # Continuous Integration mode
    # if true, it capture browsers, run tests and exit
    singleRun: false

    colors: true

    preprocessors: '**/*.coffee': ['coffee']

    # Uncomment the following lines if you are using grunt's server to run the tests
    # proxies: '/': 'http://localhost:9000/'
    # URL root prevent conflicts with the site root
    # urlRoot: '_karma_'
