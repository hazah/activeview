require 'action_view/helpers/rendering_helper'

module ActionView
  module Helpers
    RenderingHelper.module_eval do
      def view(view_class, *args, &block)
        view_class.view_context_class(controller.class).new(nil, controller, *args, &block).tap do |view|
          view.lookup_context.formats = [controller.format.to_sym]
          view.lookup_context.rendered_format = view.lookup_context.formats.first
        end
      end

      def render(options = {}, locals = {}, &block)
        if options.is_a?(Class) && options < ActiveView::Base
          args = locals.delete(:args) || []
          options = view(options, *args, &block)
        end

        case options
        when Hash
          if block_given?
            view_renderer.render_partial(self, options.merge(:partial => options[:layout]), &block)
          else
            view_renderer.render(self, options)
          end
        else
          if options.is_a? ActiveView::Base
            view_renderer.render_view(self, :view => options, :locals => locals)
          else
            view_renderer.render_partial(self, :partial => options, :locals => locals)
          end
        end
      end
    end
  end
end
