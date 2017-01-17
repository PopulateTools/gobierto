module GobiertoPeople
  module People
    class PersonBioController < BaseController
      def show
        @person_bio_content_blocks = @person.content_blocks(@person.site_id).sorted
      end
    end
  end
end
