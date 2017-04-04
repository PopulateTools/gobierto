namespace :gobierto_cms do
  namespace :globalize do
    desc "Migrates pages fields to globalize"
    task migrate: :environment do
      GobiertoCms::Page.find_each do |page|
        puts "* Migrating page id=#{page.id}"

        I18n.available_locales.map(&:to_s).each do |locale|
          page.send "title_#{locale}=", page.read_attribute(:title)
          page.send "body_#{locale}=", page.read_attribute(:body)
          page.send "slug_#{locale}=", page.read_attribute(:slug)
        end

        page.save!
      end
    end
  end
end
