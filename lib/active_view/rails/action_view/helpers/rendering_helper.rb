require 'action_view/helpers/rendering_helper'

module ActionView
  module Helpers
    RenderingHelper.module_eval do
      def render(options = {}, locals = {}, &block)
        case options
        when Hash
          if view = options.delete(:view)
            view_renderer.render_view(self, view, controller, locals, options, &block)
          else
            if block_given?
              view_renderer.render_partial(self, options.merge(:partial => options[:layout]), &block)
            else
              view_renderer.render(self, options)
            end
          end
        else
          view_renderer.render_partial(self, :partial => options, :locals => locals)
        end
      end
    end
  end
end
