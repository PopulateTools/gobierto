# frozen_string_literal: true

module GobiertoPeople
  class RowchartItemSerializer < ActiveModel::Serializer

    attributes :key, :value, :properties

    def key
      object.name
    end

    def value
      object.attributes["events_count"] || object.events.count
    end

    def properties
      { url: object.to_url }
    end

  end
end
