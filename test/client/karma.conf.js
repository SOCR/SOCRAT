// Karma configuration
// Generated on Wed Jul 31 2013 16:40:56 GMT+0530 (IST)


// base path, that will be used to resolve files and exclude
basePath = '../..';


// list of files / patterns to load in the browser
files = [
  JASMINE,
  JASMINE_ADAPTER,
  // Application Code //
  'vendor/scripts/angular/angular.js',
  'vendor/scripts/angular/angular-*.js',

  'vendor/scripts/datavore/dv.js',
  'vendor/scripts/distributome/core.js',
  // 'vendor/scripts/**/*.js',
  'vendor/scripts/**/*.coffee',
  //'app/scripts/**/*.js',
  'app/scripts/**/*.coffee',

  // Javascript //
 
  'test/vendor/angular/angular-mocks.js',

  // Specs //

  // CoffeeScript //
  // 'test/unit/**/*.spec.coffee'
  'test/unit/db/db.spec.coffee'

  // Javascript //
  // 'test/unit/**/*.spec.js'
];

// list of files to exclude
exclude = [
  
];

output = "/test";

// use dots reporter, as travis terminal does not support escaping sequences
// possible values: 'dots', 'progress', 'junit'
// CLI --reporters progress
reporters = ['progress', 'junit'];

junitReporter = {
  // will be resolved to basePath (in the same way as files/exclude patterns)
  outputFile: 'test/test-results.xml'
};
// web server port
port = 9876;


// cli runner port
runnerPort = 9100;


// enable / disable colors in the output (reporters and logs)
colors = true;


// level of logging
// possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
logLevel = LOG_INFO;


// enable / disable watching file and executing tests whenever any file changes
autoWatch = true;


// Start these browsers, currently available:
// - Chrome
// - ChromeCanary
// - Firefox
// - Opera
// - Safari (only Mac)
// - PhantomJS
// - IE (only Windows)
browsers = ['Chrome'];


// If browser does not capture in given timeout [ms], kill it
captureTimeout = 60000;


// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun = false;

// compile coffee scripts
preprocessors = {
  '**/*.coffee': 'coffee'
};
