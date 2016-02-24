module ActiveView
  class Form < ActiveView::Base
    abstract!

    after_initialize { |view| process(:form) unless presenter.blank? }

    after_initialize do |view|
      unless presenter.blank?
        process(:validate) if presenter.should_validate?
      end
    end

    after_initialize do |view|
      unless presenter.blank?
        process(presenter.operation) if presenter.should_submit?
      end
    end

    around_renderable { |view| [:create, :update, :destroy].exclude? view.params[:action] }

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
