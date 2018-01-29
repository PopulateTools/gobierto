# frozen_string_literal: true

require_dependency "gobierto_plans"

module GobiertoPlans
  class Node < ApplicationRecord
    has_and_belongs_to_many :categories, class_name: "GobiertoPlans::Category"
    has_paper_trail

    # has_paper_trail(
    #   on:     [:create, :update, :destroy],
    #   ignore: [:name, :file_size, :file_name, :description, :current_version]
    # )

  end
end
