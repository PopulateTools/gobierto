# frozen_string_literal: true

require "test_helper"

class TermTest < ActiveSupport::TestCase
  def vocabulary
    @vocabulary ||= gobierto_common_vocabularies(:animals)
  end

  def root_level_term
    @root_level_term ||= gobierto_common_terms(:mammal)
  end

  def dependent_level_term
    @dependent_level_term ||= gobierto_common_terms(:dog)
  end

  def site
    @site ||= sites(:madrid)
  end

  def test_valid
    assert root_level_term.valid?
    assert dependent_level_term.valid?
  end

  def test_creation_of_dependent_term
    new_term = root_level_term.terms.new(name_translations: { en: "Wolve", es: "Lobo" })
    assert new_term.valid?
    new_term.save
    assert_equal root_level_term.level + 1, new_term.level
    assert_equal vocabulary, new_term.vocabulary
    assert_equal 3, root_level_term.terms.count
    assert_equal root_level_term, new_term.parent_term
  end

  def test_creation_of_free_term
    new_term = vocabulary.terms.new(name_translations: { en: "Reptile", es: "Reptil" })
    assert new_term.valid?
    new_term.save
    assert_equal 0, new_term.level
    assert_equal vocabulary, new_term.vocabulary
    assert_equal nil, new_term.parent_term
    assert_equal 0, new_term.terms.count
  end
end
