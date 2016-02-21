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
        unless klass.instance_variable_defined?(:@presenter)
          klass.instance_variable_set(:@presenter, "#{klass.view_path}/presenter".camelize.constantize)
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

      def attribute(*names)
        delegate *names, to: :object
        define_attribute_methods *names
      end
    end

    attribute_method_suffix '='

    def attribute=(attr, value)
      object.send("#{attr}=", value)
    end

    # Delegates to the class' #view_path
    def view_path
      self.class.view_path
    end

    def presenter
      @presenter ||= self.class.presenter.new(self, block)
    end

    abstract!

    attr_internal :parent

    attr_internal :object
    delegate :attributes, to: :object

    delegate :process, to: :presenter

    attr_internal :block
    attr_internal :options

    def initialize(parent, controller = nil, object = {}, &block)
      @_config = ActiveSupport::InheritableOptions.new

      assign_controller(controller)
      _prepare_context

      @_parent = parent
      @_object = object.is_a?(Hash) ? AttributeWrapper.new(object) : object
      @_block = block if block_given?
      @_options = {}

      process(:show)
    end

    def to_model
      object.respond_to?(:to_model) ? object.to_model : self
    end

    def model_class
      model_name_from_record_or_class(self).name.constantize
    end

    def renderable?
      valid?
    end

    AttributeWrapper = Struct.new(:attributes)

    ActiveSupport.run_load_hooks(:active_view, self)
  end
end
