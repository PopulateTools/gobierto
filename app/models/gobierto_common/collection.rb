module GobiertoCommon
  class Collection
    def self.find(site, container = nil)
      new(site, container)
    end

    def self.collector_classes
      [Site, Module, GobiertoParticipation::Issue, GobiertoParticipation::Area]
    end

    def initialize(site, container = nil)
      @site = site
      @container = container.present? ? container : site
    end

    attr_reader :container, :site

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
  end
end
