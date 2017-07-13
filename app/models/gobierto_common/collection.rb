module GobiertoCommon
  class Collection  < ApplicationRecord

    belongs_to :site

    translates :title, :slug

    validates :site, :title, :slug, presence: true
    validate :uniqueness_of_slug
    validate :uniqueness_of_title

    def self.find_by_slug!(slug)
      if slug.present?
        I18n.available_locales.each do |locale|
          if p = self.with_slug_translation(slug, locale).first
            return p
          end
        end
        raise(ActiveRecord::RecordNotFound)
      end
    end

    def self.collector_classes
      [Site, Module, GobiertoParticipation::Issue, GobiertoParticipation::Area]
    end

    def initialize(site, container = nil)
      @container = container.present? ? container : site
    end

    attr_reader :container

    def append(item)
      containers_hierarchy(container).each do |container_type, container_id|
        CollectionItem.create site: site, container_type: container_type, container_id: container_id, item: item
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
      if container.is_a?(GobiertoParticipation::Issue)
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

    def uniqueness_of_slug
      if slug_translations.present?
        if slug_translations.select{ |_, slug| slug.present? }.any?{ |_, slug| self.class.where(site_id: self.site_id).where.not(id: self.id).with_slug_translation(slug).exists? }
          errors.add(:slug, I18n.t('errors.messages.taken'))
        end
      end
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
