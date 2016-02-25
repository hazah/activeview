module ActiveView
  class Form < ActiveView::Base
    abstract!

    def inherited(klass) # :nodoc:
      super
      presenter = klass.instance_variable_get(:@presenter)
      presenter = Class.new(presenter) do
        define_singleton_method :name do
          presenter.name
        end
        include FormPresenter
      end

      klass.instance_variable_set(:@presenter, presenter)
    end

    after_initialize { |view| view.process(:populate) if view.populate? }
    after_initialize { |view| view.process(:validate) if view.validate? }
    after_initialize { |view| view.process(operation) if view.submit?   }

    delegate :populate?, :validate?, :submit?, :valid?, :submitted?, :operation, to: :presenter

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
