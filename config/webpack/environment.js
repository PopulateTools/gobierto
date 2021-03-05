const { environment } = require("@rails/webpacker");

const webpack = require("webpack");
const merge = require("webpack-merge");
const { VueLoaderPlugin } = require("vue-loader");
const vue = require("./loaders/vue");
const less = require("./loaders/less");
const terser = require("./optimization/terser");
const splitChunks = require("./optimization/splitChunks");
const output = require('./config/output')

environment.loaders.append("less", less);
environment.loaders.append("vue", vue);
environment.config.merge(terser);
environment.config.merge(splitChunks);
environment.config.merge(output)

environment.plugins.prepend("VueLoaderPlugin", new VueLoaderPlugin());
environment.plugins.append(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery",
    "window.$": "jquery",
    jQuery: "jquery",
    "window.jQuery": "jquery",
    _: "lodash"
  })
);

// NOTE: Must be updated if add a new locale files - https://yarnpkg.com/es-ES/package/moment-locales-webpack-plugin
const MomentLocalesPlugin = require("moment-locales-webpack-plugin");
environment.plugins.append(
  "MomentLocales",
  new MomentLocalesPlugin({
    localesToKeep: ["es", "ca"]
  })
);

environment.loaders.delete("nodeModules");

// const BundleAnalyzerPlugin = require("webpack-bundle-analyzer").BundleAnalyzerPlugin;
// environment.plugins.insert("BundleAnalyzerPlugin", new BundleAnalyzerPlugin());

const envConfig = (module.exports = environment);
const aliasConfig = (module.exports = {
  resolve: {
    symlinks: false,
    alias: {
      vue: "vue/dist/vue.esm.js"
    }
  }
});

module.exports = merge(envConfig.toWebpackConfig(), aliasConfig);
