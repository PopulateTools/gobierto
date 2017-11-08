# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoParticipation
    class ContributionFormTest < ActiveSupport::TestCase
      def valid_contribution_form
        @valid_contribution_form ||= ::GobiertoParticipation::ContributionForm.new(
          site_id: site.id,
          user_id: contribution.user_id,
          contribution_container_id: contribution.contribution_container_id,
          title: contribution.title,
          description:  contribution.description
        )
      end

      def invalid_contribution_form
        @invalid_contribution_form ||= ::GobiertoParticipation::ContributionForm.new(
          site_id: site.id,
          user_id: contribution.user_id,
          contribution_container_id: contribution.contribution_container_id,
          title: nil,
          description:  nil
        )
      end

      def contribution
        @contribution ||= gobierto_participation_contributions(:cinema)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_save_contribution_with_valid_attributes
        assert valid_contribution_form.save
      end

      def test_contribution_error_messages_with_invalid_attributes
        invalid_contribution_form.save

        assert_equal 1, invalid_contribution_form.errors.messages[:title].size
      end
    end
  end
end
