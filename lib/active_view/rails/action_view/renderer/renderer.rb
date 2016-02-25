require 'action_view/helpers/rendering_helper'


module ActiveView
  module Rails
    module ActionView
      module Renderer
        extend ActiveSupport::Concern

        def render(context, options)
          if options.key?(:view)
            view_renderer.render_view(self, options)
          else
            super
          end
        end

        def render_view(context, options)
          view = options[:view]
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
