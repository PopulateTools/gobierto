# frozen_string_literal: true

module GobiertoPeople
  class PersonSerializer < ActiveModel::Serializer

    attributes(
      :id,
      :name,
      :email,
      :position,
      :positions,
      :positions_str,
      :positions_html,
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

    has_many :content_block_records, unless: :exclude_content_block_records?

    def url
      "#{object.to_url}#{date_range_query}"
    end

    def political_group
      object.political_group.try(:name)
    end

    def position
      positions.first
    end

    def positions
      charges[object.id]&.map(&:to_s) || []
    end

    def positions_html
      positions.map { |pos| "<span>#{pos}</span>" }.join
    end

    def positions_str
      positions.join(" ")
    end

    def exclude_content_block_records?
      instance_options[:exclude_content_block_records]
    end

    private

    def charges
      instance_options[:charges].presence || {}
    end

    def date_range_query
      "?#{instance_options[:date_range_query]}" if instance_options[:date_range_query].present?
    end

  end
end
