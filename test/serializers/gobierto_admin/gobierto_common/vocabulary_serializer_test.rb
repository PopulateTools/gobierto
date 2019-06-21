# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class VocabularySerializerTest < ActiveSupport::TestCase

      def vocabulary
        @vocabulary ||= gobierto_common_vocabularies(:animals)
      end

      def serializer
        VocabularySerializer.new(vocabulary)
      end

      def test_serialize
        serializer_output = JSON.parse(serializer.to_json)

        assert_equal vocabulary.id, serializer_output["id"]
        assert_equal "animals", serializer_output["slug"]
        assert_equal({ "en" => "Animals", "es" => "Animales" }, serializer_output["name_translations"])
        assert_equal vocabulary.terms.size, serializer_output["terms"].size
      end

    end
  end
end
