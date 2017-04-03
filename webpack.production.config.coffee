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
      test: /\.jsx?$/
      exclude: /(node_modules|bower_components)/
      loader: 'babel'
    ,
      test: /\.less$/
      loader: 'style!css!less'
    ,
      test: /\.css$/
      loader: 'style!css'
    ,
      test: /\.coffee$/
      loader: 'coffee'
    ,
      test: /\.jade$/
      loader: 'jade-loader'
    ,
      test: /\.html$/,
      loader: 'html'
    ,
      # required for bootstrap icons
      test: /\.eot(\?v=\d+\.\d+\.\d+)?$/
      loader: "file"
    ,
      test: /\.(woff|woff2)$/
      loader: 'url?prefix=font/&limit=5000&mimetype=application/font-woff'
    ,
      test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/
      loader: "url?limit=10000&mimetype=application/octet-stream"
    ,
      test: /\.svg(\?v=\d+\.\d+\.\d+)?$/
      loader: "url?limit=10000&mimetype=image/svg+xml"
    ,
      test: /\.jpe?g$|\.gif$|\.png$/i
      loader: "url"
    ,
      test: /[\/]datavore-d0\.1\.js$/
      loader: 'exports?dv'
    ,
      test: /[\/]highlight\.js$/
      loader: 'exports?Highlight'
    ,
      test: /[\/]dw\.js$/
      loader: 'imports?dv=datavore!imports?Highlight=highlight!exports?dw'
    ,
      test: /[\/]flat-ui\.js$/
      loader: 'imports?this=>window'
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

    alias:
      datavore: 'data-wrangler/lib/datavore/datavore-d0.1.js'
      highlight: 'data-wrangler/lib/Highlight/highlight.js'
      'jquery-ui': 'jquery-ui/ui/widgets'

  plugins: [

    # disable dynamic requires
    new webpack.ContextReplacementPlugin /.*$/, /a^/

    new webpack.ProvidePlugin
      $: "jquery",
      jQuery: "jquery",
      'window.jQuery': "jquery"

    new webpack.ProvidePlugin
      d3: "d3"

    new webpack.optimize.CommonsChunkPlugin('common.js')
    new webpack.optimize.DedupePlugin()
    new webpack.optimize.UglifyJsPlugin()
    new webpack.optimize.AggressiveMergingPlugin()
  ]
