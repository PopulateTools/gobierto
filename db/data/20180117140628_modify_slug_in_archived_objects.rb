# frozen_string_literal: true

class ModifySlugInArchivedObjects < ActiveRecord::Migration[5.1]
  def up
    ::GobiertoCalendars::Event.only_archived.each do |event|
      event.update_attribute(:slug, event.slug + "archived-" + event.id.to_s)
    end

    ::GobiertoCms::Page.only_archived.each do |page|
      page.update_attribute(:slug, page.slug + "archived-" + page.id.to_s)
    end

    ::GobiertoParticipation::ContributionContainer.only_archived.each do |contribution_container|
      contribution_container.update_attribute(:slug, "archived-" + contribution_container.id.to_s)
    end

    ::GobiertoParticipation::Process.only_archived.each do |process|
      process.update_attribute(:slug, "archived-" + process.id.to_s)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
