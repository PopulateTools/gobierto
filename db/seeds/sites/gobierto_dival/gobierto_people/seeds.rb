# frozen_string_literal: true

module GobiertoSeeds
  class Recipe
    def self.run(site)
      seeds_filenames = Dir.glob(File.join(File.dirname(__FILE__), '*_seeds.yml'))

      seeds_filenames.each do |seeds_filename|
        block_data = YAML.safe_load File.read(seeds_filename)

        block_data['blocks'].each do |content_block|
          block = GobiertoCommon::ContentBlock.find_by(site_id: site.id, internal_id: content_block['internal_id'])
          if block.nil?
            block = GobiertoCommon::ContentBlock.create!(internal_id: content_block['internal_id'],
                                                         site: site,
                                                         content_model_name: content_block['content_model_name'],
                                                         title: content_block['title'])
          end

          content_block['fields'].each do |field|
            block_field = GobiertoCommon::ContentBlockField.find_by content_block: block, name: field['name']
            next unless block_field.nil?
            GobiertoCommon::ContentBlockField.create!(content_block: block, name: field['name'],
                                                      field_type: ::GobiertoCommon::ContentBlockField.field_types[field['field_type']],
                                                      label: field['label'])
          end
        end
      end
    end
  end
end
