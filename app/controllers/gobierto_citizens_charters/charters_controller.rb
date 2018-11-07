# frozen_string_literal: true

class GobiertoCitizensCharters::ChartersController < GobiertoCitizensCharters::ApplicationController

  def index
    @site = SiteDecorator.new(current_site)
    @resources_root = ::GobiertoCitizensCharters::CharterDecorator.new(
      params[:service_slug].present? ? current_site.services.active.find_by!(slug: params[:service_slug]) : current_site,
      opts: { reference_edition: params_reference_edition }
    )

    if params_reference_edition.present?
      @charters = CollectionDecorator.new(
        @resources_root.charters.active,
        decorator: ::GobiertoCitizensCharters::CharterDecorator,
        opts: { reference_edition: params_reference_edition }
      )
    else
      period_params = @resources_root.reference_edition.period_front_params
      path = if params[:service_slug].present?
               gobierto_citizens_charters_service_charters_period_path(params[:service_slug], period_params)
             else
               gobierto_citizens_charters_charters_period_path(period_params)
             end
      redirect_to path
    end
  end

  def show
    @charter = ::GobiertoCitizensCharters::CharterDecorator.new(
      current_site.charters.active.find_by!(slug: params[:slug]),
      opts: { reference_edition: params_reference_edition }
    )
    if params_reference_edition.present? && @charter.progress.present?
      @progress_evolution = 100 * (@charter.progress / @charter.previous_period_progress - 1) if @charter.progress&.nonzero? && @charter.previous_period_progress&.nonzero?
      @historic_data = @charter.editions.map do |edition|
        ["sparkline-#{ edition.id }", ::GobiertoCitizensCharters::CommitmentDecorator.new(edition.commitment).progress_history(params_reference_edition)]
      end.to_h
      @historic_data["sparkline-GLOBAL"] = @charter.progress_history
      @period_interval = %w(year month).include?(params_reference_edition.period_interval) ? "#{ params_reference_edition.period_interval }ly" : "daily"
    elsif (latest_edition = @charter.latest_edition_of_same_period_interval(@charter.reference_edition.period_interval) || @charter.latest_edition).present?
      redirect_to charter_period_gobierto_citizens_charters_charter_path(@charter.slug, latest_edition.period_front_params)
    end
  end

  def details
    @charter = current_site.charters.active.find_by!(slug: params[:slug])
  end

  private

  def params_reference_edition
    @params_reference_edition ||= GobiertoCitizensCharters::Edition.new(period_params) if period_params.present?
  end
end
