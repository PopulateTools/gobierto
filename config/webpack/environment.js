const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const merge = require('webpack-merge')

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    'window.$': 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
    _: 'lodash'
  })
)

// NOTE: Must be updated if add a new locale files - https://yarnpkg.com/es-ES/package/moment-locales-webpack-plugin
const MomentLocalesPlugin = require('moment-locales-webpack-plugin')
environment.plugins.append(
  'MomentLocales',
  new MomentLocalesPlugin({
    localesToKeep: ['es', 'ca']
  })
)

environment.plugins.append(
  'CommonsChunk',
  new webpack.optimize.CommonsChunkPlugin({
    name: "commons",
    minChunks: 5
  })
)

// Set the ecma version only works on assets:precompile, not with the dev-server
try {
  environment.plugins.get("UglifyJs").options.uglifyOptions.ecma = 5

  environment.devtool = "source-map"
  environment.plugins.get("UglifyJs").options.sourceMap = true
} catch(e) {
  console.warn("Ignoring Uglify configuration")
}

// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
// environment.plugins.insert('BundleAnalyzerPlugin', new BundleAnalyzerPlugin())

const envConfig = module.exports = environment
const aliasConfig = module.exports = {
  resolve: {
    symlinks: false,
    alias: {
      vue: 'vue/dist/vue.esm.js'
    }
  }
}

module.exports = merge(envConfig.toWebpackConfig(), aliasConfig)
