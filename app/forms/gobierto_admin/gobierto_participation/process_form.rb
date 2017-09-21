module GobiertoAdmin
  module GobiertoParticipation
    class ProcessForm
      include ActiveModel::Model
      prepend ::GobiertoCommon::Trackable

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
        :stages,
        :visibility_level,
        :issue_id
      )

      delegate :persisted?, to: :process
      delegate :polls_stage?, to: :process
      delegate :information_stage?, to: :process

      validates :site, :title_translations, :body_translations, :slug, :process_type, presence: true
      validates :stages, presence: true, if: :process?
      validates :process_type, inclusion: { in: ::GobiertoParticipation::Process.process_types }
      validates_presence_of :starts, :ends, if: :process?
      validates_absence_of :starts, :ends, if: :group_process?

      trackable_on :process

      # notify_changed :starts
      # notify_changed :ends
      notify_changed :visibility_level

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

      def title
        process.title
      end

      def starts
        process? ? @starts : nil
      end

      def ends
        process? ? @ends : nil
      end

      def visibility_level
        @visibility_level ||= 'draft'
      end

      def issue
        @issue ||= site.issues.find_by(id: issue_id)
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

      def default_stages
        existing_stages = process.stages.map { |stage| stage.active = true; stage }
        placeholder_stage_types = process_stage_class.stage_types.keys - existing_stages.map { |stage| stage.stage_type }

        placeholder_stages = placeholder_stage_types.map do |type|
          process_stage_class.new(process: process, stage_type: type, active: false)
        end

        # WARNING: order matters for presentation
        @default_stages ||= (existing_stages + placeholder_stages).sort_by! do |stage|
          ::GobiertoParticipation::ProcessStage.stage_types[stage.stage_type.to_sym]
        end
      end

      def stages_attributes=(attributes)
        attributes.each do |_, stage_attributes|

          existing_stage = process.stages.detect { |stage| stage.stage_type == stage_attributes['stage_type'] }

          if existing_stage && stage_attributes['active'] == '0'
            process.stages.delete(existing_stage)
          elsif stage_attributes['active'] != '0'
            if existing_stage
              update_existing_stage_from_attributes(existing_stage, stage_attributes)
            else
              build_process_stage_from_attributes(stage_attributes)
            end
          end
        end

        process.stages
      end

      def process_stage_class
        ::GobiertoParticipation::ProcessStage
      end

      def notify?
        process.active?
      end

      private

      def build_process(args = {})
        site.processes.build(args)
      end

      def update_existing_stage_from_attributes(existing_stage, stage_attributes)
        existing_stage.assign_attributes(
          title_translations: stage_attributes['title_translations'],
          description_translations: stage_attributes['description_translations'],
          starts: stage_attributes['starts'],
          ends: stage_attributes['ends']
        )
      end

      def build_process_stage_from_attributes(stage_attributes)
        process.stages.build(
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
          process_attributes.header_image_url   = header_image_url
          process_attributes.visibility_level   = visibility_level
          process_attributes.process_type       = process_type
          process_attributes.starts             = starts
          process_attributes.ends               = ends
          process_attributes.slug               = slug
          process_attributes.issue_id           = issue_id
          process_attributes.stages             = stages
        end

        if @process.valid?
          run_callbacks(:save) do
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
