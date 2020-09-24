# frozen_string_literal: true

module GobiertoCommon
  module ApiTokensConcern
    extend ActiveSupport::Concern

    included do
      helper_method :owner_type
    end

    def new
      @form = api_token_form_class.new(owner: owner)

      render("gobierto_admin/api_tokens/new_modal", layout: false) && return if request.xhr?

      render "gobierto_admin/api_tokens/new"
    end

    def create
      @form = api_token_form_class.new(api_token_params.merge(id: params[:id], owner: owner))
      if @form.save
        redirect_to(
          owner_path,
          notice: t("concerns.gobierto_common.api_tokens_concern.create.success")
        )
      else
        render("gobierto_admin/api_tokens/new_modal", layout: false) && return if request.xhr?

        render "gobierto_admin/api_tokens/new"
      end
    end

    def edit
      @form = api_token_form_class.new(api_token.attributes.except(*ignored_attributes).merge(owner: owner))

      render("gobierto_admin/api_tokens/edit_modal", layout: false) && return if request.xhr?

      render "gobierto_admin/api_tokens/edit"
    end

    def update
      @form = api_token_form_class.new(api_token_params.merge(id: params[:id], owner: owner))
      if @form.save
        redirect_to(
          owner_path,
          notice: t("concerns.gobierto_common.api_tokens_concern.update.success")
        )
      else
        render("gobierto_admin/api_tokens/edit_modal", layout: false) && return if request.xhr?

        render "gobierto_admin/api_tokens/edit"
      end
    end

    def destroy
      token = base_relation.secondary.find(params[:id])
      if token.destroy
        redirect_to owner_path, notice: t("concerns.gobierto_common.api_tokens_concern.destroy.success")
      else
        redirect_to owner_path, alert: t("concerns.gobierto_common.api_tokens_concern.destroy.failed")
      end
    end

    private

    def ignored_attributes
      %w(created_at updated_at admin_id user_id primary token)
    end

    def api_token
      @api_token ||= base_relation.find(params[:id])
    end

    def base_relation
      @base_relation ||= owner.api_tokens
    end

    def api_token_form_class
      ApiTokenForm
    end

    def api_token_params
      params.require(:api_token).permit(:name, :domain, :update_token)
    end
  end
end
