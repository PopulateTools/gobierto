# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Charters
      class EditionsIntervalsController < GobiertoCitizensCharters::BaseController

        before_action :set_charter

        def index
          set_filter_counts

          @filter = available_intervals.include?(params[:period_interval]) ? params[:period_interval] : nil
          selected_intervals = @filter ? [@filter] : available_intervals
          @editions_intervals = CollectionDecorator.new(
            selected_intervals.map do |key|
              @charter.editions.group_by_period_interval(key).count
            end.reduce({}, :merge),
            decorator: ::GobiertoCitizensCharters::EditionIntervalDecorator
          )
        end

        def new
          @editions_interval_form = EditionsIntervalForm.new(
            period_interval: params[:period_interval],
            period: params[:period]
          )
          render(:new, layout: false) && return if request.xhr?
        end

        def create
          @editions_interval_form = EditionsIntervalForm.new(interval_params.merge(period: period_date))
          if @editions_interval_form.save
            redirect_to(
              admin_citizens_charters_charter_editions_path(
                @charter,
                period_interval: @editions_interval_form.period_interval,
                period: @editions_interval_form.period,
                new: true
              )
            )
          else
            render(:new, layout: false) && return if request.xhr?
            render :new
          end
        end

        protected

        def editions_relation
          ::GobiertoCitizensCharters::Edition
        end

        def available_intervals
          @available_intervals ||= editions_relation.period_intervals.keys
        end

        def set_charter
          @charter = current_site.charters.find(params[:charter_id])
        end

        def set_filter_counts
          @filter_counts = {}.tap do |counts|
            available_intervals.each do |interval|
              counts[interval] = @charter.editions.group_by_period_interval(interval).count.count
            end
          end
        end

        def date_attributes
          @date_attributes ||= [:year, :month, :day]
        end

        def period_date
          values = case interval_params[:period_interval]
                   when "year"
                     period_params[:period_discarded_month]
                   when "month", "quarter"
                     period_params[:period_discarded_day]
                   else
                     period_params[:period_discarded_nothing]
                   end.values_at(*date_attributes).reject(&:blank?)

          return nil if values.count != date_attributes.count

          values.join("-")
        end

        def interval_params
          params.require(:editions_interval).permit(:period_interval)
        end

        def period_params
          params.require(:editions_interval).permit(period_discarded_nothing: date_attributes,
                                                    period_discarded_day: date_attributes,
                                                    period_discarded_month: date_attributes)
        end

        def preview_url(charter, options = {})
          options[:preview_token] = current_admin.preview_token unless charter.active?
          charter_period_gobierto_citizens_charters_charter_url(charter.slug, options)
        end
      end
    end
  end
end
