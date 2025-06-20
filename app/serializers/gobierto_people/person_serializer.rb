# frozen_string_literal: true

module GobiertoPeople
  class PersonSerializer < ActiveModel::Serializer

    attributes(
      :id,
      :name,
      :email,
      :position,
      :current_positions,
      :filtered_positions,
      :filtered_positions_str,
      :filtered_positions_html,
      :filtered_positions_tooltip,
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
      filtered_positions.first&.name
    end

    def current_positions
      positions = filtered_positions.select do |position|
        position.end_date.blank?
      end

      positions = [filtered_positions.first] if positions.blank?

      return "" if positions.blank?

      "<ul>" + positions.map { |pos| "<li>#{pos.name}</li>" }.join + "</ul>"
    end

    def filtered_positions
      @filtered_positions ||= charges[object.id] || []
    end

    def filtered_positions_html
      filtered_positions.map { |pos| "<span>#{pos}</span>" }.join
    end

    def filtered_positions_tooltip
      "<ul>" + filtered_positions.map { |pos| "<li>#{pos}</li>" }.join + "</ul>"
    end

    def filtered_positions_str
      filtered_positions.join(" ")
    end

    def exclude_content_block_records?
      instance_options[:exclude_content_block_records]
    end

    private

    def charges
      instance_options[:charges].presence || charges_query
    end

    def charges_query
      { object.id => object.historical_charges.between_dates(instance_options[:date_range_params]).with_department(instance_options[:department]).reverse_sorted }
    end

    def date_range_query
      "?#{instance_options[:date_range_query]}" if instance_options[:date_range_query].present?
    end

  end
end
