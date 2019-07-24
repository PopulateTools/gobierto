# frozen_string_literal: true

require "test_helper"

module GobiertoInvestments
  class ProjectTest < ActiveSupport::TestCase
    def project
      @project ||= gobierto_investments_projects(:public_pool_project)
    end

    def project_without_external_id
      @project_without_external_id ||= gobierto_investments_projects(:sports_center_project)
    end

    def test_valid
      assert project.valid?
    end

    def test_valid_without_external_id
      assert project_without_external_id.valid?
    end
  end
end
