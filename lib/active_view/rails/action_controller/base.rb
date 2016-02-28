require 'action_controller/base'
require 'active_support/concern'

module ActiveView
  module Rails
    module ActionController
      extend ActiveSupport::Concern

      def view(view_class, *args, &block)
        view_class.view_context_class(self.class).new(nil, self, *args, &block).tap do |view|
          view.lookup_context.formats = [rendered_format.to_sym] if rendered_format
          view.lookup_context.rendered_format = view.lookup_context.formats.first
        end
      end

      def render(action=nil, options={}, &block) #:nodoc:
        unless action.nil?
          if action.is_a?(Class) && action < ActiveView::Base
            args = locals.delete(:args) || []
            options[:view] = view(action, *args, &block)
          end
        end
        super
      end

      private

      def _normalize_args(action=nil, options={})
        options = super(action, options)

        if action.is_a? ActiveView::Base
          options[:view] = action
        end
        options
      end

    end
  end
end

module ActionController
  Base.class_eval do
    include ActiveView::Rails::ActionController
  end
end
