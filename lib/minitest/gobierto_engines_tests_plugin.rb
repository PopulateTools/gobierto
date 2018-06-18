# frozen_string_literal: true

module Minitest
  def self.plugin_gobierto_engines_tests_init(*)
    if ::Rails::TestUnit::Runner.send(:extract_filters, ARGV).empty?
      tests = Rake::FileList['vendor/gobierto_engines/**/*_test.rb']
      tests.to_a.each { |path| require File.expand_path(path) }
    end
  end
end
