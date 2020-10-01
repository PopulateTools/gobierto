# frozen_string_literal: true

module GobiertoCommon
  class ApiTokenForm < BaseForm

    attr_accessor(
      :id,
      :name,
      :domain,
      :owner
    )

    attr_writer(
      :update_token
    )

    delegate :persisted?, to: :api_token

    def api_token
      @api_token ||= api_token_relation.find_by(id: id) || build_api_token
    end

    def update_token
      @update_token ||= false
    end

    def update_token?
      update_token == true || update_token == "1"
    end

    def save
      return false unless valid?

      if save_api_token
        api_token
      end
    end

    private

    def build_api_token
      api_token_relation.secondary.new
    end

    def api_token_relation
      owner.api_tokens
    end

    def save_api_token
      @api_token = api_token.tap do |attributes|
        attributes.name = name.presence
        attributes.domain = domain.presence
      end

      if @api_token.valid?
        @api_token.save
        @api_token.regenerate_token if update_token?

        @api_token
      else
        promote_errors(@api_token.errors)

        false
      end
    end
  end
end
