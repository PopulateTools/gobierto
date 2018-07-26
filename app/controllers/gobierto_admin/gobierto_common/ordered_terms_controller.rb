# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class OrderedTermsController < BaseController
      helper_method :term_preview_url

      def index
        @terms = current_site.send(association)
        @term_form = OrderedTermForm.new(site_id: current_site.id, association: association)
        @vocabulary = find_vocabulary
      end

      def new
        @term_form = OrderedTermForm.new(site_id: current_site.id, association: association)

        render(:new_modal, layout: false) && return if request.xhr?
      end

      def edit
        @term = find_term
        @term_form = OrderedTermForm.new(
          @term.attributes.except(*ignored_term_attributes).merge(site_id: current_site.id, association: association)
        )

        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def create
        @term_form = OrderedTermForm.new(term_params.merge(site_id: current_site.id, association: association))

        if @term_form.save
          track_create_activity

          redirect_to(
            admin_ordered_vocabulary_terms_path(module: params[:module], vocabulary: params[:vocabulary], id: @term),
            notice: t(".success", link: send(:"gobierto_participation_#{ params[:vocabulary] }_url", @term_form.term.slug, host: current_site.domain))
          )
        else
          render(:new_modal, layout: false) && return if request.xhr?
          render :new
        end
      end

      def update
        @term = find_term
        @term_form = OrderedTermForm.new(
          term_params.merge(id: params[:id], site_id: current_site.id, association: association)
        )

        if @term_form.save
          track_update_activity

          redirect_to(
            admin_ordered_vocabulary_terms_path(module: params[:module], vocabulary: params[:vocabulary], id: @term),
            notice: t(".success", link: send(:"gobierto_participation_#{ params[:vocabulary] }_url", @term_form.term.slug, host: current_site.domain))
          )
        else
          render(:edit_modal, layout: false) && return if request.xhr?
          render :edit
        end
      end

      def destroy
        @term = find_term

        if current_site.processes.where(association.singularize => @term).blank? && @term.destroy
          redirect_to admin_ordered_vocabulary_terms_path(module: params[:module], vocabulary: params[:vocabulary]), notice: t(".success")
        else
          redirect_to admin_ordered_vocabulary_terms_path(module: params[:module], vocabulary: params[:vocabulary]), alert: t(".destroy_failed")
        end
      end

      private

      def association
        @association ||= begin
                           if current_site.send(:"#{ params[:module] }_settings")&.send(:"#{ params[:vocabulary] }_vocabulary_id").present?
                             params[:vocabulary]
                           else
                             redirect_to(
                               admin_root_path,
                               alert: t(".not_defined")
                             )
                           end
                         end
      end

      def find_vocabulary
        current_site.vocabularies.find(current_site.send(:"#{ params[:module] }_settings")&.send(:"#{ params[:vocabulary] }_vocabulary_id"))
      end

      def track_create_activity
        case params[:vocabulary]
        when "issues"
          Publishers::IssueActivity.broadcast_event("issue_created", default_activity_params.merge(subject: @term_form.term))
        when "scopes"
          Publishers::ScopeActivity.broadcast_event("scope_created", default_activity_params.merge(subject: @term_form.term))
        end
      end

      def track_update_activity
        case params[:vocabulary]
        when "issues"
          Publishers::IssueActivity.broadcast_event("issue_updated", default_activity_params.merge(subject: @term))
        when "scopes"
          Publishers::ScopeActivity.broadcast_event("scope_updated", default_activity_params.merge(subject: @term))
        end
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def term_params
        params.require(:term).permit(
          :slug,
          name_translations: [*I18n.available_locales],
          description_translations: [*I18n.available_locales]
        )
      end

      def ignored_term_attributes
        %w(position created_at updated_at level term_id vocabulary_id)
      end

      def find_term
        current_site.send(association).find(params[:id])
      end

      def term_preview_url(term, options = {})
        options[:preview_token] = current_admin.preview_token unless term.active?
        send(:"gobierto_participation_#{ params[:vocabulary] }_url", term.slug, options)
      end
    end
  end
end
