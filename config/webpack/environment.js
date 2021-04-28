const { environment } = require('@rails/webpacker')

// config
const alias = require('./config/alias')
const splitChunks = require("./config/splitChunks");
const output = require('./config/output')

environment.config.merge(alias)
environment.config.merge(splitChunks)
environment.config.merge(output)

// loaders
const vue = require('./loaders/vue')
const less = require('./loaders/less')

environment.loaders.append('less', less)
environment.loaders.append('vue', vue)
environment.loaders.delete('moduleCss')
environment.loaders.delete('moduleSass')
environment.loaders.delete('nodeModules')

// plugins
const webpack = require('webpack')
const glob = require('glob-all')
const path = require('path')
const { VueLoaderPlugin } = require('vue-loader')
const MomentLocalesPlugin = require('moment-locales-webpack-plugin')
const PurgeCSSPlugin = require('purgecss-webpack-plugin')

environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
environment.plugins.append('PurgeCSSPlugin', new PurgeCSSPlugin({
  paths: glob.sync([
    path.join(__dirname, '../../app/views/**/*.erb'),
    path.join(__dirname, '../../app/javascript/**/*.js'),
    path.join(__dirname, '../../app/javascript/**/*.vue')
  ]),
  safelist: [/leaflet/, /marker/]
}))
environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    "window.$": "jquery",
    jQuery: "jquery",
    "window.jQuery": "jquery",
    _: "lodash"
  })
)
// NOTE: Must be updated if add a new locale files - https://yarnpkg.com/es-ES/package/moment-locales-webpack-plugin
environment.plugins.append(
  "MomentLocales",
  new MomentLocalesPlugin({
    localesToKeep: ["es", "ca"]
  })
)

module.exports = environment
