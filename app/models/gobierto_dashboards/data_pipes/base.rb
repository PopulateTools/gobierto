# frozen_string_literal: true

require_relative "../../gobierto_dashboards"

module GobiertoDashboards
  module DataPipes
    class Base
      class NotImplementedError < StandardError; end

      attr_reader :site, :context

      def initialize(context, opts = {})
        @context = context.is_a?(GobiertoCommon::ContextService) ? context : GobiertoCommon::ContextService.new(:context)
        @site = @context.present? && context.resource.respond_to?(:site) ? @context.resource.site : opts[:site]
      end

      def output_data
        raise NotImplementedError, "Override this with a method returning an ActiveRecord::Relation of a class with sortable concern"
      end
    end
  end
end
