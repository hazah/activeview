require 'action_view/helpers/rendering_helper'


module ActiveView
  module Rails
    module ActionView
      module Renderer
        extend ActiveSupport::Concern

        def render_view(context, view_base, controller, object, &block)
          view_class = view_base.view_context_class(controller.class)
          view = view_class.new(controller, object, &block)

          ViewRenderer.new(view.lookup_context).render(view, view.options) if view.renderable?
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
