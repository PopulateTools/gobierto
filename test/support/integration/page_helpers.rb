module Integration
  module PageHelpers
    def scroll_to_top
      page.driver.scroll_to(0, 0)
    end
  end
end
