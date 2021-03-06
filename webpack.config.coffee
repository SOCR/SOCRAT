webpack = require 'webpack'
path = require 'path'

production = process.env.NODE_ENV is 'production'

appRoot = path.resolve "#{__dirname}", "app"

module.exports =
  cache: true
  debug: !production
  devtool: production ? false : 'eval'

  # The entry point
  entry: [
    path.resolve "#{appRoot}", "app.coffee"
  ]

  devtool: 'inline-source-map'

  output:
    path: path.resolve ".", "_build"
    filename: 'socrat.js'
    chunkFilename: "[id].socrat.js"

  module:
    loaders: [
      test: /\.m?js$/
      exclude: /(node_modules|bower_components)/
      loader: 'babel-loader'
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
      test: /\.json$/,
      loader: 'json-loader'
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
      test: /[\/\\]datavore-d0\.1\.js$/
      loader: 'exports?dv'
    ,
      test: /[\/\\]highlight\.js$/
      loader: 'exports?Highlight'
    ,
      test: /[\/\\]dw\.js$/
      loader: 'imports?dv=datavore!imports?Highlight=highlight!exports?dw'
    ,
      test: /[\/\\]flat-ui\.js$/
      loader: 'imports?this=>window'
    ,
      test: /[\/\\]vega-dataflow\.js$|[\/\\]vega-view\.js$|[\/\\]vega-loader\.js$/i
      loader: 'babel-loader'
    ,
      test: /[\/\\]d3-delaunay\.js$/
      loader: 'babel-loader'
    ,
      test: /[\/\\](ml-array-rescale).*\.js$/
      loader: 'babel-loader'
    ,
      test: /[\/\\]vega-lite\.js$/
      loader: 'imports?vg=vega'
    ,
      test: /[\/\\]vega-embed\.js$/
      loader: 'imports?vg=vega!imports?vl=vega-lite'
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
      'vega-lite': 'vega-lite/build/vega-lite.js'
      'vega-embed': 'vega-embed/build/vega-embed.js'

  plugins: [

    # disable dynamic requires
    new webpack.ContextReplacementPlugin /.*$/, /a^/

    new webpack.ProvidePlugin
      $: "jquery",
      jQuery: "jquery",
      'window.jQuery': "jquery"
  ]
