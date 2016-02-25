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
    include ActionView::Rails::ActionController
  end
end
