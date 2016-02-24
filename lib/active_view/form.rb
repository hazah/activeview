module ActiveView
  class Form < ActiveView::Base
    abstract!

    after_initialize { |view| process(:form) }
    after_initialize { |view| process(:validate)           if presenter.should_validate? }
    after_initialize { |view| process(presenter.operation) if presenter.should_submit?   }

    around_renderable { |view| [:create, :update, :destroy].exclude? view.params[:action] }

    delegate :validation_passed?, :submitted?, to: :presenter

    ActiveSupport.run_load_hooks(:active_view_form, self)
  end
end
