module.exports = {
  moduleFileExtensions: [
    'js',
    'vue',
  ],
  transform: {
    '^.+\\.js$': 'babel-jest',
    '.*\\.vue$': 'vue-jest',
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/javascript/lib/vue-components/modules/$1',
    '^tests/(.*)$': '<rootDir>/app/javascript/lib/vue-components/test/$1',
  },
};
