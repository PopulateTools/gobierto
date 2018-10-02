# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class TermsController < BaseController

      before_action :check_permissions!

      def index
        @terms = tree(terms_relation)
      end

      def show
        @term = find_term
      end

      def new
        @term_form = TermForm.new(site_id: current_site.id, vocabulary_id: vocabulary.id)
        @parent_terms = parent_terms_for_select(terms_relation)
        @parent_term = nil
      end

      def create
        @term_form = TermForm.new(term_params.merge(site_id: current_site.id, vocabulary_id: vocabulary.id))

        if @term_form.save
          redirect_to(
            edit_admin_common_term_path(@term_form.term),
            notice: t(".success")
          )
        else
          @parent_terms = parent_terms_for_select(terms_relation)
          @parent_term = @term_form.term&.parent_term
          render :new
        end
      end

      def edit
        term = find_term
        @term_form = TermForm.new(term.attributes.except(*ignored_term_attributes).merge(site_id: current_site.id))
        @vocabulary ||= term.vocabulary
        @parent_terms = parent_terms_for_select(terms_relation.where.not(id: term.id))
        @parent_term = term.term_id
      end

      def update
        term = find_term
        @term_form = TermForm.new(term_params.merge(id: params[:id], site_id: current_site.id, vocabulary_id: term.vocabulary_id))
        if @term_form.save
          redirect_to(
            edit_admin_common_term_path(@term_form.term),
            notice: t(".success")
          )
        else
          @vocabulary ||= term.vocabulary
          @parent_terms = parent_terms_for_select(terms_relation.where.not(id: term.id))
          @parent_term = term.term_id
          render :edit
        end
      end

      def destroy
        term = find_term
        @vocabulary ||= term.vocabulary
        if term.destroy
          redirect_to admin_common_vocabulary_terms_path(@vocabulary), notice: t(".success")
        else
          redirect_to admin_common_vocabulary_terms_path(@vocabulary), alert: t(".destroy_failed")
        end
      end

      private

      def term_params
        params.require(:term).permit(
          :slug,
          :term_id,
          name_translations: [*I18n.available_locales],
          description_translations: [*I18n.available_locales]
        )
      end

      def ignored_term_attributes
        %w(created_at updated_at site_id level position)
      end

      def find_term
        terms_relation.find(params[:id])
      end

      def vocabulary
        @vocabulary ||= params[:vocabulary_id] ? current_site.vocabularies.find(params[:vocabulary_id]) : nil
      end

      def parent_terms_for_select(relation)
        relation.map do |term|
          [term.name, term.id]
        end
      end

      def terms_relation
        (vocabulary || current_site).terms
      end

      def tree(relation, level = 0)
        level_relation = relation.where(level: level).order(position: :asc)
        return [] if level_relation.blank?
        relation.where(level: level).map do |node|
          [node, tree(node.terms, level + 1)].flatten
        end.flatten
      end

      def check_permissions!
        raise_module_not_allowed unless current_admin.can_edit_vocabularies?
      end
    end
  end
end
