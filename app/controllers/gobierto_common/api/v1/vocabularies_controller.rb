# frozen_string_literal: true

module GobiertoCommon
  module Api
    module V1
      class VocabulariesController < ApiBaseController
        include ::GobiertoCommon::SecuredWithAdminToken

        # GET /api/v1/vocabularies
        # GET /api/v1/vocabularies.json
        def index
          render(json: base_relation, each_serializer: ::GobiertoCommon::VocabularySerializer, adapter: :json_api)
        end

        # GET /api/v1/vocabularies/1
        # GET /api/v1/vocabularies/1.json
        def show
          find_item

          render(json: @item, adapter: :json_api)
        end

        # GET /api/v1/vocabularies/new
        # GET /api/v1/vocabularies/new.json
        def new
          render(
            json: base_relation.new(name_translations: available_locales_hash),
            serializer: ::GobiertoCommon::VocabularySerializer,
            adapter: :json_api
          )
        end

        # POST /api/v1/vocabularies
        # POST /api/v1/vocabularies.json
        def create
          @form = ::GobiertoAdmin::GobiertoCommon::VocabularyForm.new(vocabulary_params.merge(site_id: current_site.id))

          if @form.save
            vocabulary = @form.vocabulary

            create_or_update_terms(vocabulary, terms_params) do
              render(
                json: vocabulary,
                serializer: ::GobiertoCommon::VocabularySerializer,
                status: :created,
                adapter: :json_api
              )
            end
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        # PUT /api/v1/vocabularies/1
        # PUT /api/v1/vocabularies/1.json
        def update
          find_item
          @form = ::GobiertoAdmin::GobiertoCommon::VocabularyForm.new(vocabulary_params.merge(site_id: current_site.id, id: @item.id))

          if @form.save
            vocabulary = @form.vocabulary

            create_or_update_terms(vocabulary, terms_params) do
              render(
                json: vocabulary,
                serializer: ::GobiertoCommon::VocabularySerializer,
                adapter: :json_api
              )
            end
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/vocabularies/1
        # DELETE /api/v1/vocabularies/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def create_or_update_terms(vocabulary, terms_data)
          if terms_data.blank?
            yield(vocabulary)
          else
            @terms_form = ::GobiertoAdmin::GobiertoCommon::TermsForm.new(terms: terms_data, site_id: current_site.id, vocabulary_id: vocabulary.id)
            if @terms_form.save
              yield(vocabulary)
            else
              api_errors_render(@terms_form, adapter: :json_api)
            end
          end
        end

        def base_relation
          current_site.vocabularies
        end

        def find_item
          @item = base_relation.find_by(id: params[:id]) || base_relation.find_by!(slug: params[:id])
        end

        def vocabulary_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: writable_attributes)
        end

        def terms_params
          ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:terms])[:terms]
        end

        def writable_attributes
          [:name_translations, :slug]
        end

        def available_locales_hash
          @available_locales_hash ||= available_locales.each_with_object({}) { |key, locales| locales[key] = nil }
        end

        def available_locales
          @available_locales ||= current_site.configuration.available_locales
        end
      end
    end
  end
end
