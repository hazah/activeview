module ActionView
  module FormPresenter
    extend ActiveSupport::Concern

    included do
      around_action :validate, :set_valid
      after_action :create, :update, :set_submitted
    end

    # TODO: Remove in favour of an implicit action call
    def populate
    end

    # TODO: Remove in favour of an implicit action call
    def validate
    end

    # TODO: Remove in favour of an implicit action call
    def create
    end

    # TODO: Remove in favour of an implicit action call
    def update
    end

    # TODO: Remove in favour of an implicit action call
    def destroy
    end

    ## Public API

    def populate?
      # Only populate if the calling controller matches the intended resources.
      # Otherwise the assumption is that the object was populated by
      # accepts_nested_attributes_for.
      validate? && params[:controller].singularize == view.view_path.rpartition('/').first
    end

    def validate?
      [:create, :update].include? params[:action]
    end

    def submit?
      should_submit = [:create, :update, :destroy].include? params[:action]
      should_submit = should_submit && valid? if validate?
      should_submit
    end

    def operation
      params[:action]
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
        super - [:populate, :validate, :create, :update, :destroy] # TODO: remove once implicit actions are available.
      end
    end
  end
end
