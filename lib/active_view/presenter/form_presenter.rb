module ActionView
  module FormPresenter
    extend ActiveSupport::Concern

    included do
      around_action :validate, :set_valid
      after_action :submit, :set_submitted
    end

    # TODO: Remove in favour of an implicit action call
    def populate
    end

    # TODO: Remove in favour of an implicit action call
    def validate
    end

    # TODO: Remove in favour of an implicit action call
    def submit
    end

    ## Public API

    def populate!(*args, &block)
      action_params = { args: args, block: block }
      process(:populate)
    end

    def validate!
      process(:validate)
    end

    def submit!
      process(:submit)
    end

    def valid?
      @_valid ||= false
    end

    def submitted?
      @_submitted ||= false
    end

    private

    def set_valid
      @_valid = yield
    end

    def set_submitted
      @_submitted = true
    end

    module ClassMethods
      def internal_methods
        super - [:populate, :validate, :submit] # TODO: remove once implicit actions are available.
      end
    end
  end
end
