# frozen_string_literal: true

namespace :gobierto_data do
  desc "Loads a dataset from a local csv file"
  task :load_dataset, [:organization_id, :slug, :csv_file_path, :schema_file_path, :attributes_file_path, :append, :csv_separator] => :environment do |_t, args|
    raise "Please, provide an organization id" if args[:organization_id].blank?
    raise "Please, provide a dataset slug" if args[:slug].blank?
    raise "Please, provide a CSV file path" if args[:csv_file_path].blank?
    organization_id = args[:organization_id]
    slug = args[:slug]
    csv_file_path = args[:csv_file_path]
    schema_file_path = args[:schema_file_path]
    attributes = args[:attributes_file_path].present? ? JSON.parse(File.read(args[:attributes_file_path])) : {}
    append = args[:append] == "true"
    csv_separator = args[:csv_separator] || ","
    site = Site.find_by(organization_id: organization_id)

    dataset = site.datasets.find_or_initialize_by(slug: slug)

    dataset.assign_attributes(attributes) if attributes.present?

    dataset.load_data_from_file(
      csv_file_path,
      csv_separator: csv_separator,
      schema_file: schema_file_path,
      append: append
    )
  end
end
