require 'action_view/view_paths'

module ActiveView
  module Rendering
    extend ActiveSupport::Concern
    include ActionView::ViewPaths

    module ClassMethods
      def view_context_class(controller)
        @view_context_class ||= begin
          supports_path = controller.supports_path?
          routes  = controller.respond_to?(:_routes)  && controller._routes
          helpers = controller.respond_to?(:_helpers) && controller._helpers

          base = self

          Class.new(base) do
            if routes
              include routes.url_helpers(supports_path)
              include routes.mounted_helpers
            end

            if helpers
              include helpers
            end

            self._view_paths = base._view_paths
          end
        end
      end

    private

      # Override this method in your view if you want to change paths prefixes for finding views.
      # Prefixes defined here will still be added to parents' <tt>._prefixes</tt>.
      def local_prefixes
        []
      end
    end

    # Returns an object that is able to render templates.
    # :api: private
    def view_renderer
      @_view_renderer ||= ActionView::Renderer.new(lookup_context)
    end

    def render(options = {}, object = nil, locals = {}, &block)
      if object.is_a?(Hash) && locals.empty?
        locals, object = object, nil
      end

      case options
      when Hash
        if view = options.delete(:view)
          view_renderer.render_view(self, view, controller, object, options, &block)
        else
          if block_given?
            controller.view_renderer.render_partial(self, options.merge(:partial => options[:layout]), &block)
          else
            controller.view_renderer.render(self, options)
          end
        end
      else
        controller.view_renderer.render_partial(self, :partial => options, :locals => locals)
      end
    end
  end
end
