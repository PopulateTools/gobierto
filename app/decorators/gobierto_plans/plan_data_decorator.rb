# frozen_string_literal: true

module GobiertoPlans
  class PlanDataDecorator < BaseDecorator
    def initialize(plan)
      @object = plan
    end

    def csv
      categories = CollectionDecorator.new(object.categories.where(level: object.categories.maximum(:level)).order(:position), decorator: CategoryTermDecorator)

      collection = []
      categories.each do |category|
        if category.nodes.exists?
          collection += category.nodes
        else
          collection << category
        end
      end

      return "" unless collection.present?
      CSV.generate do |csv|
        csv << RowNodeDecorator.new(collection.first).headers
        collection.each do |item|
          csv << RowNodeDecorator.new(item).object
        end
      end.force_encoding('utf-8')
    end
  end
end
