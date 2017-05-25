# frozen_string_literal: true

namespace :gobierto_core do
  namespace :globalize do
    desc 'Migrates sites fields to globalize'
    task migrate_sites: :environment do
      Site.find_each do |site|
        puts "* Migrating site id=#{site.id}"

        I18n.available_locales.map(&:to_s).each do |locale|
          site.send "title_#{locale}=", site.read_attribute(:title)
          site.send "name_#{locale}=", site.read_attribute(:name)
        end

        site.save!
      end
    end
  end
end
