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

// This is required while the style imports are being done through CSS files, instead of JS
// https://github.com/rails/webpacker/blob/5-x-stable/docs/css.md#resolve-url-loader
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

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
