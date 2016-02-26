require 'action_view/base'
require 'active_model/callbacks'
require 'active_support'

module ActiveView
  class Base < ActionView::Base
    include ActiveModel::Callbacks

    include Rendering

    class << self
      attr_reader :abstract
      alias_method :abstract?, :abstract

      # Define a view as abstract.
      def abstract!
        @abstract = true
      end

      attr_reader :presenter

      def presenter=(new_presenter)
        @presenter = new_presenter
      end

      def inherited(klass) # :nodoc:
        # Define the abstract ivar on subclasses so that we don't get
        # uninitialized ivar warnings
        unless klass.instance_variable_defined?(:@abstract)
          klass.instance_variable_set(:@abstract, false)
        end

        # Determine the presenter class that will manipulate this view.
        unless klass.instance_variable_defined?(:@_presenter)
          klass.instance_variable_set(:@_presenter, ("#{klass.view_path.camelize.deconstantize}::Presenter".constantize rescue ActiveView::Presenter))
        end

        super
      end

      # Returns the full view name, underscored, without the ending View.
      # For instance, MyApp::MyPost::Show would return "my_app/my_post/show" for
      # view_path.
      #
      # ==== Returns
      # * <tt>String</tt>
      def view_path
        @view_path ||= anonymous? ? superclass.view_path : name.underscore
      end

      def attr_helper(*names)
        attr_accessor *names
        define_attribute_methods *names
      end
    end

    attribute_method_suffix '='

    # Delegates to the class' #view_path
    def view_path
      self.class.view_path
    end

    abstract!

    def presenter
      @_presenter
    end

    attr_internal :parent
    attr_internal :block

    define_model_callbacks :initialize

    def initialize(parent = nil, controller = nil, options = {}, &block)
      @_config = ActiveSupport::InheritableOptions.new

      assign_controller(controller)
      _prepare_context

      @_parent = parent
      @_presenter = self.class.presenter.new(self, options, block)

      run_callbacks :initialize
    end

    after_initialize { |view| view.presenter.initialize_view! }

    ## Allows other systems, such as authorization, to block rendering
    define_model_callbacks :populate,
    define_model_callbacks :renderable, only: :before

    delegate :populate!, to: :presenter

    def populate(*args, &block)
      run_callbacks :populate do
        populate! *args, &block
      end
    end

    def renderable?
      run_callbacks :renderable || true
    end

    ActiveSupport.run_load_hooks(:active_view, self)
  end
end
