# frozen_string_literal: true

namespace :common do
  namespace :migrate_to_vocabularies do
    desc "Generate a vocabulary for each site from existing issues"
    task issues: :environment do
      ignored_attributes = %w(id site_id created_at updated_at)
      Site.all.each do |site|
        next if Issue.where(site: site).blank?
        puts "== Migrating issues of #{ site.domain }"
        issues = site.vocabularies.find_or_create_by(name: "issues")
        scopes_vocabulary_id = site.gobierto_participation_settings&.scopes_vocabulary_id
        settings = ::GobiertoAdmin::GobiertoParticipation::SettingsForm.new(site_id: site.id, issues_vocabulary_id: issues.id, scopes_vocabulary_id: scopes_vocabulary_id)
        settings.save
        Issue.where(site: site).each do |issue|
          next if issues.terms.where(slug: issue.slug).exists?
          term = issues.terms.create(issue.attributes.except(*ignored_attributes))
          puts "== Created term of issues vocabulary: #{ term.name }"
        end
      end

      GobiertoCommon::Collection.where(container_type: "Issue").each do |collection|
        move_issue_to_term(
          issue: collection.container,
          site: collection.site,
          target: collection,
          prefix: "container"
        )
      end

      GobiertoCommon::CollectionItem.where(container_type: "Issue").each do |collection_item|
        move_issue_to_term(
          issue: collection_item.container,
          site: collection_item.collection.site,
          target: collection_item,
          prefix: "container"
        )
      end

      Activity.where(subject_type: "Issue").each do |activity|
        issue = activity.subject || activity.site.issues.find_by_id(activity.subject_id)
        move_issue_to_term(
          issue: issue,
          site: activity.site,
          target: activity,
          prefix: "subject"
        )
      end

      User::Subscription.where(subscribable_type: "Issue").each do |subscription|
        issue = subscription.subscribable || subscription.site.issues.find_by_id(subscription.subscribable_id)
        move_issue_to_term(
          issue: subscription.subscribable,
          site: subscription.site,
          target: subscription,
          prefix: "subscribable"
        )
      end

      GobiertoParticipation::Process.where.not(issue_id: nil).each do |process|
        site = process.site
        next if (issue = Issue.where(site: site).find_by_id(process.issue_id)).blank?
        term = site.issues.find_by(name_translations: issue.name_translations)
        if term.blank?
          term = site.issues.terms.create(issue.attributes.except(*ignored_attributes))
        end
        process.update_attribute(:issue_id, term.id)
      end
    end

    desc "Generate a vocabulary for each site from existing scopes"
    task scopes: :environment do
      ignored_attributes = %w(id site_id created_at updated_at)
      Site.all.each do |site|
        next if GobiertoCommon::Scope.where(site: site).blank?
        puts "== Migrating scopes of #{ site.domain }"
        scopes = site.vocabularies.find_or_create_by(name: "scopes")
        issues_vocabulary_id = site.gobierto_participation_settings&.issues_vocabulary_id
        settings = ::GobiertoAdmin::GobiertoParticipation::SettingsForm.new(site_id: site.id, scopes_vocabulary_id: scopes.id, issues_vocabulary_id: issues_vocabulary_id)
        settings.save
        GobiertoCommon::Scope.where(site: site).each do |scope|
          next if scopes.terms.where(slug: scope.slug).exists?
          term = scopes.terms.create(scope.attributes.except(*ignored_attributes))
          puts "== Created term of scopes vocabulary: #{ term.name }"
        end
      end

      GobiertoCommon::Collection.where(container_type: "GobiertoCommon::Scope").each do |collection|
        move_scope_to_term(
          scope: collection.container,
          site: collection.site,
          target: collection,
          prefix: "container"
        )
      end

      GobiertoCommon::CollectionItem.where(container_type: "GobiertoCommon::Scope").each do |collection_item|
        move_scope_to_term(
          scope: collection_item.container,
          site: collection_item.collection.site,
          target: collection_item,
          prefix: "container"
        )
      end

      Activity.where(subject_type: "GobiertoCommon::Scope").each do |activity|
        scope = activity.subject || activity.site.scopes.find_by_id(activity.subject_id)
        move_scope_to_term(
          scope: scope,
          site: activity.site,
          target: activity,
          prefix: "subject"
        )
      end

      User::Subscription.where(subscribable_type: "GobiertoCommon::Scope").each do |subscription|
        scope = subscription.subscribable || subscription.site.scopes.find_by_id(subscription.subscribable_id)
        move_scope_to_term(
          scope: subscription.subscribable,
          site: subscription.site,
          target: subscription,
          prefix: "subscribable"
        )
      end

      GobiertoParticipation::Process.where.not(scope_id: nil).each do |process|
        site = process.site
        next if (scope = GobiertoCommon::Scope.where(site: site).find_by_id(process.scope_id)).blank?
        term = site.scopes.find_by(name_translations: scope.name_translations)
        if term.blank?
          term = site.scopes.terms.create(scope.attributes.except(*ignored_attributes))
        end
        process.update_attribute(:scope_id, term.id)
      end
    end

    desc "Generate a vocabulary for each site from existing political groups"
    task political_groups: :environment do
      GobiertoPeople::Person.where.not(political_group_id: nil).each do |person|
        move_political_group_to_term(person)
      end
    end

    desc "Generate a vocabulary for each existing plan and create terms from categories"
    task plans: :environment do
      id_transformations = {}
      GobiertoPlans::Plan.where(vocabulary_id: nil).each do |plan|
        site = plan.site
        I18n.locale = site.configuration.default_locale
        categories = GobiertoPlans::Category.where(plan: plan)
        vocabulary = site.vocabularies.find_or_create_by(name_translations: plan.title_translations)
        plan.update(vocabulary_id: vocabulary.id)

        sorted_uids = categories.map(&:uid).sort

        categories.each do |category|
          if category.name_translations.blank?
            category.name = "Missing"
            category.save!
          end
          position = sorted_uids.index(category.uid)
          term = create_term_from_category(category, sorted_uids, vocabulary)
          id_transformations[category.id] = term.id
        end
      end

      ActiveRecord::Base.transaction do
        replace_category_id_with_term_id_in_categories_nodes_table(id_transformations)
      end
    end

    def create_term_from_category(category, sorted_uids, vocabulary)
      ignored_attributes = %w(id parent_id plan_id created_at updated_at progress uid)
      parent_term = if (parent_category = category.parent_category).present?
                      create_term_from_category(parent_category, sorted_uids, vocabulary)
                    end
      term = vocabulary.terms.find_or_initialize_by(category.attributes.except(*ignored_attributes).merge(term_id: parent_term&.id))
      if term.new_record?
        term.slug = "#{ term.slug }-#{ vocabulary.terms.where(name_translations: term.name_translations).count + 1 }" if vocabulary.terms.where(slug: term.slug).exists?
        term.position = sorted_uids.index(category.uid)
      end
      term.save!
      term
    end

    def replace_category_id_with_term_id_in_categories_nodes_table(id_transformations)
      GobiertoPlans::CategoriesNode.all.each do |record|
        record.update(category_id: id_transformations[record.category_id]) if id_transformations.has_key?(record.category_id)
      end
    end

    def move_political_group_to_term(person)
      return unless (political_group = GobiertoPeople::PoliticalGroup.find_by_id(person.political_group_id)).present?
      ignored_attributes = %w(id site_id admin_id created_at updated_at name)
      site = person.site
      default_locale = site.configuration.default_locale
      I18n.locale = default_locale
      vocabulary = site.vocabularies.find_or_create_by(name: I18n.t("gobierto_people.people_filter.political_groups.title"))
      settings = site.gobierto_people_settings
      unless settings.political_groups_vocabulary_id == vocabulary.id
        settings.tap do |conf|
          conf.political_groups_vocabulary_id = vocabulary.id
        end.save
      end
      terms = vocabulary.terms
      term = terms.find_by(slug: political_group.slug) ||
             terms.create(political_group.attributes.except(*ignored_attributes).merge("name_#{ default_locale }" => political_group.name))
      person.update_attribute(:political_group_id, term.id)
    end

    def move_issue_to_term(issue:, site:, target:, prefix:)
      return if issue.blank?
      term = site.issues.find_by(name_translations: issue.name_translations)
      return if term.blank?
      target.update_attributes("#{ prefix }_type" => "GobiertoCommon::Term", "#{ prefix }_id" => term.id)
    end

    def move_scope_to_term(scope:, site:, target:, prefix:)
      return if scope.blank?
      term = site.scopes.find_by(name_translations: scope.name_translations)
      return if term.blank?
      target.update_attributes("#{ prefix }_type" => "GobiertoCommon::Term", "#{ prefix }_id" => term.id)
    end
  end
end
