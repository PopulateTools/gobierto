# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class TermSerializerTest < ActiveSupport::TestCase

      def term
        @term ||= gobierto_common_terms(:mammal)
      end

      def serializer
        TermSerializer.new(term)
      end

      def test_serialize
        serializer_output = JSON.parse(serializer.to_json)

        assert_equal term.id, serializer_output["id"]
        assert_equal term.name_translations, { "en" => "Mammal", "es" => "Mamífero" }
      end

    end
  end
end
