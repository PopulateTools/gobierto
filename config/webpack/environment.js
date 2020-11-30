const { environment } = require('@rails/webpacker')

// config
const alias = require('./config/alias')
environment.config.merge(alias)
environment.splitChunks((config) => Object.assign({}, config, { optimization: { splitChunks: { name: "commons", minChunks: 5 } } }))

// loaders
const vue = require('./loaders/vue')
const less = require('./loaders/less')

environment.loaders.append('less', less)
environment.loaders.append('vue', vue)
environment.loaders.delete('nodeModules')

// plugins
const webpack = require('webpack')
const { VueLoaderPlugin } = require('vue-loader')
const MomentLocalesPlugin = require('moment-locales-webpack-plugin')
const PerspectivePlugin = require('@finos/perspective-webpack-plugin')

environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
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
// NOTE: Must be updated if add a new locale files - https://yarnpkg.com/es-ES/package/moment-locales-webpack-plugin
environment.plugins.append(
  'MomentLocales',
  new MomentLocalesPlugin({
    localesToKeep: ['es', 'ca']
  })
)
// Persperctive webpack
environment.plugins.append(
  'Perspective',
  new PerspectivePlugin()
)

module.exports = environment
