# frozen_string_literal: true

require "test_helper"

class VocabularyTest < ActiveSupport::TestCase
  def vocabulary
    @vocabulary ||= gobierto_common_vocabularies(:animals)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_valid
    assert vocabulary.valid?
  end

  def test_unique_slug_scoped_to_site
    invalid_vocabulary = site.vocabularies.new(name: "test", slug: vocabulary.slug)
    refute invalid_vocabulary.valid?
  end
end
