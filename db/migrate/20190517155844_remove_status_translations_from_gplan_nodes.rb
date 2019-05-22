# frozen_string_literal: true

class RemoveStatusTranslationsFromGplanNodes < ActiveRecord::Migration[5.2]
  def up
    GobiertoPlans::Plan.all.each do |plan|
      terms = plan.nodes.map(&:status_translations).uniq
      next if [[nil], [{}]].include?(terms)

      if plan.statuses_vocabulary.blank?
        name_translations = plan.title_translations.clone

        { "es" => "Estados de ",
          "en" => "Statuses of ",
          "ca" => "Estats de " }.each do |locale, prefix|
          name_translations[locale] = prefix + name_translations[locale] if name_translations[locale].present?
        end

        statuses_vocabulary = GobiertoCommon::Vocabulary.create(site: plan.site, name_translations: name_translations)
        plan.update_attribute(:statuses_vocabulary_id, statuses_vocabulary.id)
      end
      statuses_terms = plan.statuses_vocabulary.terms

      plan.nodes.each do |node|
        term = statuses_terms.find_or_create_by(name_translations: node.status_translations)
        node.update_attribute(:status_id, term.id)
      end
    end

    remove_column :gplan_nodes, :status_translations
  end

  def down
    add_column :gplan_nodes, :status_translations, :jsonb

    GobiertoPlans::Node.all.each do |node|
      next if node.status.blank?

      node.update_attribute(:status_translations, node.status.name_translations)
    end
  end
end
