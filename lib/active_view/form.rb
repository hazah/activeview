module ActiveView
  class Form < ActiveView::Base
    abstract!

    after_initialize do |view|
      process(:form) unless presenter.blank?
    end

    after_initialize do |view|
      unless presenter.blank?
        process(:validate) if presenter.should_validate?
        process(presenter.operation) if presenter.should_submit?
      end
    end

    # We want to render invalid forms as well since we this allows to relay errors
    # to the user.
    def renderable?
      run_callbacks :renderable do
        true
      end
    end

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
