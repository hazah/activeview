require 'abstract_controller/callbacks'

module ActiveView
  class Presenter < AbstractController::Base
    include AbstractController::Callbacks

    before_action :show, :run_block
    after_action :show, :set_assigns

    abstract!

    class << self
      def internal_methods
        superclass.internal_methods - [:show]
      end
    end

    attr_internal :model
    delegate :session, :params, :options, to: :model
    delegate :assign, to: :model
    delegate :capture, to: :model

    attr_internal :block

    def initialize(model, block)
      @_model = model
      @_block = block
    end

    def show
    end

    private

    def run_block
      @block_content ||= capture(model, &block) unless block.blank?
    end

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
