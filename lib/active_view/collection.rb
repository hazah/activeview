module ActiveView
  class Collection < ActiveView::Base
    abstract!

    def self.inherited(klass) # :nodoc:
      presenter = Class.new(ActiveView::Presenter) do
        include ActiveView::CollectionPresenter
      end
      klass.instance_variable_set(:@_presenter, presenter)
      super
    end

    ActiveSupport.run_load_hooks(:active_view_index, self)
  end
end
