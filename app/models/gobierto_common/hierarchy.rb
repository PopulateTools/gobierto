module GobiertoCommon
  class Hierarchy
    def self.h
      # - Site
      # - Module, Topic, Scope
      # - Instance obj
      [
        'Site',
        ['GobiertoModule', 'Topic', 'Scope'],
        'Instance'
      ]
    end
  end
end
