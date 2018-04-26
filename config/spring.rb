%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  config/secrets.yml
].each { |path| Spring.watch(path) }
