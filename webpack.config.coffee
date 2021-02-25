webpack = require 'webpack'
path = require 'path'

production = process.env.NODE_ENV is 'production'

appRoot = path.resolve "#{__dirname}", "app"

module.exports =
  cache: true
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
    rules: [
      test: /\.m?js$/
      exclude: /(node_modules|bower_components)/
      use: [
        {
          loader: 'babel-loader'
        }
      ]
    ,
      test: /\.(sass|less|css)$/
      loaders: ['style-loader', 'css-loader', 'less-loader']
    ,

      test: /\.coffee$/
      use: [
        {
          loader: 'coffee-loader'
        }
      ]
    ,
      test: /\.jade$/
      use: [
        {
          loader: 'jade-loader'
        }
      ]
    ,
      test: /\.html$/,
      use: [
        {
          loader: 'html-loader'
        }
      ]
    ,
      test: /\.json$/,
      use: [
        {
          loader: 'json-loader'
        }
      ]
    ,
      # required for bootstrap icons
      test: /\.eot(\?v=\d+\.\d+\.\d+)?$/
      use: [
        {
          loader: "file-loader"
        }
      ]
    ,
      test: /\.(woff|woff2)$/
      use: [
        {
          loader: 'url-loader'
          options: {
            limit: 5000,
            mimetype: 'application/font-woff'
          }
        }
      ]
    ,
      test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/
      use: [
        {
          loader: 'url-loader'
          options: {
            limit: 10000,
            mimetype: 'application/octet-stream'
          }
        }
      ]
    ,
      test: /\.svg(\?v=\d+\.\d+\.\d+)?$/
      use: [
        {
          loader: 'url-loader'
          options: {
            limit: 10000,
            mimetype: 'image/svg+xml'
          }
        }
      ]
    ,
      test: /\.jpe?g$|\.gif$|\.png$/i
      use: [
        {
          loader: 'url-loader'
        }
      ]
    ,
      test: /[\/\\]datavore-d0\.1\.js$/
      use: [
        {
          loader: 'exports-loader?dv'
        }
      ]
    ,
      test: /[\/\\]highlight\.js$/
      use: [
        {
          loader: 'exports-loader?Highlight'
        }
      ]
    ,
      test: /[\/\\]dw\.js$/
      loader: 'imports-loader?dv=datavore!imports-loader?Highlight=highlight!exports-loader?dw'
    ,
      test: /[\/\\]flat-ui\.js$/
      use: [
        {
          loader: 'imports-loader?this=>window'
        }
      ]
    ,
      test: /[\/\\]vega-dataflow\.js$|[\/\\]vega-view\.js$|[\/\\]vega-loader\.js$/i
      use: [
        {
          loader: 'babel-loader'
        }
      ]
    ,
      test: /[\/\\]d3-delaunay\.js$/
      use: [
        {
          loader: 'babel-loader'
        }
      ]
    ,
      test: /[\/\\](ml-array-rescale).*\.js$/
      use: [
        {
          loader: 'babel-loader'
        }
      ]
    ,
      test: /[\/\\]vega-lite\.js$/
      loader: 'imports-loader?vg=vega'
    ,
      test: /[\/\\]vega-embed\.js$/
      loader: 'imports-loader?vg=vega!imports-loader?vl=vega-lite'
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
      'vega-lite': 'vega-lite/build/vega-lite.js'
      'vega-embed': 'vega-embed/build/vega-embed.js'

  plugins: [

    # disable dynamic requires
    new webpack.ContextReplacementPlugin /.*$/, /a^/

    new webpack.ProvidePlugin
      $: "jquery",
      jQuery: "jquery",
      'window.jQuery': "jquery"

    # debug mode update for webpack 2+
    new webpack.LoaderOptionsPlugin({
       debug: !production
    })
  ]
