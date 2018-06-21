const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const merge = require('webpack-merge')

const manifestPlugin = environment.plugins.get('Manifest')
manifestPlugin.opts.writeToFileEmit = false

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

environment.plugins.append('CommonChunkVendor',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor', // Vendor code
    minChunks: (module) => module.context && module.context.indexOf('node_modules') !== -1
  })
)

environment.plugins.append('CommonsChunkManifest',
  new webpack.optimize.CommonsChunkPlugin({
    name: 'manifest',
    minChunks: Infinity
  })
)

// const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
// environment.plugins.insert('BundleAnalyzerPlugin', new BundleAnalyzerPlugin())

const envConfig = module.exports = environment
const aliasConfig = module.exports = {
  resolve: {
    alias: {
      vue: 'vue/dist/vue.esm.js'
    }
  }
}

const config = merge(envConfig.toWebpackConfig(), aliasConfig);
config.devtool = 'source-map';

module.exports = config;

// module.exports = merge(envConfig.toWebpackConfig(), aliasConfig)
