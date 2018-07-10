# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class DepartmentTest < ActiveSupport::TestCase

    def department
      @department ||= gobierto_people_departments(:culture_department)
    end

    def test_short_name
      complete_names = [
        "Departamento de Wadus",
        "Department of Wadus",
        "Departament de la Wadus",
        "Departament de Wadus",
        "Departament d'Wadus"
      ]

      complete_names.each do |name|
        department.update_attributes!(name: name)
        assert_equal "Wadus", department.short_name
      end
    end

  end
end
