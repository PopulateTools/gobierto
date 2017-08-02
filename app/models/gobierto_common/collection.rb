module GobiertoCommon
  class Collection < ApplicationRecord
    include User::Subscribable

    belongs_to :site
    belongs_to :container, polymorphic: true
    has_many :collection_items

    translates :title

    validates :site, :title, :slug, :item_type, presence: true
    validates :container, presence: true, associated: true
    validates_associated :container
    validates :slug, uniqueness: true
    validate :uniqueness_of_title

    attr_reader :container

    scope :by_item_type, ->(item_type) { where(item_type: item_type) }

    def pages_in_collection
      collection_items.where(item_type: 'GobiertoCms::Page').map(&:item_id)
    end

    def file_attachments_in_collection
      collection_items.where(item_type: 'GobiertoAttachments::Attachment').map(&:item_id)
    end

    def container
      if container_id.present?
        super
      end
    end

    def global_container
      container.to_global_id if container.present?
    end

    def global_container=(container)
      self.container = GlobalID::Locator.locate container
    end

    def self.collector_classes
      [Site, Issue, GobiertoParticipation::Area]
    end

    def self.type_classes
      [GobiertoCms::Page, GobiertoAttachments::Attachment]
    end

    def append(item)
      containers_hierarchy(container).each do |container_type, container_id|
        CollectionItem.create! collection_id: id, container_type: container_type, container_id: container_id, item: item
      end
    end

    private

    def containers_hierarchy(container)
      [
        site_for_container(container), gobierto_module_for_container(container),
        area_for_container(container), issue_for_container(container),
        gobierto_module_instance_for_container(container)
      ].compact.uniq
    end

    def site_for_container(container)
      if container.is_a?(Site)
        [container.class.name, container.id]
      else
        [site.class.name, site.id]
      end
    end

    def gobierto_module_for_container(container)
      if container.is_a?(Module)
        [container.name, nil]
      elsif !container_is_a_collector?(container)
        [container.class.parent.name, nil]
      end
    end

    def area_for_container(container)
      if container.is_a?(GobiertoParticipation::Area)
        [container.class.name, container.id]
      end
    end

    def issue_for_container(container)
      if container.is_a?(Issue)
        [container.class.name, container.id]
      end
    end

    def gobierto_module_instance_for_container(container)
      if !container_is_a_collector?(container)
        [container.class.name, container.id]
      end
    end

    def container_is_a_collector?(container)
      self.class.collector_classes.include?(container.class)
    end

    def uniqueness_of_title
      if title_translations.present?
        if title_translations.select{ |_, title| title.present? }.any?{ |_, title| self.class.where(site_id: self.site_id).where.not(id: self.id).with_title_translation(title).exists? }
          errors.add(:title, I18n.t('errors.messages.taken'))
        end
      end
    end
  end
end
