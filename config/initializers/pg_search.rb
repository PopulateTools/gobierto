# frozen_string_literal: true

module PgSearch
  class Document
    belongs_to :site
    translates :title, :description

    belongs_to :searchable, polymorphic: true, optional: true
  end
end

PgSearch.multisearch_options = {
  using: {
    tsearch: { prefix: true },
    trigram: { word_similarity: true }
  },
  ignoring: :accents
}
