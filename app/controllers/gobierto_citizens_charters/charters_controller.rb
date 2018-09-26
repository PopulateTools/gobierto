# frozen_string_literal: true

class GobiertoCitizensCharters::ChartersController < GobiertoCitizensCharters::ApplicationController

  def index
    @service = ::GobiertoCitizensCharters::CharterDecorator.new(service, opts: { reference_edition: reference_edition })
    @charters = CollectionDecorator.new(base_relation.active, decorator: ::GobiertoCitizensCharters::CharterDecorator, opts: { reference_edition: @service.reference_edition })
  end

  def show
    @charter = ::GobiertoCitizensCharters::CharterDecorator.new(
      base_relation.find_by!(slug: params[:slug]),
      opts: { reference_edition: reference_edition }
    )
    @progress_evolution = 100 * (@charter.progress / @charter.previous_period_progress - 1) if @charter.progress&.nonzero? && @charter.previous_period_progress&.nonzero?
  end

  private

  def base_relation
    service.charters
  end

  def service
    @service ||= current_site.services.active.find_by!(slug: params[:service_slug])
  end

  def reference_edition
    @reference_edition ||= GobiertoCitizensCharters::Edition.new(period_params) if period_params.present?
  end
end
