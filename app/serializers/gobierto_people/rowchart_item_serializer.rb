# frozen_string_literal: true

module GobiertoPeople
  class RowchartItemSerializer < ActiveModel::Serializer

    attributes :key, :value, :properties

    def key
      object.name
    end

    def value
      object.attributes["custom_events_count"]
    end

    def properties
      { url: object.to_url }
    end

  end
end
