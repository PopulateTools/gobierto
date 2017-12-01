# frozen_string_literal: true

namespace :db do
  namespace :data do
    desc "Anonymize names and phone numbers"
    task anonymize: :environment do
      if ENV["RAILS_ENV"] == "production"
        puts "Refusing to anonymize production data. You don't really want to do that."
      else
        puts "Anonymizing all Users in the #{ENV["RAILS_ENV"]} database."

        User.all.each do |user|
          seed = Digest::SHA1.hexdigest("#{Time.current}#{rand(100)}#{user.id}")[0..19]

          user.name = "user #{seed}"
          user.email = "user-#{seed}@gobierto.tools"
          user.bio = nil
          user.date_of_birth = "2000-07-06"
          user.password = "gobierto"
          user.password_confirmation = "gobierto"
          puts "Saving #{user.name} (#{user.email})"
          user.save!
        end

        puts "Anonymizing all Admins in the #{ENV["RAILS_ENV"]} database."

        GobiertoAdmin::Admin.all.each do |admin|
          unless admin.god?
            seed = Digest::SHA1.hexdigest("#{Time.current}#{rand(100)}#{admin.id}")[0..19]
            admin.name = "admin #{seed}" unless admin.email.include?("populate.tools")
            admin.email = "admin-#{seed}@gobierto.tools" unless admin.email.include?("populate.tools")
          end
          admin.password = "gobierto"
          admin.password_confirmation = "gobierto"
          puts "Saving #{admin.name} (#{admin.email})"
          admin.save!
        end

        puts "Anonymizing all Persons in the #{ENV["RAILS_ENV"]} database."

        GobiertoPeople::Person.all.each do |person|
          seed = Digest::SHA1.hexdigest("#{Time.current}#{rand(100)}#{person.id}")[0..19]

          person.name = "person #{seed}"
          person.email = "person-#{seed}@gobierto.tools"
          person.slug = "person-#{seed}"
          puts "Saving #{person.name} (#{person.email})"
          person.save!
        end

        puts "Changing all Sites to gobierto.dev in the #{ENV["RAILS_ENV"]} database."

        Site.all.each do |site|
          subdomain = site.domain.split('.').first
          site.domain = subdomain + ".gobierto.dev"
          site.save
        end

        puts "Remember map site domains in /etc/hosts"
      end
    end
  end
end
