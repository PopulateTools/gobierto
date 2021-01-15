# frozen_string_literal: true

module GobiertoCommon
  class ContextService
    attr_reader :context

    delegate :present?, to: :resource

    def initialize(context)
      @context = fill_missing_parts(context.to_s.strip)
    end

    def resource
      @resource ||= begin
                      GlobalID::Locator.locate context
                    rescue ActiveRecord::RecordNotFound
                      nil
                    end
    end

    private

    def fill_missing_parts(context)
      return context if context =~ %r{^gid://gobierto/}

      missing_part = "gid://"
      missing_part += "gobierto/" unless context =~ %r{^gobierto/}

      "#{missing_part}#{context}"
    end
  end
end
