# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    class DatasetsController < GobiertoAdmin::GobiertoData::BaseController
      include CustomFieldsHelper

      def index
        @datasets = current_site.datasets.order(id: :desc)
      end

      def new
        @dataset_form = DatasetForm.new(site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip)
        @dataset = @dataset_form.dataset
        initialize_custom_field_form
      end

      def edit
        @dataset = find_dataset

        @dataset_form = DatasetForm.new(
          @dataset.attributes.except(*ignored_dataset_attributes).merge(site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip)
        )
        initialize_custom_field_form
      end

      def create
        @dataset_form = DatasetForm.new(dataset_params.merge(site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip))
        @dataset = @dataset_form.dataset
        initialize_custom_field_form

        if @dataset_form.save
          custom_fields_save
          redirect_to(
            edit_admin_data_dataset_path(@dataset_form.dataset),
            notice: t(".success")
          )
        else
          render :new
        end
      end

      def update
        @dataset = find_dataset

        @dataset_form = DatasetForm.new(
          dataset_params.merge(id: params[:id], site_id: current_site.id, admin_id: current_admin.id, ip: remote_ip)
        )
        initialize_custom_field_form

        if @dataset_form.save && custom_fields_save
          redirect_to(
            edit_admin_data_dataset_path(@dataset),
            notice: t(".success")
          )
        else
          render :edit
        end
      end

      def destroy
        @dataset = find_dataset

        @dataset.destroy

        redirect_to admin_data_datasets_path, notice: t(".success")
      end

      private

      def dataset_params
        params.require(:dataset).permit(
          :table_name,
          :slug,
          name_translations: [*I18n.available_locales]
        )
      end

      def ignored_dataset_attributes
        %w(created_at updated_at site_id)
      end

      def find_dataset
        current_site.datasets.find(params[:id])
      end

    end
  end
end
