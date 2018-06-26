# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class DepartmentRowchartSerializerTest < ActiveSupport::TestCase

    def department
      @department ||= gobierto_people_departments(:culture_department)
    end

    def test_serialize
      department.update_attributes!(name: "Departament de la Presidència")

      serializer = DepartmentRowchartSerializer.new(department)
      serializer_output = JSON.parse(serializer.to_json)

      assert_equal "Presidència", serializer_output["key"]
    end

  end
end
