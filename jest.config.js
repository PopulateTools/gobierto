module.exports = {
  moduleFileExtensions: [
    "js"
  ],
  transform: {
    "^.+\\.js$": "babel-jest"
  },
  testMatch: [
    '<rootDir>/test/**/*.test.js'
  ],
  moduleNameMapper: {
    "data.json": "<rootDir>/test/javascript/gobierto_data/__mocks__/data.json"
  }
};
