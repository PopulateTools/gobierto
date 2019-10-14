module GobiertoPeople
  class PersonSerializer < ActiveModel::Serializer

    attributes(
      :id,
      :name,
      :email,
      :position,
      :bio,
      :bio_url,
      :avatar_url,
      :category,
      :political_group,
      :party,
      :url,
      :created_at,
      :updated_at
    )

    has_many :content_block_records

    def url
      "#{object.to_url}#{date_range_query}"
    end

    def political_group
      object.political_group.try(:name)
    end

    def position
      object.charge
    end

    private

    def date_range_query
      "?#{instance_options[:date_range_query]}" if instance_options[:date_range_query].present?
    end

  end
end
