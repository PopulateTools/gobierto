# frozen_string_literal: true

module GobiertoPeople
  module FilterByActivitiesHelper
    extend ActiveSupport::Concern

    private

    def filter_by_activities(source:, start_date: nil, end_date: nil)
      return source if start_date.blank? && end_date.blank?

      source.select do |item|
        events = item.events.published
        gifts = item.gifts
        trips = item.trips
        invitations = item.invitations

        if start_date.present?
          events = events.where("#{events.table_name}.starts_at >= ?", start_date)
          gifts = gifts.where("#{gifts.table_name}.date >= ?", start_date)
          trips = trips.where("#{trips.table_name}.start_date >= ?", start_date)
          invitations = invitations.where("#{invitations.table_name}.start_date >= ?", start_date)
        end

        if end_date.present?
          events = events.where("#{events.table_name}.ends_at <= ?", end_date)
          gifts = gifts.where("#{gifts.table_name}.date <= ?", end_date)
          trips = trips.where("#{trips.table_name}.end_date <= ?", end_date)
          invitations = invitations.where("#{invitations.table_name}.end_date <= ?", end_date)
        end
        events.exists? || gifts.exists? || trips.exists? || invitations.exists?
      end
    end
  end
end
