# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class VocabulariesController < BaseController

      def index
        @vocabularies = vocabularies_relation.order(updated_at: :desc)
      end

      def show
        @vocabulary = find_vocabulary
        @terms_count = @vocabulary.terms.count
      end

      def new
        @vocabulary_form = VocabularyForm.new(site_id: current_site.id)
      end

      def create
        @vocabulary_form = VocabularyForm.new(vocabulary_params.merge(site_id: current_site.id))

        if @vocabulary_form.save
          track_create_activity
          redirect_to(
            edit_admin_common_vocabulary_path(@vocabulary_form.vocabulary),
            notice: t(".success")
          )
        else
          render :new
        end
      end

      def edit
        vocabulary = find_vocabulary
        @vocabulary_form = VocabularyForm.new(vocabulary.attributes.except(*ignored_vocabulary_attributes).merge(site_id: current_site.id))
      end

      def update
        @vocabulary_form = VocabularyForm.new(vocabulary_params.merge(id: params[:id], site_id: current_site.id))
        if @vocabulary_form.save
          track_update_activity
          redirect_to(
            edit_admin_common_vocabulary_path(@vocabulary_form.vocabulary),
            notice: t(".success")
          )
        else
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
        params.require(:vocabulary).permit(:name)
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
    end
  end
end
