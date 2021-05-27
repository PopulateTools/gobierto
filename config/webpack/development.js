process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const stats = require('./config/stats')

environment.config.merge(stats)
environment.plugins.delete('CaseSensitivePaths')

// How to run: WEBPACK_ANALYZE=true bin/webpack-dev-server
if (process.env.WEBPACK_ANALYZE === 'true') {
  const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
  environment.plugins.append('BundleAnalyzerPlugin', new BundleAnalyzerPlugin())
}

let config;
// How to run: WEBPACK_SPEED=true bin/webpack-dev-server
if (process.env.WEBPACK_SPEED === 'true') {
  const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");
  const smp = new SpeedMeasurePlugin({
    outputFormat: "human",
    loaderTopFiles: 5,
    // compareLoadersBuild: {
    //   filePath: "./tmp/build-info.json",
    // },
  });

  config = smp.wrap(environment.toWebpackConfig())
} else {
  config = environment.toWebpackConfig()
}

module.exports = config