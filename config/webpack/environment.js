const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    'window.$': 'jquery',
    jQuery: 'jquery',
    'window.jQuery': 'jquery',
    I18n: 'i18n-js',
    'window.I18n': 'i18n-js',
    _: 'lodash',
  })
)

// Insert before a given plugin
environment.plugins.insert('CommonChunkVendor',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor', // Vendor code
    minChunks: (module) => module.context && module.context.indexOf('node_modules') !== -1
  })
)

// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
// environment.plugins.insert('BundleAnalyzerPlugin', new BundleAnalyzerPlugin())

module.exports = environment
