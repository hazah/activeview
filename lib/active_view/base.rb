require 'action_view/base'
require 'active_model/callbacks'
require 'active_support'

module ActiveView
  class Base < ActionView::Base
    extend ActiveModel::Callbacks

    include Rendering

    class << self
      attr_reader :abstract
      alias_method :abstract?, :abstract

      # Define a view as abstract.
      def abstract!
        @abstract = true
      end

      attr_internal_reader :presenter

      def presenter=(new_presenter)
        @_presenter = new_presenter
      end

      def inherited(klass) # :nodoc:
        # Define the abstract ivar on subclasses so that we don't get
        # uninitialized ivar warnings
        unless klass.instance_variable_defined?(:@abstract)
          klass.instance_variable_set(:@abstract, false)
        end

        # Determine the presenter class that will manipulate this view.
        unless klass.instance_variable_defined?(:@_presenter) || klass == ActiveView::Form
          klass.instance_variable_set(:@_presenter, ("#{klass.view_path.camelize.deconstantize}Presenter".constantize))
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

    end

    # Delegates to the class' #view_path
    def view_path
      self.class.view_path
    end

    abstract!

    def presenter
      @_presenter
    end

    attr_internal :parent

    define_model_callbacks :initialize, only: :after

    def initialize(parent = nil, controller = nil, options = {}, &block)
      @_config = ActiveSupport::InheritableOptions.new

      assign_controller(controller)
      _prepare_context

      @_parent = parent
      @_presenter = self.class.presenter.new(self, options, block)

      run_callbacks :initialize
    end

    after_initialize { |view| view.presenter.initialize_view! }

    define_model_callbacks :populate

    delegate :populate!, to: :presenter

    def populate(*args, &block)
      run_callbacks :populate do
        populate! *args, &block
      end
    end

    def renderable?
      true
    end

    ActiveSupport.run_load_hooks(:active_view, self)
  end
end
