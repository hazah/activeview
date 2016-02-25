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
        superclass.internal_methods - [:show] # TODO: remove once implicit actions are available.
      end
    end

    attr_internal :view
    delegate :session, :params, :options, to: :view
    delegate :assign, to: :view

    # capture calls are set on the parent view, where the blocks are actually defined.
    delegate :capture, to: 'view.parent'

    # Usually this is used to manipulate the View model directly but it can be
    # used for very complex configuration strategy.
    attr_internal :block

    def initialize(view, block)
      @_view = view
      @_block = block
    end

    ## Placeholders so that action calls relied on by the view succed. These
    ## are to be implemented by subclasses.

    # TODO: Remove in favour of an implicit action call
    def show
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
        @_block_content =  if view.parent.present?
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
      assign(variables)
    end

    DEFAULT_PROTECTED_INSTANCE_VARIABLES = Set.new %w(
      @_action_name @_response_body @_parent_params
      @_block_content @_view @_block @_valid @_submitted
    ).map(&:to_sym)

    def _protected_ivars # :nodoc:
      DEFAULT_PROTECTED_INSTANCE_VARIABLES
    end
  end
end
