# frozen_string_literal: true

require "test_helper"

class GobiertoLocaleInflectionsTest < ActiveSupport::TestCase
  def femenine_word_starting_with_vowel(locale)
    with_locale(locale) do
      I18n::Inflections::Base.create_with_locale("ostra", gender: :f)
    end
  end

  def masculine_word_starting_with_vowel(locale)
    with_locale(locale) do
      I18n::Inflections::Base.create_with_locale("emo", gender: :m)
    end
  end

  def femenine_word_starting_with_consonant(locale)
    with_locale(locale) do
      I18n::Inflections::Base.create_with_locale("rambla", gender: :f)
    end
  end

  def masculine_word_starting_with_consonant(locale)
    with_locale(locale) do
      I18n::Inflections::Base.create_with_locale("rastro", gender: :m)
    end
  end

  def with_locale(locale)
    initial_locale = locale
    I18n.locale = locale
    yield
  ensure
    I18n.locale = initial_locale
  end

  def test_pronouns
    assert_equal "l'ostra", femenine_word_starting_with_vowel(:ca).the
    assert_equal "l'emo", masculine_word_starting_with_vowel(:ca).the
    assert_equal "la rambla", femenine_word_starting_with_consonant(:ca).the
    assert_equal "el rastro", masculine_word_starting_with_consonant(:ca).the

    assert_equal "la ostra", femenine_word_starting_with_vowel(:es).the
    assert_equal "el emo", masculine_word_starting_with_vowel(:es).the
    assert_equal "la rambla", femenine_word_starting_with_consonant(:es).the
    assert_equal "el rastro", masculine_word_starting_with_consonant(:es).the

    assert_equal "the ostra", femenine_word_starting_with_vowel(:en).the
    assert_equal "the emo", masculine_word_starting_with_vowel(:en).the
    assert_equal "the rambla", femenine_word_starting_with_consonant(:en).the
    assert_equal "the rastro", masculine_word_starting_with_consonant(:en).the
  end

  def test_possesive
    assert_equal "la teva ostra", femenine_word_starting_with_vowel(:ca).your
    assert_equal "el teu emo", masculine_word_starting_with_vowel(:ca).your
    assert_equal "la teva rambla", femenine_word_starting_with_consonant(:ca).your
    assert_equal "el teu rastro", masculine_word_starting_with_consonant(:ca).your

    assert_equal "tu ostra", femenine_word_starting_with_vowel(:es).your
    assert_equal "tu emo", masculine_word_starting_with_vowel(:es).your
    assert_equal "tu rambla", femenine_word_starting_with_consonant(:es).your
    assert_equal "tu rastro", masculine_word_starting_with_consonant(:es).your

    assert_equal "your ostra", femenine_word_starting_with_vowel(:en).your
    assert_equal "your emo", masculine_word_starting_with_vowel(:en).your
    assert_equal "your rambla", femenine_word_starting_with_consonant(:en).your
    assert_equal "your rastro", masculine_word_starting_with_consonant(:en).your
  end

  def test_preposition_and_possesive
    assert_equal "de la nostra ostra", femenine_word_starting_with_vowel(:ca).of_our
    assert_equal "del nostre emo", masculine_word_starting_with_vowel(:ca).of_our
    assert_equal "de la nostra rambla", femenine_word_starting_with_consonant(:ca).of_our
    assert_equal "del nostre rastro", masculine_word_starting_with_consonant(:ca).of_our

    assert_equal "de nuestra ostra", femenine_word_starting_with_vowel(:es).of_our
    assert_equal "de nuestro emo", masculine_word_starting_with_vowel(:es).of_our
    assert_equal "de nuestra rambla", femenine_word_starting_with_consonant(:es).of_our
    assert_equal "de nuestro rastro", masculine_word_starting_with_consonant(:es).of_our

    assert_equal "of our ostra", femenine_word_starting_with_vowel(:en).of_our
    assert_equal "of our emo", masculine_word_starting_with_vowel(:en).of_our
    assert_equal "of our rambla", femenine_word_starting_with_consonant(:en).of_our
    assert_equal "of our rastro", masculine_word_starting_with_consonant(:en).of_our
  end

  def test_of_the_particle
    assert_equal "de l'ostra", femenine_word_starting_with_vowel(:ca).of_the
    assert_equal "de l'emo", masculine_word_starting_with_vowel(:ca).of_the
    assert_equal "de la rambla", femenine_word_starting_with_consonant(:ca).of_the
    assert_equal "del rastro", masculine_word_starting_with_consonant(:ca).of_the

    assert_equal "de la ostra", femenine_word_starting_with_vowel(:es).of_the
    assert_equal "del emo", masculine_word_starting_with_vowel(:es).of_the
    assert_equal "de la rambla", femenine_word_starting_with_consonant(:es).of_the
    assert_equal "del rastro", masculine_word_starting_with_consonant(:es).of_the

    assert_equal "of the ostra", femenine_word_starting_with_vowel(:en).of_the
    assert_equal "of the emo", masculine_word_starting_with_vowel(:en).of_the
    assert_equal "of the rambla", femenine_word_starting_with_consonant(:en).of_the
    assert_equal "of the rastro", masculine_word_starting_with_consonant(:en).of_the
  end

  def test_to_your_particle
    assert_equal "a la teva ostra", femenine_word_starting_with_vowel(:ca).to_your
    assert_equal "al teu emo", masculine_word_starting_with_vowel(:ca).to_your
    assert_equal "a la teva rambla", femenine_word_starting_with_consonant(:ca).to_your
    assert_equal "al teu rastro", masculine_word_starting_with_consonant(:ca).to_your

    assert_equal "a tu ostra", femenine_word_starting_with_vowel(:es).to_your
    assert_equal "a tu emo", masculine_word_starting_with_vowel(:es).to_your
    assert_equal "a tu rambla", femenine_word_starting_with_consonant(:es).to_your
    assert_equal "a tu rastro", masculine_word_starting_with_consonant(:es).to_your

    assert_equal "your ostra", femenine_word_starting_with_vowel(:en).to_your
    assert_equal "your emo", masculine_word_starting_with_vowel(:en).to_your
    assert_equal "your rambla", femenine_word_starting_with_consonant(:en).to_your
    assert_equal "your rastro", masculine_word_starting_with_consonant(:en).to_your
  end
end
