# frozen_string_literal: true

class ESQueryBuilder

  MAX_SIZE = 10_000

  def self.must(terms_hash)
    terms = terms_hash.map do |key, value|
      term_key = value.is_a?(Array) ? :terms : :term
      { term_key => { key.to_sym => value } }
    end

    {
      query: {
        filtered: {
          filter: {
            bool: {
              must: terms
            }
          }
        }
      }
    }
  end

end
