process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const terser = require('./config/terser')
environment.config.merge(terser)

module.exports = environment.toWebpackConfig()