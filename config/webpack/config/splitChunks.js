module.exports = {
  optimization: {
    runtimeChunk: false,
    splitChunks: {
      chunks: chunk => chunk.name !== "embeds"
    }
  }
};
