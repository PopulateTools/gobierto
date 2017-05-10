module GobiertoPeople
  module SearchableBySlug
    extend ActiveSupport::Concern

    included do

      def self.generate_unique_slug(string, date = nil)
        base_slug = string.parameterize(separator: '-')

        base_slug.prepend("#{date.strftime('%F')}-") if date

        taken_slugs = self.where("slug LIKE ?", "#{base_slug}%").pluck(:slug)

        return base_slug unless taken_slugs.include?(base_slug)

        count = 2
        while true
          new_slug = "#{base_slug}_#{count}"
          return new_slug unless taken_slugs.include?(new_slug)
          count += 1
        end
      end

    end

  end
end
