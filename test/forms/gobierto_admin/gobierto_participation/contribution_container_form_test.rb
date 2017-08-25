# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ContributionContainerFormTest < ActiveSupport::TestCase
      def valid_contribution_container_form
        @valid_contribution_container_form ||= ContributionContainerForm.new(
          site_id: site.id,
          admin_id: contribution_container.admin_id,
          process_id: contribution_container.process_id,
          title_translations: { I18n.locale => contribution_container.title },
          description_translations:  { I18n.locale => contribution_container.description },
          contribution_type: contribution_container.contribution_type,
          visibility_level: contribution_container.visibility_level,
          starts: contribution_container.starts,
          ends: contribution_container.ends
        )
      end

      def invalid_contribution_container_form
        @invalid_contribution_container_form ||= ContributionContainerForm.new(
          site_id: site.id,
          admin_id: contribution_container.admin_id,
          process_id: contribution_container.process_id,
          title_translations: nil,
          description_translations:  nil,
          contribution_type: nil,
          visibility_level: contribution_container.visibility_level,
          starts: nil,
          ends: nil
        )
      end

      def contribution_container
        @contribution_container ||= gobierto_participation_contribution_containers(:children_contributions)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_contribution_container_with_valid_attributes
        assert valid_contribution_container_form.save
      end

      def test_contribution_container_error_messages_with_invalid_attributes
        invalid_contribution_container_form.save

        assert_equal 1, invalid_contribution_container_form.errors.messages[:title_translations].size
        assert_equal 1, invalid_contribution_container_form.errors.messages[:description_translations].size
      end
    end
  end
end
