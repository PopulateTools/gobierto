module GobiertoPeople
  class PersonDecorator < BaseDecorator
    def initialize(person)
      @object = person
    end

    def contact_methods
      {
        email: contact_email,
        twitter: { handle: twitter_handle, url: twitter_url },
        facebook: { handle: facebook_handle, url: facebook_url },
        linkedin: { handle: linkedin_handle, url: linkedin_url }
      }
    end

    private

    def contact_email
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end

    def twitter_handle
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end

    def twitter_url
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end

    def facebook_handle
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end

    def facebook_url
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end

    def linkedin_handle
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end

    def linkedin_url
      # TODO. Retrieve actual Person's contact methods.
      #

      ""
    end
  end
end
