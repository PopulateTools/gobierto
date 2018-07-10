# frozen_string_literal: true

module GobiertoPeople
  class DepartmentRowchartSerializer < RowchartItemSerializer

    def key
      object.short_name
    end

  end
end
