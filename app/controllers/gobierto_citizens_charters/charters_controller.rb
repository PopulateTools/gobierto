# frozen_string_literal: true

class GobiertoCitizensCharters::ChartersController < GobiertoCitizensCharters::ApplicationController

  def index
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
    if params_reference_edition.present?
      @progress_evolution = 100 * (@charter.progress / @charter.previous_period_progress - 1) if @charter.progress&.nonzero? && @charter.previous_period_progress&.nonzero?
    else
      redirect_to charter_period_gobierto_citizens_charters_charter_path(@charter.slug, @charter.reference_edition.period_front_params)
    end
  end

  private

  def params_reference_edition
    @params_reference_edition ||= GobiertoCitizensCharters::Edition.new(period_params) if period_params.present?
  end
end
