module ActiveView
  class Form < ActiveView::Base
    abstract!

    delegate :save, to: :object

    def initialize(parent, controller = nil, object = {}, &block)
      super
      process(:form) unless presenter.blank?
      if should_process? && process(:validate)
        process(:process_form)
      end
    end

    # We want to render invalid forms as well since we this allows to relay errors
    # to the user.
    def renderable?
      run_callbacks :renderable do
        true
      end
    end

    private

    def should_process?
      true
    end

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
