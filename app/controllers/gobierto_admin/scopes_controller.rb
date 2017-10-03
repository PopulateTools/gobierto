# frozen_string_literal: true

module GobiertoAdmin
  class ScopesController < BaseController

    def index
      @scopes = current_site.scopes.sorted

      @scope_form = ScopeForm.new(site_id: current_site.id)
    end

    def show
      @scope = find_scope
    end

    def new
      @scope_form = ScopeForm.new

      render(:new_modal, layout: false) && return if request.xhr?
    end

    def edit
      @scope = find_scope
      @scope_form = ScopeForm.new(
        @scope.attributes.except(*ignored_scope_attributes)
      )

      render(:edit_modal, layout: false) && return if request.xhr?
    end

    def create
      @scope_form = ScopeForm.new(scope_params.merge(site_id: current_site.id))

      if @scope_form.save
        track_create_activity

        redirect_to(
          admin_scopes_path(@scope),
          notice: t('.success')
        )
      else
        render(:new_modal, layout: false) && return if request.xhr?
        render :new
      end
    end

    def update
      @scope = find_scope
      @scope_form = ScopeForm.new(
        scope_params.merge(id: params[:id])
      )

      if @scope_form.save
        track_update_activity

        redirect_to(
          admin_scopes_path(@scope),
          notice: t('.success')
        )
      else
        render(:edit_modal, layout: false) && return if request.xhr?
        render :edit
      end
    end

    def destroy
      @scope = find_scope

      if @scope.destroy
        redirect_to admin_scopes_path(@scope), notice: t('.success')
      else
        redirect_to admin_scopes_path(@scope), alert: t('.has_items')
      end
    end

    private

    def track_create_activity
      Publishers::ScopeActivity.broadcast_event('scope_created', default_activity_params.merge(subject: @scope_form.scope))
    end

    def track_update_activity
      Publishers::ScopeActivity.broadcast_event('scope_updated', default_activity_params.merge(subject: @scope))
    end

    def default_activity_params
      { ip: remote_ip, author: current_admin, site_id: current_site.id }
    end

    def scope_params
      params.require(:scope).permit(
        name_translations: [*I18n.available_locales],
        description_translations: [*I18n.available_locales]
      )
    end

    def ignored_scope_attributes
      %w(position created_at updated_at)
    end

    def find_scope
      current_site.scopes.find(params[:id])
    end
    
  end
end
