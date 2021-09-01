# frozen_string_literal: true

module GobiertoCms
  class PagesCollection < GobiertoCommon::Collection
    default_scope -> { where(item_type: "GobiertoCms::Page") }
  end
end
