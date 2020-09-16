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
    tsearch: { prefix: true , tsvector_column: "content_tsvector" }
  },
  ignoring: :accents
}
