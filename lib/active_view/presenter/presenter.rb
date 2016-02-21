module ActiveView
  class Presenter < AbstractController::Base
    abstract!

    class << self
      def internal_methods
        superclass.internal_methods - [:show]
      end
    end

    attr_internal :model
    attr_internal :block

    def initialize(model, block)
      @_model = model
      @_block = block
    end

    def show
      block.call(model) unless block.blank?
    end
  end
end
