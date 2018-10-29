# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class DepartmentTest < ActiveSupport::TestCase

    def department
      @department ||= gobierto_people_departments(:culture_department)
    end

    def test_short_name
      I18n.locale = :ca

      expected_result = {
        "Departamento de Wadus" => "Wadus",
        "Department of Wadus" => "Wadus",
        "Departament de la Wadus" => "Wadus",
        "Departament de la Foo i d'Bar i Baz" => "Foo i Bar i Baz",
        "Departament de Wadus" => "Wadus",
        "Departament d'Wadus" => "Wadus"
      }

      expected_result.keys.each.each do |full_name|
        department.update_attributes!(name: full_name)
        assert_equal expected_result[full_name], department.short_name
      end
    end

  end
end
