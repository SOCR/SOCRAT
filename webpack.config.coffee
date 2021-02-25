webpack = require('webpack')
path = require('path')

appRoot = path.resolve "#{__dirname}", "app"

config =
  mode: 'development'
  entry: path.resolve "#{appRoot}", "app.coffee"
  output:
    path: path.resolve ".", "_build"
    filename: 'socrat.js'
  # devtool: 'source-map'
  module:
    rules: [
      test: /\.(js|jsx)$/
      exclude: /(node_modules|bower_components)/
      use: 'babel-loader'
    ,
      test: /\.less$/
      use: ['style-loader', 'css-loader', 'less-loader']
    ,
      test: /\.css$/
      use: ['style-loader', 'css-loader']
    ,
      test: /\.coffee$/
      use: 'coffee-loader'
    ,
      test: /\.jade$/
      use: 'jade-loader'
    ,
      test: /\.html$/,
      use: 'html-loader'
    ,
      # required for bootstrap icons
      test: /\.eot(\?v=\d+\.\d+\.\d+)?$/
      use: "file-loader"
    ,
      test: /\.(woff|woff2)$/
      use: 'url-loader?prefix=font/&limit=5000&mimetype=application/font-woff'
    ,
      test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/
      use: "url-loader?limit=10000&mimetype=application/octet-stream"
    ,
      test: /\.svg(\?v=\d+\.\d+\.\d+)?$/
      use: "url-loader?limit=10000&mimetype=image/svg+xml"
    ,
      test: /\.jpe?g$|\.gif$|\.png$/i
      use: "url-loader"
    ,
      test: /[\/\\]datavore-d0\.1\.js$/
      use:
        loader: 'exports-loader'
        options:
          exports: 'dv'
    ,
      test: /[\/\\]highlight\.js$/
      loader: 'exports-loader'
      options:
        type: 'commonjs'
        exports: 'Highlight'
    ,
      test: /[\/\\]dw\.js$/
      use: [
        loader: 'imports-loader'
        options:
          imports: 'named datavore dv'
      ,
        loader: 'imports-loader'
        options:
          imports: 'named highlight Highlight'
      ,
        loader: 'exports-loader'
        options:
          exports: 'dw'
      ]
    ,
      test: /[\/\\]flat-ui\.js$/
      use: 'imports-loader?this=>window'
    ,
      test: /[\/\\]vega-dataflow\.js$|[\/\\]vega-view\.js$|[\/\\]vega-loader\.js$/i
      use: 'babel-loader'
    ,
      test: /[\/\\]d3-delaunay\.js$/
      use: 'babel-loader'
    ]
  resolve:

    extensions: [
      '.js'
      '.coffee'
      '.less'
      '.css'
    ]

    fallback:
      "path": require.resolve 'path-browserify'

    roots: [appRoot]

    modules: [path.resolve(__dirname, 'app'), 'node_modules']

    alias:
      datavore: 'data-wrangler/lib/datavore/datavore-d0.1.js'
      highlight: 'data-wrangler/lib/Highlight/highlight.js'
      'jquery-ui': 'jquery-ui/ui/widgets'

  plugins: [
    new webpack.ContextReplacementPlugin /.*$/, /a^/

    new webpack.ProvidePlugin
      $: "jquery",
      jQuery: "jquery",
      'window.jQuery': "jquery"

    new webpack.SourceMapDevToolPlugin
      filename: "[file].map"
  ]

module.exports = config
