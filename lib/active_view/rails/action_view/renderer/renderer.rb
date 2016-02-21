require 'action_view/helpers/rendering_helper'


module ActiveView
  module Rails
    module ActionView
      module Renderer
        extend ActiveSupport::Concern

        def render_view(context, view, controller, object, options)
          assigns = {}

          view_class = "#{view.to_s}_view".camelize.constantize.view_context_class(controller.class)
          view = view_class.new(assigns, controller, object)

          yield view if block_given?

          ViewRenderer.new(view.lookup_context).render(view, options) if view.valid?
        end
      end
    end
  end
end

module ActionView
  class Renderer
    include ::ActiveView::Rails::ActionView::Renderer
  end
end
