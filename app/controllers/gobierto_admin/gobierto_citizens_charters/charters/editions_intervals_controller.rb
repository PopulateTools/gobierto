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
        end

        def create
          @editions_interval_form = EditionsIntervalForm.new(editions_interval_params)
          if @editions_interval_form.save
            redirect_to(
              admin_citizens_charters_charter_editions_path(
                @charter,
                period_interval: @editions_interval_form.period_interval,
                period: @editions_interval_form.period
              )
            )
          else
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

        def editions_interval_params
          params.require(:editions_interval).permit(:period_interval, :period)
        end
      end
    end
  end
end
