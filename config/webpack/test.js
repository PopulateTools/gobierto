process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const terser = require('./config/terser')
environment.config.merge(terser)

const SpeedMeasurePlugin = require("speed-measure-webpack-plugin");
const smp = new SpeedMeasurePlugin({
  outputFormat: "humanVerbose",
  loaderTopFiles: 10,
  compareLoadersBuild: {
    filePath: "./tmp/build-info.json",
  },
});

module.exports = smp.wrap(environment.toWebpackConfig())