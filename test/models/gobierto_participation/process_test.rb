require "test_helper"

module GobiertoCms
  class ProcessTest < ActiveSupport::TestCase

    def process
      @process ||= gobierto_participation_processes(:green_city_group)
    end
    alias collectionable_object process

    def test_valid
      assert process.valid?
    end

  end
end
