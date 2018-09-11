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

// environment.plugins.append('CommonChunkVendor',
//   new webpack.optimize.CommonsChunkPlugin({
//     name: 'vendor', // Vendor code
//     minChunks: (module) => module.context && module.context.indexOf('node_modules') !== -1
//   })
// )

// Set the ecma version only works on assets:precompile, not with the dev-server
try {
  environment.plugins.get("UglifyJs").options.uglifyOptions.ecma = 5;
} catch(e) {
  console.log("Ignoring Uglify configuration");
}

const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
environment.plugins.insert('BundleAnalyzerPlugin', new BundleAnalyzerPlugin())

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
