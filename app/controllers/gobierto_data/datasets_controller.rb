# frozen_string_literal: true

class GobiertoData::DatasetsController < GobiertoData::ApplicationController
  def index
    @datasets = current_site.datasets
  end

  def show
    @dataset = current_site.datasets.find_by(slug: params[:slug])

    @rows_count = @dataset.rails_model.count
  end
end
