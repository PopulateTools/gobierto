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

    def instagram_handle
      person_contact_method_for("Instagram", "service_handle")
    end

    def instagram_url
      person_contact_method_for("Instagram", "service_url")
    end

    def trips_url
      person_custom_link_for('Viajes')
    end

    def gifts_url
      person_custom_link_for('Obsequios')
    end

    def content_blocks_for_bio(site_id)
      object.content_blocks(site_id).where.not(internal_id:  GobiertoCommon::DynamicContent::CONTACT_BLOCK_ID)
    end

    def has_bio_or_cv?
      bio.present? || bio_url.present?
    end

    def has_biographic_blocks?
      content_blocks_for_bio(site_id).any? { |block| block.records.any? }
    end

    def has_biographic_data?
     has_bio_or_cv? || has_biographic_blocks?
    end

    def has_posts?
      posts.active.any?
    end

    def has_statements?
      statements.active.any?
    end

    private

    def person_contact_method_for(service_name, attribute_name)
      person_contact_methods.detect do |contact_method|
        contact_method["service_name"] == service_name
      end.try(:[], attribute_name)
    end

    def person_custom_link_for(service_name)
      content_block = object.content_blocks.find_by(internal_id: GobiertoCommon::DynamicContent::CUSTOM_LINKS_BLOCK_ID)

      if content_block
        payloads = content_block.records.pluck(:payload)
        service_payload = payloads.detect { |payload| payload['service_name'] == service_name }
        return service_payload['service_url'] if service_payload && valid_url?(service_payload['service_url'])
      end

      nil
    end

    def valid_url?(url)
      /http.*\..*/.match(url)
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
