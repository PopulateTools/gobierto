module GobiertoPeople
  class PersonDecorator < BaseDecorator
    def initialize(person)
      @object = person
    end

    def contact_email
      person_contact_method_for("Email", "service_url")
    end

    def twitter_handle
      person_contact_method_for("Twitter", "service_handle")
    end

    def twitter_url
      person_contact_method_for("Twitter", "service_url")
    end

    def facebook_handle
      person_contact_method_for("Facebook", "service_handle")
    end

    def facebook_url
      person_contact_method_for("Facebook", "service_url")
    end

    def linkedin_handle
      person_contact_method_for("LinkedIn", "service_handle")
    end

    def linkedin_url
      person_contact_method_for("LinkedIn", "service_url")
    end

    def content_blocks_for_bio(site_id)
      object.content_blocks(site_id).where.not(internal_id:  GobiertoCommon::DynamicContent::CONTACT_BLOCK_ID)
    end

    private

    def person_contact_method_for(service_name, attribute_name)
      person_contact_methods.detect do |contact_method|
        contact_method["service_name"] == service_name
      end.try(:[], attribute_name)
    end

    protected

    def person_contact_methods
      @person_contact_methods ||= begin
        if content_block = object.content_blocks.find_by(internal_id: GobiertoCommon::DynamicContent::CONTACT_BLOCK_ID)
          content_block.records.pluck(:payload)
        else
          []
        end
      end
    end
  end
end
