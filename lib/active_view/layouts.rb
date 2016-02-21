require "active_support/core_ext/module/remove_method"

module ActiveView
  module Layouts
    extend ActiveSupport::Concern

    included do
      class_attribute :_layout, :_layout_conditions, :instance_accessor => false
      self._layout = nil
      self._layout_conditions = {}
      _write_layout_method
    end

    delegate :_layout_conditions, to: :class

    module ClassMethods
      def inherited(klass) # :nodoc:
        super
        klass._write_layout_method
      end

      # This module is mixed in if layout conditions are provided. This means
      # that if no layout conditions are used, this method is not used
      module LayoutConditions # :nodoc:
        private

        # Determines whether the current action has a layout definition by
        # checking the action name against the :only and :except conditions
        # set by the <tt>layout</tt> method.
        #
        # ==== Returns
        # * <tt> Boolean</tt> - True if the action has a layout definition, false otherwise.
        def _conditional_layout?
          return unless super
          true
        end
      end

      # Specify the layout to use for this class.
      #
      # If the specified layout is a:
      # String:: the String is the template name
      # Symbol:: call the method specified by the symbol, which will return the template name
      # false::  There is no layout
      # true::   raise an ArgumentError
      # nil::    Force default layout behavior with inheritance
      #
      # ==== Parameters
      # * <tt>layout</tt> - The layout to use.
      #
      # ==== Options (conditions)
      # * :only   - A list of actions to apply this layout to.
      # * :except - Apply this layout to all actions but this one.
      def layout(layout, conditions = {})
        include LayoutConditions unless conditions.empty?

        conditions.each {|k, v| conditions[k] = Array(v).map {|a| a.to_s} }
        self._layout_conditions = conditions

        self._layout = layout
        _write_layout_method
      end

      # Creates a _layout method to be called by _default_layout .
      #
      # If a layout is not explicitly mentioned then look for a layout with the controller's name.
      # if nothing is found then try same procedure to find super class's layout.
      def _write_layout_method # :nodoc:
        remove_possible_method(:_layout)

        prefixes    = _implied_layout_name =~ /\blayouts/ ? [] : ["layouts"]
        default_behavior = "lookup_context.find_all('#{_implied_layout_name}', #{prefixes.inspect}).first || super"
        name_clause = if name
          default_behavior
        else
          <<-RUBY
            super
          RUBY
        end

        layout_definition = case _layout
          when String
            _layout.inspect
          when Symbol
            <<-RUBY
              #{_layout}.tap do |layout|
                return #{default_behavior} if layout.nil?
                unless layout.is_a?(String) || !layout
                  raise ArgumentError, "Your layout method :#{_layout} returned \#{layout}. It " \
                    "should have returned a String, false, or nil"
                end
              end
            RUBY
          when Proc
            define_method :_layout_from_proc, &_layout
            protected :_layout_from_proc
            <<-RUBY
              result = _layout_from_proc(#{_layout.arity == 0 ? '' : 'self'})
              return #{default_behavior} if result.nil?
              result
            RUBY
          when false
            nil
          when true
            raise ArgumentError, "Layouts must be specified as a String, Symbol, Proc, false, or nil"
          when nil
            name_clause
        end

        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def _layout
            if _conditional_layout?
              #{layout_definition}
            else
              #{name_clause}
            end
          end
          private :_layout
        RUBY
      end

      private

      # If no layout is supplied, look for a template named the return
      # value of this method.
      #
      # ==== Returns
      # * <tt>String</tt> - A template name
      def _implied_layout_name # :nodoc:
        view_path
      end
    end

    attr_internal_writer :view_has_layout

    def initialize(*) # :nodoc:
      @_view_has_layout = true
      super
    end

    # Controls whether an action should be rendered using a layout.
    # If you want to disable any <tt>layout</tt> settings for the
    # current action so that it is rendered without a layout then
    # either override this method in your controller to return false
    # for that action or set the <tt>action_has_layout</tt> attribute
    # to false before rendering.
    def view_has_layout?
      @_view_has_layout
    end

  private

    def _conditional_layout?
      true
    end

    # This will be overwritten by _write_layout_method
    def _layout; end

    # Determine the layout for a given name, taking into account the name type.
    #
    # ==== Parameters
    # * <tt>name</tt> - The name of the template
    def _layout_for_option(name)
      case name
      when String     then _normalize_layout(name)
      when Proc       then name
      when true       then Proc.new { _default_layout(true)  }
      when :default   then Proc.new { _default_layout(false) }
      when false, nil then nil
      else
        raise ArgumentError,
          "String, Proc, :default, true, or false, expected for `layout'; you passed #{name.inspect}"
      end
    end

    def _normalize_layout(value)
      value.is_a?(String) && value !~ /\blayouts/ ? "layouts/#{value}" : value
    end

    # Returns the default layout for this controller.
    # Optionally raises an exception if the layout could not be found.
    #
    # ==== Parameters
    # * <tt>require_layout</tt> - If set to true and layout is not found,
    #   an ArgumentError exception is raised (defaults to false)
    #
    # ==== Returns
    # * <tt>template</tt> - The template object for the default layout (or nil)
    def _default_layout(require_layout = false)
      begin
        value = _layout if view_has_layout?
      rescue NameError => e
        raise e, "Could not render layout: #{e.message}"
      end

      if require_layout && view_has_layout? && !value
        raise ArgumentError,
          "There was no default layout for #{self.class} in #{view_paths.inspect}"
      end

      _normalize_layout(value)
    end

    def _include_layout?(options)
      (options.keys & [:body, :text, :plain, :html, :inline, :partial]).empty? || options.key?(:layout)
    end
  end
end
