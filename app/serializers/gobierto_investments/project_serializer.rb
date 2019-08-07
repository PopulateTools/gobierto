# frozen_string_literal: true

module GobiertoInvestments
  class ProjectSerializer < ActiveModel::Serializer

    include ::GobiertoCommon::HasCustomFieldsAttributes

    attributes :id, :external_id, :title_translations

  end
end
