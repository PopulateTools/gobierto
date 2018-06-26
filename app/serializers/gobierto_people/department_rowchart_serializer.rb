# frozen_string_literal: true

module GobiertoPeople
  class DepartmentRowchartSerializer < RowchartItemSerializer

    TRUNCATE_NAME_PATTERN = Regexp.new([
      "Departamento de ",
      "Departamento ",
      "Department of ",
      "Departament de la ",
      "Departament de ",
      "Departament d'"
    ].join("|")).freeze

    def key
      object.name.gsub(TRUNCATE_NAME_PATTERN, "")
    end

  end
end
