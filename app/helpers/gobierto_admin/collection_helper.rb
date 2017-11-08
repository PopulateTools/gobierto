module GobiertoAdmin
  module CollectionHelper
    def collection_context(collection)
      collection_item_type_name = if collection.item_type == "GobiertoCms::News"
                                    I18n.t('activerecord.models.gobierto_cms/news_plural')
                                  else
                                    collection.item_type.constantize.model_name.human.pluralize
                                  end
      [collection_item_type_name, t('views.of'), collection.container.try(:name) || collection.container.try(:title)].join(' ')
    end
  end
end
