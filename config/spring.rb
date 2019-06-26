%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
  config/secrets.yml
  vendor/gobierto_engines
].each { |path| Spring.watch(path) }
