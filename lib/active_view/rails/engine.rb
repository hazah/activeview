require 'rails/engine'

module Rails
  Engine.class_eval do
    initializer :add_action_view_paths, before: :append_asset_paths do
      views = paths["app/actions/views"].existent
      unless views.empty?
        ActiveSupport.on_load(:active_view){ prepend_view_path(views) if respond_to?(:prepend_view_path) }
      end
    end
  end
end
