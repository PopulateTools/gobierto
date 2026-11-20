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

  def test_reserved
    refute vocabulary.reserved?

    vocabulary.slug = GobiertoCommon::Vocabulary::RESERVED.dig(:sdgs, :slug)

    assert vocabulary.reserved?
  end

  def test_vocabulary_seeded_by_plans_recipe_is_reserved
    previous_ids = site.vocabularies.pluck(:id)

    GobiertoSeeds::GobiertoPlans::Recipe.run(site)

    seeded_vocabularies = site.vocabularies.where.not(id: previous_ids)
    assert_equal 1, seeded_vocabularies.count
    assert seeded_vocabularies.first.reserved?
  end
end
