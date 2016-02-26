require 'abstract_controller/helpers'
require 'abstract_controller/callbacks'

module ActiveView
  class Presenter < AbstractController::Base
    include ActionController::Helpers
    include AbstractController::Callbacks

    before_action :show, :run_block
    after_action :show, :set_assigns

    abstract!

    class << self
      def internal_methods
        superclass.internal_methods - [:initialize_view] # TODO: remove once implicit actions are available.
      end
    end

    attr_internal :view
    delegate :controller, to: :view
    delegate :session, :params, :cookies, :flash to: :view

    # capture calls are set on the parent view, where the blocks are actually defined.
    delegate :capture, to: 'view.parent'

    # Usually this is used to manipulate the View model directly but it can be
    # used for very complex configuration strategy.
    attr_internal :block

    attr_internal :action_params

    def initialize(view, options, block)
      @_view = view
      @_options = options
      @_block = block
    end

    ## Placeholders so that action calls relied on by the view succed. These
    ## are to be implemented by subclasses.

    # TODO: Remove in favour of an implicit action call
    def initialize_view(*args, &block)
    end

    private

    def initialize_view!(*args, &block)
      action_params = { args: args, block: block }
      process(:initialize_view)
    end

    ## adds blocks to the action calls.
    def process_action(method_name, *args)
      args = args + action_params[:args]
      super(method_name, *args, &action_params[:block])
    end

    def block_content
      @_block_content ||= nil
    end

    helper_method :block_content

    # The default implementation simply yields the model for manipulation before
    # rendering.
    def run_block
      @_block_content = nil
      unless block.blank?
        @_block_content = if view.parent.present?
                            capture(view, &block)
                          else
                            ## We've been called directly from a controller.
                            yield(view)
                          end
      end
    end

    # Assign all instance variables to the view so that they are available in the
    # template.
    def set_assigns
      protected_vars = _protected_ivars
      variables      = instance_variables

      variables.reject! { |s| protected_vars.include? s }
      variables = variables.each_with_object({}) { |name, hash|
        hash[name.slice(1, name.length)] = instance_variable_get(name)
      }
      view.assign(variables)
    end

    DEFAULT_PROTECTED_INSTANCE_VARIABLES = Set.new %w(
      @_action_name @_response_body @_options
      @_block_content @_view @_block @_valid @_submitted
    ).map(&:to_sym)

    def _protected_ivars # :nodoc:
      DEFAULT_PROTECTED_INSTANCE_VARIABLES
    end
  end
end
