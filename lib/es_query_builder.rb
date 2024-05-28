# frozen_string_literal: true

class ESQueryBuilder

  MAX_SIZE = 10_000

  def self.must(terms_hash)
    {
      query: {
        bool: {
          must: terms(terms_hash)
        }
      }
    }
  end

  def self.terms(terms_hash)
    terms_hash.map do |key, value|
      term_key = value.is_a?(Array) ? :terms : :term
      { term_key => { key.to_sym => value } }
    end
  end

end
