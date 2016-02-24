require 'action_view/view_paths'

module ActiveView
  module Rendering
    extend ActiveSupport::Concern
    include ActionView::ViewPaths

    module ClassMethods
      def view_context_class(controller)
        supports_path = controller.supports_path?
        routes  = controller.respond_to?(:_routes)  && controller._routes
        helpers = controller.respond_to?(:_helpers) && controller._helpers

        base = self

        presenter_helpers = base.presenter.respond_to(:_helpers) && base.presenter._helpers

        Class.new(base) do
          if routes
            include routes.url_helpers(supports_path)
            include routes.mounted_helpers
          end

          if helpers
            include helpers
          end

          if presenter_helpers
            include presenter_helpers
          end

          self._view_paths = base._view_paths

          define_singleton_method :name do
            base.name
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

    # Overrides the main helper so that global templates can make use of the
    # controllers lookup_context if one is available and fallback to own if not.
    def render(options = {}, locals = {}, &block)
      case options
      when Hash
        if block_given?
          (try(:controller) || self).view_renderer.render_partial(self, options.merge(:partial => options[:layout]), &block)
        else
          (try(:controller) || self).view_renderer.render(self, options)
        end
      else
        if options < ActiveView::Base
          view_renderer.render_view(self, options, controller, locals, &block)
        else
          (try(:controller) || self).view_renderer.render_partial(self, :partial => options, :locals => locals)
        end
      end
    end
  end
end
