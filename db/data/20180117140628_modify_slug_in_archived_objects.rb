# frozen_string_literal: true

class ModifySlugInArchivedObjects < ActiveRecord::Migration[5.1]
  def up
    ::GobiertoCalendars::Event.only_archived.each do |event|
      event.update_attribute(:slug, event.slug + "-slug-archived")
    end

    ::GobiertoCms::Page.only_archived.each do |page|
      page.update_attribute(:slug, page.slug + "-slug-archived")
    end

    ::GobiertoParticipation::ContributionContainer.only_archived.each do |contribution_container|
      contribution_container.update_attribute(:slug, contribution_container.slug + "-slug-archived")
    end

    ::GobiertoParticipation::Process.only_archived.each do |process|
      process.update_attribute(:slug, process.slug + "-slug-archived")
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
