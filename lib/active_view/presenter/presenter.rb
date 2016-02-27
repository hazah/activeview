require 'abstract_controller/helpers'
require 'abstract_controller/callbacks'

module ActiveView
  class Presenter < AbstractController::Base
    include ActionController::Helpers
    extend ActiveModel::Callbacks

    abstract!

    class << self
      def helper_method(*meths)
        meths.flatten!
        self._helper_methods += meths

        meths.each do |meth|
          _helpers.class_eval <<-ruby_eval, __FILE__, __LINE__ + 1
            def #{meth}(*args, &blk)                               # def current_user(*args, &blk)
              presenter.send(%(#{meth}), *args, &blk)             #    presenter.send(:current_user, *args, &blk)
            end                                                    # end
          ruby_eval
        end
      end
    end

    attr_internal :view
    delegate :controller, to: :view
    delegate :session, :params, :cookies, :flash, to: :view

    # capture calls are set on the parent view, where the blocks are actually defined.
    delegate :capture, to: 'view.parent'

    # Usually this is used to manipulate the View model directly but it can be
    # used for very complex configuration strategy.
    attr_internal :block

    attr_internal_reader :options

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
      run_block
    end

    def initialize_view!(*args, &block)
      @_action_params = { args: args, block: block }
      process(:initialize_view)
    end

    def populate!(*args, &block)
      @_action_params = { args: args, block: block }
      process(:populate)
      set_assigns
    end

    private

    ## adds blocks to the action calls.
    def process_action(method_name, *args)
      args = args + @_action_params[:args]
      if action_params[:block]
        super(method_name, *args, &action_params[:block])
      else
        super(method_name, *args)
      end
    ensure
      @_action_params = { args: [], block: nil }
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

    def default_action
    end

    def method_for_action(action_name)
      super || "default_action"
    end

    DEFAULT_PROTECTED_INSTANCE_VARIABLES = Set.new %w(
      @_action_name @_response_body @_options @_action_params
      @_block_content @_view @_block @_valid @_submitted
    ).map(&:to_sym)

    def _protected_ivars # :nodoc:
      DEFAULT_PROTECTED_INSTANCE_VARIABLES
    end
  end
end
