require 'action_controller/base'
require 'active_support/concern'

module ActiveView
  module Rails
    module ActionController
      extend ActiveSupport::Concern

      def view(view_class, *args, &block)
        view_class.view_context_class(self).new(nil, self, *args, &block)
      end

      private

      def _normalize_args(action=nil, options={})
        options = super(action, options)

        if action.is_a? ActiveView::Base || (action.is_a?(Class) && action < ActiveView::Base)
          if action.is_a?(Class)
            args = options.delete(:args) || []
            action = view(view, *args)
          end
          options[:view] = action
        end
        options
      end

      def _process_format(format, options = {})
        super

        if options.has_key?(:view)
          options[:view].lookup_context.formats = [format.to_sym]
          options[:view].lookup_context.rendered_format = options[:view].lookup_context.formats.first
      end

    end
  end
end

module ActionController
  Base.class_eval do
    include ActionView::Rails::ActionController
  end
end
