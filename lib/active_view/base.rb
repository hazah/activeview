require 'action_view/base'
require 'active_model/model'
require 'active_support'

module ActiveView
  class Base < ActionView::Base
    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Validations

    include Rendering

    class << self
      attr_reader :abstract
      alias_method :abstract?, :abstract

      # Define a controller as abstract. See internal_methods for more
      # details.
      def abstract!
        @abstract = true
      end

      def inherited(klass) # :nodoc:
        # Define the abstract ivar on subclasses so that we don't get
        # uninitialized ivar warnings
        unless klass.instance_variable_defined?(:@abstract)
          klass.instance_variable_set(:@abstract, false)
        end
        super
      end

      # Returns the full view name, underscored, without the ending View.
      # For instance, MyApp::MyPost::ShowView would return "my_app/my_post/show" for
      # view_path.
      #
      # ==== Returns
      # * <tt>String</tt>
      def view_path
        @view_path ||= anonymous? ? superclass.view_path : name.sub(/View$/, '').underscore
      end
    end

    # Delegates to the class' #view_path
    def view_path
      self.class.view_path
    end

    abstract!

    attr_internal :object
    delegate :attributes, to: :object

    attr_internal :presenter
    delegate :process, to: :presenter

    def initialize(assigns = {}, controller = nil, object = nil)
      @_config = ActiveSupport::InheritableOptions.new

      assign(assigns)
      assign_controller(controller)
      _prepare_context
      @_object = object
    end

    delegate :to_model, to: :object
    delegate :model_name, to: :to_model

    ActiveSupport.run_load_hooks(:active_view, self)
  end
end
