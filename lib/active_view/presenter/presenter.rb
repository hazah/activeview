require 'abstract_controller/callbacks'

module ActiveView
  class Presenter < AbstractController::Base
    include AbstractController::Callbacks

    before_action :show, :run_block
    after_action :show, :set_assigns

    abstract!

    class << self
      def internal_methods
        superclass.internal_methods - [:show ,:form, :validate, :process_form] # TODO: remove once implicit actions are available.
      end
    end

    attr_internal :model
    delegate :session, :params, :options, to: :model
    delegate :assign, to: :model

    # capture calls are set on the parent view, where the blocks are actually defined.
    delegate :capture, to: 'model.parent'

    # Usually this is used to manipulate the View model directly but it can be
    # used for very complex configuration strategy.
    attr_internal :block

    def initialize(model, block)
      @_model = model
      @_block = block
    end

    # TODO: Remove in favour of an implicit action call
    def show
    end

    # TODO: Remove in favour of an implicit action call
    def form
    end

    def validate
    end

    def process_form
    end

    private

    # The default implementation simply yields the model for manipulation before
    # rendering.
    def run_block
      @block_content = capture(model, &block) unless block.blank?
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
      @_action_name @_response_body
      @_model @_block
    ).map(&:to_sym)

    def _protected_ivars # :nodoc:
      DEFAULT_PROTECTED_INSTANCE_VARIABLES
    end
  end
end
