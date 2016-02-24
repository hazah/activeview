module ActiveView
  class Form < ActiveView::Base
    abstract!

    after_initialize { |view| process(:populate) if populate? }
    after_initialize { |view| process(:validate) if validate? }
    after_initialize { |view| process(operation) if submit?   }

    delegate :populate?, :validate?, :submit?, :valid?, :submitted?, :operation, to: :presenter

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
