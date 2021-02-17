process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const stats = require('./config/stats')
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin

environment.config.merge(stats)
environment.plugins.append('BundleAnalyzerPlugin', new BundleAnalyzerPlugin({
  openAnalyzer: false
}))

module.exports = environment.toWebpackConfig()
