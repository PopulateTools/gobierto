process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const stats = require('./config/stats')
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");

environment.config.merge(stats)

environment.plugins.delete('CaseSensitivePaths')
environment.plugins.append('BundleAnalyzerPlugin', new BundleAnalyzerPlugin({
  openAnalyzer: false
}))

const smp = new SpeedMeasurePlugin({
  outputFormat: "human",
  loaderTopFiles: 5,
  // compareLoadersBuild: {
  //   filePath: "./tmp/build-info.json",
  // },
});
module.exports = smp.wrap(environment.toWebpackConfig())