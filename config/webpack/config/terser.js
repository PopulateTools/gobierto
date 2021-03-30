const TerserPlugin = require("terser-webpack-plugin");

module.exports = {
  optimization: {
    minimize: false,
    minimizer: [
      new TerserPlugin({
        terserOptions: {
          format: {
            comments: false,
          },
        },
        extractComments: false,
        parallel: 2,
        cache: true,
        sourceMap: false,
      })
    ]
  }
};
