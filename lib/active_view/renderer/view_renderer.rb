module ActiveView
  class ViewRenderer < ::ActionView::TemplateRenderer
    def render(context, options)
      @view    = context
      @details = extract_details(options)

      keys = options.has_key?(:locals) ? options[:locals].keys : []

      template = find_template(@view.view_path, options[:prefixes], false, keys, @details)

      prepend_formats(template.formats)

      @lookup_context.rendered_format ||= (template.formats.first || formats.first)

      render_template(template, options[:layout], options[:locals])
    end
  end
end
