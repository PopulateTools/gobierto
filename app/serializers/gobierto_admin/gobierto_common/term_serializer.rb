# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class TermSerializer < ActiveModel::Serializer

      attributes :id, :name_translations

    end
  end
end
