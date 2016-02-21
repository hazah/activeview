require "active_model"
require "action_view"
require "rails"

module ActiveView
  class Engine < ::Rails::Engine # :nodoc:
    config.eager_load_namespaces << ActiveView

#    initializer "active_view." do
#
#    end
  end
end
