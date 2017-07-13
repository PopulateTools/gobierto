require "test_helper"
require "support/concerns/gobierto_common/collectionable_test"

module GobiertoCms
  class ProcessTest < ActiveSupport::TestCase
    include GobiertoCommon::CollectionableTest

    def process
      @process ||= gobierto_participation_processes(:green_city)
    end
    alias collectionable_object process

    def test_valid
      assert process.valid?
    end

    def test_find_by_slug
      assert_nil GobiertoParticipation::Process.find_by_slug! nil
      assert_nil GobiertoParticipation::Process.find_by_slug! ""
      assert_raises(ActiveRecord::RecordNotFound) do
        GobiertoParticipation::Process.find_by_slug! "foo"
      end

      assert_equal process, GobiertoParticipation::Process.find_by_slug!(process.slug_es)
      assert_equal process, GobiertoParticipation::Process.find_by_slug!(process.slug_en)
    end
  end
end
