# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class DepartmentRowchartSerializerTest < ActiveSupport::TestCase

    def department
      @department ||= gobierto_people_departments(:culture_department)
    end

    def test_serialize
      complete_names = [
        "Departamento de Wadus",
        "Department of Wadus",
        "Departament de la Wadus",
        "Departament de Wadus",
        "Departament d'Wadus"
      ]

      complete_names.each do |name|
        department.update_attributes!(name: name)
        serializer_output = JSON.parse(DepartmentRowchartSerializer.new(department).to_json)
        assert_equal "Wadus", serializer_output["key"]
      end
    end

  end
end
