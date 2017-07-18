module GobiertoAdmin
  module GobiertoParticipation
    class ProcessForm
      include ActiveModel::Model

      attr_accessor(
        :id,
        :site_id,
        :title_translations,
        :body_translations,
        :information_text_translations,
        :process_type,
        :starts,
        :ends,
        :slug,
        :header_image,
        :header_image_url,
        :stages,
        :issue_id
      )

      delegate :persisted?, to: :process

      validates :site, :title_translations, :body_translations, :slug, :process_type, presence: true
      validates :stages, presence: true, if: :is_process?
      validates :process_type, inclusion: { in: ::GobiertoParticipation::Process.allowed_types }
      validates_presence_of :starts, :ends, if: :is_process?
      validates_absence_of  :starts, :ends, if: :is_group?

      def initialize(options = {})
        # Reorder attributes so site and process get assigned first
        ordered_options = { site_id: options[:site_id], id: options[:id] }
        ordered_options.merge!(options)
        super(ordered_options)
      end

      def save
        save_process if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def issue
        @issue ||= site.issues.find_by(id: issue_id)
      end

      def process
        @process = site.processes.find_by(id: id).presence || build_process(process_type: process_type)
        @process
      end

      def is_process?
        # to avoid incoherences when updating, this must reflect the value passed through the input, not the DB process
        (process_type == ::GobiertoParticipation::Process::PROCESS) || process.is_process?
      end

      def is_group?
        # to avoid incoherences when updating, this must reflect the value passed through the input, not the DB process
        (process_type == ::GobiertoParticipation::Process::GROUP) || process.is_group?
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
        @stages ||= process.stages || []
      end

      def default_stages
        existing_stages = process.stages.map { |stage| stage.active = true; stage }
        placeholder_stage_types = process_stage_class.stage_types.keys - existing_stages.map { |stage| stage.stage_type }

        placeholder_stages = placeholder_stage_types.map do |type|
          process_stage_class.new(process: process, stage_type: type, active: false)
        end

        @default_stages ||= existing_stages + placeholder_stages
      end

      def stages_attributes=(attributes)
        @stages = []

        attributes.each do |_, stage_attributes|
          next if stage_attributes['active'] == '0'

          stage = if existing_stage = process.stages.select { |stage| stage.stage_type == stage_attributes['stage_type'] }.first
                    update_existing_stage_from_attributes(existing_stage, stage_attributes)
                    existing_stage
                  else
                    build_process_stage_from_attributes(stage_attributes)
                  end

          @stages.push(stage) if stage.valid?
        end

        @stages
      end

      def process_stage_class
        ::GobiertoParticipation::ProcessStage
      end

      private

      def build_process(args = {})
        site.processes.new(args)
      end

      def update_existing_stage_from_attributes(existing_stage, stage_attributes)
        existing_stage.update_attributes!(
          title_translations: stage_attributes['title_translations'],
          description_translations: stage_attributes['description_translations'],
          starts: stage_attributes['starts'],
          ends: stage_attributes['ends']
        )
      end

      def build_process_stage_from_attributes(stage_attributes)
        process_stage_class.new(
          process: process,
          title_translations: stage_attributes['title_translations'],
          description_translations: stage_attributes['description_translations'],
          starts: stage_attributes['starts'],
          ends: stage_attributes['ends'],
          stage_type: stage_attributes['stage_type'],
          slug: stage_attributes['stage_type']
        )
      end

      def save_process
        @process = process.tap do |process_attributes|
          process_attributes.site_id = site_id
          process_attributes.title_translations = title_translations
          process_attributes.body_translations  = body_translations
          process_attributes.information_text_translations = information_text_translations
          process_attributes.header_image_url   = header_image_url
          process_attributes.process_type       = process_type
          process_attributes.starts             = starts
          process_attributes.ends               = ends
          process_attributes.slug               = slug
          process_attributes.issue_id           = issue_id
          process_attributes.stages             = stages
        end

        if @process.valid?
          if @process.changes.any?
            @process.save
          end

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
