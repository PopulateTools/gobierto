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
        settings = ::GobiertoAdmin::GobiertoParticipation::SettingsForm.new(site_id: site.id, issues_vocabulary_id: issues.id)
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

      Activity.where(subject_type: "Issue") do |activity|
        move_issue_to_term(
          issue: activity.subject,
          site: activity.site,
          target: activity,
          prefix: "subject"
        )
      end

      GobiertoParticipation::Process.where.not(issue_id: nil).each do |process|
        next if (issue = Issue.find_by_id(process.issue_id)).blank?
        site = process.site
        term = site.issues.find_by(name_translations: issue.name_translations)
        if term.blank?
          term = issues.terms.create(issue.attributes.except(*ignored_attributes))
        end
        process.update_attribute(:issue_id, term.id)
      end
    end

    desc "Generate a vocabulary for each site from existing scopes"
    task scopes: :environment do
      ignored_attributes = %w(id site_id created_at updated_at)
      Site.all.each do |site|
        next if site.scopes.blank?
        puts "== Migrating scopes of #{ site.domain }"
        scopes = site.vocabularies.find_or_create_by(name: "scopes")
        site.scopes.each do |scope|
          next if scopes.terms.where(slug: scope.slug).exists?
          term = scopes.terms.create(scope.attributes.except(*ignored_attributes))
          puts "== Created term of scopes vocabulary: #{ term.name }"
        end
      end
    end

    def move_issue_to_term(issue:, site:, target:, prefix:)
      term = site.issues.find_by(name_translations: issue.name_translations)
      return if term.blank?
      target.update_attributes("#{ prefix }_type" => "GobiertoCommon::Term", "#{ prefix }_id" => term.id)
    end
  end
end
