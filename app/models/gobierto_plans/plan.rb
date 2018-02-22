# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Plan < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::Sluggable

    belongs_to :site
    belongs_to :plan_type
    has_many :categories
    has_many :nodes, through: :categories

    translates :title, :introduction, :title_for_menu

    enum visibility_level: { draft: 0, published: 1 }

    after_restore :set_slug

    validates :site, :title, :introduction, :title_for_menu, :plan_type_id, presence: true

    def configuration_data
      data = read_attribute(:configuration_data)
      JSON.parse(data) unless data.empty?
    end

    def levels
      categories.maximum("level")
    end

    def node_size
      nodes.size
    end

    def to_s
      text = ""
      # "5 cats, 43 subcats, 151 subsubcats, 161 nodes"
      if levels && levels.positive?
        (0..(levels)).each do |level|
          category_size = categories.where(level: level).size
          text += category_size.to_s + " " + level_key(category_size, level) + ", "
        end
      end

      if nodes.any?
        text += node_size.to_s + " " + level_key(node_size, levels + 1)
      end

      text
    end

    def attributes_for_slug
      [title]
    end

    private

    def level_key(level_size, level)
      configuration_data["level" + level.to_s][level_size == 1 ? "one" : "other"][I18n.locale.to_s]
    end
  end
end
