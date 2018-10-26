# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Plan < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases
    include GobiertoCommon::Sluggable

    belongs_to :site
    belongs_to :plan_type
    belongs_to :categories_vocabulary, class_name: "GobiertoCommon::Vocabulary", foreign_key: :vocabulary_id
    has_many :categories, through: :categories_vocabulary, source: :terms, class_name: "GobiertoCommon::Term"

    translates :title, :introduction, :footer

    enum visibility_level: { draft: 0, published: 1 }

    after_restore :set_slug

    validates :site, :title, :introduction, :plan_type_id, :year, presence: true
    validates :slug, uniqueness: { scope: :site }

    scope :sort_by_updated_at, -> { order(updated_at: :desc) }
    scope :sort_by_year, -> { order(year: :desc) }

    def configuration_data
      data = read_attribute(:configuration_data)
      JSON.parse(data) unless data.empty?
    end

    def nodes
      Node.joins(categories: [:vocabulary]).where(terms: { vocabulary_id: categories_vocabulary&.id })
    end

    def levels
      categories.maximum("level")
    end

    def node_size
      nodes.count
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
