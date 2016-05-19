path = require 'path'
webpack = require 'webpack'
BowerWebpackPlugin = require('bower-webpack-plugin');

appRoot = "#{__dirname}/app"
bowerRoot = "#{__dirname}/bower_components"
#{{#less}}
#styleRoot = "#{appRoot}/styles"
#{{/less}}

module.exports =
  cache: true
  debug: true

  # The entry point
  entry: [
    "#{appRoot}/app.coffee"
  ]

  output:
    path: './target'
    filename: 'bundle.js'
    chunkFilename: "[id].bundle.js"

module:
  loaders: [
    # required to write 'require('./style.css')'
    test: /\.css$/
    loaders: ['style','css']
  ,
#    {{#sass}}
#    # required to write 'require('./style.scss')'
#    test: /\.scss$/
#    loaders: ['style','css',"sass?includePaths[]=#{styleRoot}"]
#      ,
#    {{/sass}}
    test: /\.coffee$/
    loader: 'coffee'
  ,
    # require raw html for partials
    test: /\.html$/
    loader: 'raw'
  ,
    # required for bootstrap icons
    test: /\.woff$/
    loader: 'url?prefix=font/&limit=5000&mimetype=application/font-woff'
  ,
    test: /\.ttf$/
    loader: 'file?prefix=font/'
  ,
    test: /\.eot$/
    loader: 'file?prefix=font/'
  ,
    test: /\.svg$/
    loader: 'file?prefix=font/'
]

# don't parse some dependencies to speed up build.
# can probably do this non-AMD/CommonJS deps
noParse: [
  path.join bowerRoot, '/angular'
  path.join bowerRoot, '/angular-route'
  path.join bowerRoot, '/angular-ui-router'
  path.join bowerRoot, '/angular-mocks'
  path.join bowerRoot, '/jquery'
]

resolve:
  alias:
    bower: bowerRoot

  extensions: [
    ''
    '.js'
    '.coffee'
    '.less'
    '.css'
  ]

  root: appRoot

plugins: [
# bower.json resolving
#  new webpack.ResolverPlugin [
#    new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin "bower.json", ["main"]
#  ], ["normal", "loader"]

  new BowerWebpackPlugin
    modulesDirectories: bowerRoot
    manifestFiles:      "bower.json"
    includes:           /.*/
    excludes:           []
    searchResolveModulesDirectories: true

# disable dynamic requires
  new webpack.ContextReplacementPlugin(/.*$/, /a^/)

  new webpack.ProvidePlugin
    'angular': 'exports?window.angular!bower/angular'
]

devtool: 'eval'
