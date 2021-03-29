const { environment } = require('@rails/webpacker')

// config
const alias = require('./config/alias')
const terser = require("./config/terser");
const splitChunks = require("./config/splitChunks");
const output = require('./config/output')

environment.config.merge(alias)
environment.config.merge(terser)
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
const { VueLoaderPlugin } = require('vue-loader')
const MomentLocalesPlugin = require('moment-locales-webpack-plugin')

environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
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
