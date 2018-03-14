const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    'window.$': 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
    _: 'lodash',
  })
)

environment.plugins.append('CommonChunkVendor',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor', // Vendor code
    minChunks: (module) => module.context && module.context.indexOf('node_modules') !== -1
  })
)

// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
// environment.plugins.insert('BundleAnalyzerPlugin', new BundleAnalyzerPlugin())

module.exports = environment
