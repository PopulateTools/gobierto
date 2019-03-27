# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ContributionFormTest < ActiveSupport::TestCase

    def contribution_form_attributes
      {
        site_id: site.id,
        user_id: contribution.user_id,
        contribution_container_id: contribution.contribution_container_id,
        title: contribution.title,
        description:  contribution.description
      }
    end

    def valid_contribution_form
      @valid_contribution_form ||= ContributionForm.new(contribution_form_attributes)
    end

    def invalid_contribution_form
      @invalid_contribution_form ||= ContributionForm.new(contribution_form_attributes.merge(
        title: nil,
        description: nil
      ))
    end

    def future_contribution_container
      @future_contribution_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_future)
    end

    def past_contribution_container
      @past_contribution_container ||= gobierto_participation_contribution_containers(:bowling_group_contributions_past)
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

    def test_create_contribution_when_contribution_container_is_future
      contribution_form = ContributionForm.new(contribution_form_attributes.merge(
        contribution_container_id: future_contribution_container.id
      ))

      refute contribution_form.save

      assert_equal 1, contribution_form.errors.messages[:contribution_container].size
    end

    def test_create_contribution_when_contribution_container_is_past
      contribution_form = ContributionForm.new(contribution_form_attributes.merge(
        contribution_container_id: past_contribution_container.id
      ))

      refute contribution_form.save

      assert_equal 1, contribution_form.errors.messages[:contribution_container].size
    end
  end
end
