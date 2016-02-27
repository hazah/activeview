module ActiveView
  module FormPresenter
    extend ActiveSupport::Concern

    ## Public API

    def validate!
      @_valid = process(:validate)
    end

    def submit!
      process(:submit).tap do |result|
        @_submitted = true
      end
    end

    def valid?
      @_valid ||= false
    end

    def submitted?
      @_submitted ||= false
    end
  end
end
