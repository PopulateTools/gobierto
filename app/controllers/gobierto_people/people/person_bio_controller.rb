# frozen_string_literal: true

module GobiertoPeople
  module People
    class PersonBioController < BaseController
      def show
        @person_bio_content_blocks = @person.content_blocks_for_bio(@person.site_id).sorted
      end
    end
  end
end
