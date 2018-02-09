# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class NodeTest < ActiveSupport::TestCase
    def node
      @node ||= gobierto_plans_nodes(:political_agendas)
    end

    def test_valid
      assert node.valid?
    end
  end
end
