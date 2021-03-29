module.exports = {
  optimization: {
    runtimeChunk: false,
    splitChunks: {
      name: "commons",
      minChunks: 5,
      chunks: chunk => chunk.name !== "embeds"
    }
  }
};
