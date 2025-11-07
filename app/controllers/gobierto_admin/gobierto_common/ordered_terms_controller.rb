# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class OrderedTermsController < BaseController

      before_action :check_permissions!, except: [:index]

      def index
        @vocabulary = find_vocabulary
        @terms = tree(@vocabulary.terms)
      end

      def new
        @vocabulary = find_vocabulary
        @term_form = TermForm.new(site_id: current_site.id, vocabulary_id: @vocabulary.id)
        @parent_terms = parent_terms_for_select(@vocabulary.terms)

        render(:new_modal, layout: false) && return if request.xhr?
      end

      def edit
        @term = find_term
        @term_form = TermForm.new(
          @term.attributes.except(*ignored_term_attributes).merge(site_id: current_site.id)
        )
        @parent_terms = parent_terms_for_select(@term.vocabulary.terms.where.not(id: @term.id))

        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def create
        @vocabulary = find_vocabulary
        @term_form = TermForm.new(term_params.merge(site_id: current_site.id, vocabulary_id: @vocabulary.id))

        if @term_form.save
          track_create_activity

          redirect_to(
            index_path,
            notice: t(".success")
          )
        else
          render(:new_modal, layout: false) && return if request.xhr?
          @parent_terms = parent_terms_for_select(@vocabulary.terms)
          render :new
        end
      end

      def update
        @term = find_term
        @term_form = TermForm.new(
          term_params.merge(id: params[:id], site_id: current_site.id)
        )

        if @term_form.save
          track_update_activity

          redirect_to(
            index_path,
            notice: t(".success")
          )
        else
          @parent_terms = parent_terms_for_select(@term.vocabulary.terms.where.not(id: @term.id))
          render(:edit_modal, layout: false) && return if request.xhr?
          render :edit
        end
      end

      def destroy
        @term = find_term

        if @term.destroy
          redirect_to(
            index_path,
            notice: t(".success")
          )
        else
          redirect_to(
            index_path,
            alert: t(".destroy_failed", validation_errors: @term.errors.full_messages.to_sentence)
          )
        end
      end

      private

      def find_vocabulary
        params[:vocabulary_id] ? current_site.vocabularies.find(params[:vocabulary_id]) : nil
      end

      def index_path
        admin_common_vocabulary_terms_path(@vocabulary || @term.vocabulary)
      end

      def track_create_activity
        Publishers::GobiertoCommonTermActivity.broadcast_event("term_created", default_activity_params.merge(subject: @term_form.term))
      end

      def track_update_activity
        Publishers::GobiertoCommonTermActivity.broadcast_event("term_updated", default_activity_params.merge(subject: @term))
      end

      def default_activity_params
        { ip: remote_ip, author: current_admin, site_id: current_site.id }
      end

      def term_params
        params.require(:term).permit(
          :slug,
          :term_id,
          :external_id,
          name_translations: [*I18n.available_locales],
          description_translations: [*I18n.available_locales]
        )
      end

      def ignored_term_attributes
        %w(position created_at updated_at level term_id vocabulary_id)
      end

      def find_term
        current_site.terms.find(params[:id])
      end

      def parent_terms_for_select(relation)
        flatten_tree(relation).map do |term|
          [ActiveSupport::SafeBuffer.new("#{"&nbsp;" * 6 * term.level} #{term.name}".strip), term.id]
        end
      end

      def tree(relation)
        relation.order(position: :asc).where(level: relation.minimum(:level)).inject({}) do |tree, term|
          tree.merge(term.ordered_tree)
        end
      end

      def flatten_tree(relation, level = 0)
        level_relation = relation.where(level: level).order(position: :asc)
        return [] if level_relation.blank?

        level_relation.where(level: level).map do |node|
          [node, flatten_tree(node.terms, level + 1)].flatten
        end.flatten
      end

      def check_permissions!
        raise_module_not_allowed unless current_admin.can_edit_vocabularies?
      end
    end
  end
end
