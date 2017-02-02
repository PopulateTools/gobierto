module AlgoliaSearchGobierto
  def class_name
    self.class.name
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def search_index_name
      "#{APP_CONFIG["site"]["name"]}_#{Rails.env}"
    end

    def algoliasearch_gobierto(&block)
      algoliasearch(enqueue: true, disable_indexing: Rails.env.test?, index_name: search_index_name, &block)
    end
  end
end
