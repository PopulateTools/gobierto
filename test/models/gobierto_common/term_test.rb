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

  def terms_with_dependencies
    @terms_with_dependencies ||= {
      issue:  gobierto_common_terms(:culture_term),
      scope:  gobierto_common_terms(:center_term),
      political_group: gobierto_common_terms(:marvel_term)
    }
  end

  def term_without_dependencies
    @term_without_dependencies ||= gobierto_common_terms(:cat)
  end

  def site
    @site ||= sites(:madrid)
  end

  def mammal
    @mammal ||= gobierto_common_terms(:mammal)
  end

  def cat
    @cat ||= gobierto_common_terms(:cat)
  end

  def dog
    @dog ||= gobierto_common_terms(:dog)
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
    assert_nil new_term.parent_term
    assert_equal 0, new_term.terms.count
  end

  def test_destroy_of_term_with_dependencies
    terms_with_dependencies.each do |_, term|
      refute term.destroy
    end
  end

  def test_destroy_of_term_without_dependencies
    assert term_without_dependencies.destroy
  end

  def test_update_parents_and_positions_to_root_level
    positions_from_params = { "0" => [ term_without_dependencies.id, mammal ] }

    assert GobiertoCommon::Term.update_parents_and_positions(positions_from_params)
    term_without_dependencies.reload
    assert_equal 0, term_without_dependencies.level
    assert_equal 0, term_without_dependencies.position
    assert_nil term_without_dependencies.term_id

    mammal.reload
    assert_equal 1, mammal.position
  end

  def test_update_parents_and_positions_reorder
    positions_from_params = { "0" => [ term_without_dependencies.id, mammal ], mammal.id.to_s => [cat.id, dog.id] }

    assert GobiertoCommon::Term.update_parents_and_positions(positions_from_params)

    cat.reload
    assert_equal 0, cat.position
    dog.reload
    assert_equal 1, dog.position
  end

  def test_update_parents_and_positions_update_parent
    positions_from_params = { "0" => [ term_without_dependencies.id, mammal ], term_without_dependencies.id.to_s => [cat.id, dog.id] }

    assert GobiertoCommon::Term.update_parents_and_positions(positions_from_params)

    cat.reload
    assert_equal 0, cat.position
    assert_equal term_without_dependencies, cat.parent_term
    dog.reload
    assert_equal 1, dog.position
    assert_equal term_without_dependencies, dog.parent_term
  end
end
