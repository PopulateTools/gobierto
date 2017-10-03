module GobiertoAdmin
  module GobiertoParticipation
    class ProcessForm

      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :body_translations,
        :process_type,
        :starts,
        :ends,
        :slug,
        :header_image,
        :header_image_url,
        :visibility_level,
        :issue_id,
        :scope_id,
        :has_duration
      )

      delegate :persisted?, to: :process
      delegate :polls_stage?, to: :process
      delegate :information_stage?, to: :process

      validates :site, :title_translations, :process_type, presence: true
      validates :process_type, inclusion: { in: ::GobiertoParticipation::Process.process_types }

      def initialize(options = {})
        options = options.to_h.with_indifferent_access

        # reorder attributes so site and process get assigned first
        ordered_options = {
          site_id: options[:site_id],
          id: options[:id]
        }.with_indifferent_access
        ordered_options.merge!(options)

        # overwritte options[:has_duration]
        ordered_options.merge!(has_duration: calculate_has_duration(options))

        super(ordered_options)
      end

      def save
        save_process if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def title
        process.title
      end

      def visibility_level
        @visibility_level ||= 'draft'
      end

      def issue
        @issue ||= site.issues.find_by(id: issue_id)
      end

      def scope
        @scope ||= site.scope.find_by(id: scope_id)
      end

      def process
        @process ||= site.processes.find_by(id: id) || build_process(process_type: process_type)
      end

      def process?
        # to avoid incoherences when updating, this must reflect the value passed through the input, not the DB process
        (process_type == ::GobiertoParticipation::Process.process_types[:process]) || process.process?
      end

      def group_process?
        # to avoid incoherences when updating, this must reflect the value passed through the input, not the DB process
        (process_type == ::GobiertoParticipation::Process.process_types[:group_process]) || process.group_process?
      end

      def header_image_url
        @header_image_url ||= begin
          return process.header_image_url unless header_image.present?

          FileUploadService.new(
            site: site,
            collection: process.model_name.collection,
            attribute_name: :header_image,
            file: header_image
          ).call
        end
      end

      def stages
        process.stages
      end

      def stages_attributes=(attributes)
        attributes.each do |_, stage_attributes|
          existing_stage = process.stages.detect { |stage| stage.stage_type == stage_attributes['stage_type'] }
          update_existing_stage_from_attributes(existing_stage, stage_attributes) if existing_stage
        end
        
        stages
      end

      private

      def process_stage_class
        ::GobiertoParticipation::ProcessStage
      end

      def build_process(args = {})
        site.processes.build(args)
      end

      def calculate_has_duration(options)
        if options[:has_duration].present?
          options[:has_duration] == '1'
        else
          (options[:starts] || options[:ends]).present?
        end
      end

      def update_existing_stage_from_attributes(existing_stage, attributes)
        existing_stage.assign_attributes(
          title_translations: attributes['title_translations'],
          description_translations: attributes['description_translations'],
          active: attributes['active'],
          starts: attributes['starts'],
          ends: attributes['ends']
        )
      end

      def build_placeholder_stages
        process_stage_class.stage_types.each do |stage_type_name, stage_type_number|
          process.stages.build(
            process: process,
            stage_type: stage_type_number,
            slug: stage_type_name
          )
        end
      end

      def save_process
        @process = process.tap do |process_attributes|
          process_attributes.site_id            = site_id
          process_attributes.title_translations = title_translations
          process_attributes.body_translations  = body_translations
          process_attributes.header_image_url   = header_image_url
          process_attributes.visibility_level   = visibility_level
          process_attributes.process_type       = process_type
          process_attributes.starts             = has_duration ? starts : nil
          process_attributes.ends               = has_duration ? ends : nil
          process_attributes.slug               = slug
          process_attributes.issue_id           = issue_id
          process_attributes.scope_id           = scope_id
          process_attributes.stages             = stages
        end

        build_placeholder_stages if process.stages.empty?

        if @process.valid?
          @process.save
          @process
        else
          promote_errors(@process.errors)
          false
        end
      end

      protected

      def promote_errors(errors_hash)
        errors_hash.each do |attribute, message|
          errors.add(attribute, message)
        end
      end

    end
  end
end
