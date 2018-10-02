# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class VocabulariesController < BaseController

      before_action :check_permissions!

      def index
        @vocabularies = vocabularies_relation.order(updated_at: :desc)
      end

      def show
        @vocabulary = find_vocabulary
        @terms_count = @vocabulary.terms.count
      end

      def new
        @vocabulary_form = VocabularyForm.new(site_id: current_site.id)
        render(:new_modal, layout: false) && return if request.xhr?
      end

      def create
        @vocabulary_form = VocabularyForm.new(vocabulary_params.merge(site_id: current_site.id))

        if @vocabulary_form.save
          track_create_activity
          redirect_to(
            admin_common_vocabularies_path,
            notice: t(".success")
          )
        else
          render(:new_modal, layout: false) && return if request.xhr?
          render :new
        end
      end

      def edit
        vocabulary = find_vocabulary
        @vocabulary_form = VocabularyForm.new(vocabulary.attributes.except(*ignored_vocabulary_attributes).merge(site_id: current_site.id))
        render(:edit_modal, layout: false) && return if request.xhr?
      end

      def update
        @vocabulary_form = VocabularyForm.new(vocabulary_params.merge(id: params[:id], site_id: current_site.id))
        if @vocabulary_form.save
          track_update_activity
          redirect_to(
            admin_common_vocabularies_path,
            notice: t(".success")
          )
        else
          render(:edit_modal, layout: false) && return if request.xhr?
          render :edit
        end
      end

      def destroy
        vocabulary = find_vocabulary
        if vocabulary.destroy
          redirect_to admin_common_vocabularies_path, notice: t(".success")
        else
          redirect_to admin_common_vocabularies_path, alert: t(".destroy_failed")
        end
      end

      private

      def vocabulary_params
        params.require(:vocabulary).permit(:slug, name_translations: [*I18n.available_locales])
      end

      def ignored_vocabulary_attributes
        %w(created_at updated_at site_id)
      end

      def find_vocabulary
        vocabularies_relation.find(params[:id])
      end

      def vocabularies_relation
        current_site.vocabularies
      end

      def track_create_activity
        # pending
      end

      def track_update_activity
        # pending
      end

      def check_permissions!
        raise_module_not_allowed unless current_admin.can_edit_vocabularies?
      end
    end
  end
end
