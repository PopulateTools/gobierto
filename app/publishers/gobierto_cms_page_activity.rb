# frozen_string_literal: true

require_dependency "app/publishers/base"

module Publishers
  class GobiertoCmsPageActivity
    include Publisher

    self.pub_sub_namespace = 'activities/gobierto_cms_pages'
  end
end
