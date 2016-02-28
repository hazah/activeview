module ActiveView
  module CollectionPresenter
    extend ActiveSupport::Concern

    included do
      helper_method :collection
    end

    def populate(scope, view = nil)
      @scope, @view = scope, view
    end

    private

    def collection
      @scope.to_a.map do |item|
        if @view
          view = @_view.view(@view)
          view.populate(item)
          item = view
        end
        item
      end
    end
  end
end
