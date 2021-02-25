webpack = require 'webpack'
production = process.env.NODE_ENV is 'production'

appRoot = "#{__dirname}/app"

module.exports =
  cache: true
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
    rules: [
      test: /\.jsx?$/
      exclude: /(node_modules|bower_components)/
      loader: 'babel-loader'
    ,
      test: /\.less$/
      loader: 'style-loader!css!less'
    ,
      test: /\.css$/
      loader: 'style-loader!css'
    ,
      test: /\.coffee$/
      loader: 'coffee-loader'
    ,
      test: /\.jade$/
      loader: 'jade-loader'
    ,
      test: /\.html$/,
      loader: 'html-loader'
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
      loader: 'imports-loader?dv=datavore!imports-loader?Highlight=highlight!exports-loader?dw'
    ,
      test: /[\/]flat-ui\.js$/
      loader: 'imports-loader?this=>window'
  ]

  resolve:

    extensions: [
      '.js'
      '.coffee'
      '.less'
      '.css'
    ]

    # resolve.root in webpack 2.0
    modules: [appRoot, 'node_modules']

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

    # debug mode update for webpack 2+
    new webpack.LoaderOptionsPlugin({
       debug: !production
    })
  ]
