module GobiertoPeople
  class PersonSerializer < ActiveModel::Serializer

    attributes :name, :charge, :url

    def url
      "#{object.to_url}#{date_range_query}"
    end

    private

    def date_range_query
      "?#{instance_options[:date_range_query]}" if instance_options[:date_range_query].present?
    end

  end
end
