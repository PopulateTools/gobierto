module.exports = {
  output: {
    filename: (pathData) => {
      return pathData.chunk.name === 'embeds' ? "js/[name].js" : "js/[name]-[contenthash].js";
    },
  },
};