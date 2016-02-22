module ActiveView
  class FormPresenter < ActiveView::Presenter
    abstract!

    class << self
      def internal_methods
        superclass.internal_methods - [:form, :validate, :process_form] # TODO: remove once implicit actions are available.
      end
    end

    # TODO: Remove in favour of an implicit action call
    def form
    end

    def validate
      model.validate
    end

    def process_form
      model.save
    end

  end
end
