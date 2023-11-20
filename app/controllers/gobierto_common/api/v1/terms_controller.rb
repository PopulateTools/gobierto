# frozen_string_literal: true

module GobiertoCommon
  module Api
    module V1
      class TermsController < ApiBaseController
        include ::GobiertoCommon::SecuredWithAdminToken

        # GET /api/v1/vocabularies/1/terms
        # GET /api/v1/vocabularies/1/terms.json
        def index
          render(json: base_relation, each_serializer: ::GobiertoCommon::ApiTermSerializer, adapter: :json_api)
        end

        # GET /api/v1/vocabularies/1/terms/1
        # GET /api/v1/vocabularies/1/terms/1.json
        def show
          find_item

          render(json: @item, serializer: ::GobiertoCommon::ApiTermSerializer, adapter: :json_api)
        end

        # GET /api/v1/vocabularies/1/terms/new
        # GET /api/v1/vocabularies/1/terms/new.json
        def new
          render(
            json: base_relation.new(name_translations: available_locales_hash, description_translations: available_locales_hash),
            serializer: ::GobiertoCommon::ApiTermSerializer,
            adapter: :json_api
          )
        end

        # POST /api/v1/vocabularies/1/terms
        # POST /api/v1/vocabularies/1/terms.json
        def create
          @form = ::GobiertoAdmin::GobiertoCommon::TermForm.new(term_form_params)

          if @form.save
            term = @form.term

            render(
              json: term,
              serializer: ::GobiertoCommon::ApiTermSerializer,
              status: :created,
              adapter: :json_api
            )
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        # PUT /api/v1/vocabularies/1/terms/1
        # PUT /api/v1/vocabularies/1/terms/1.json
        def update
          find_item
          @form = ::GobiertoAdmin::GobiertoCommon::TermForm.new(term_form_params.merge(id: @item.id))

          if @form.save
            term = @form.term

            render(
              json: term,
              serializer: ::GobiertoCommon::ApiTermSerializer,
              adapter: :json_api
            )
          else
            api_errors_render(@form, adapter: :json_api)
          end
        end

        # DELETE /api/v1/vocabularies/1/terms/1
        # DELETE /api/v1/vocabularies/1/terms/1.json
        def destroy
          find_item

          @item.destroy

          head :no_content
        end

        private

        def term_id
          return term_params[:term_id] if term_params[:term_id].present?
          return base_relation.find_by(external_id: term_params[:parent_external_id])&.id if term_params[:parent_external_id].present?
          return (base_relation.find_by(id: term_params[:parent_id])&.id || base_relation.find_by(external_id: term_params[:parent_id])&.id) if term_params[:parent_id].present?
        end

        def base_relation
          return GobiertoCommon::Term.none if vocabulary.blank?

          vocabulary.terms
        end

        def vocabulary
          @vocabulary ||= current_site.vocabularies.find_by(id: params[:vocabulary_id]) || current_site.vocabularies.find_by(slug: params[:vocabulary_id])
        end

        def find_item
          @item = base_relation.find(params[:id])
        end

        def term_form_params
          term_params.except(:parent_external_id, :parent_id).merge(site_id: current_site.id, vocabulary_id: vocabulary.id, term_id:)
        end

        def term_params
          @term_params ||= ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: writable_attributes)
        end

        def writable_attributes
          [:name_translations, :description_translations, :slug, :position, :term_id, :external_id, :parent_external_id, :parent_id]
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
