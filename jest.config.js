module.exports = {
  moduleFileExtensions: [
    "js",
    "vue",
  ],
  transform: {
     "^[^.]+.vue$": "vue-jest",
     "^.+\\.js$": "babel-jest"
   },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/javascript/$1',
    '^tests/(.*)$': '<rootDir>/test/javascript/$1',
  },
  testMatch: [
    '<rootDir>/test/**/*.spec.js'
  ]
};
