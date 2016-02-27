module ActiveView
  class Form < ActiveView::Base
    abstract!

    def self.inherited(klass) # :nodoc:
      super
      presenter = klass.instance_variable_get(:@_presenter)

      base = presenter
      presenter = Class.new(presenter) do
        define_singleton_method :name do
          base.name
        end
        include ActiveView::FormPresenter
      end
      klass.instance_variable_set(:@_presenter, presenter)
    end

    delegate :valid?, :submitted?, to: :presenter
    delegate :validate!, :submit!, to: :presenter

    define_model_callbacks :validate, :submit

    def validate
      run_callbacks :validate do
        validate!
      end
    end

    def submit
      run_callbacks :submit do
        submit!
      end
    end

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
