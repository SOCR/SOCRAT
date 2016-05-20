webpack = require 'webpack'
production = process.env.NODE_ENV is 'production'

appRoot = "#{__dirname}/app"

module.exports =
  cache: true
  debug: !production
  devtool: production ? false : 'eval'

  # The entry point
  entry: [
    "#{appRoot}/app.coffee"
  ]

  output:
    path: './_build'
    filename: 'socrat.js'
    chunkFilename: "[id].socrat.js"

  devServer: {
    hot: true,
  }

  module:
    loaders: [
      test: /\.less$/
      loaders: ['style', 'css', 'less']
    ,
      test: /\.css$/
      loaders: ['style', 'css']
    ,
      test: /\.coffee$/
      loader: 'coffee'
    ,
      test: /\.jade$/
      loader: 'jade-loader'
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

  resolve:

    extensions: [
      ''
      '.js'
      '.coffee'
      '.less'
      '.css'
    ]

    root: appRoot

  plugins: [

  # disable dynamic requires
    new webpack.ContextReplacementPlugin(/.*$/, /a^/)

#    new webpack.ProvidePlugin
#      'angular': 'exports?window.angular!bower/angular'
  ]
