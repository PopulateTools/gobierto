module.exports = {
  moduleFileExtensions: [
    "js",
    "vue",
  ],
  transform: {
     "^[^.]+.vue$": "vue-jest",
     "^.+\\.js$": "babel-jest"
   },
  testMatch: [
    '<rootDir>/test/**/*.spec.js'
  ]
};
