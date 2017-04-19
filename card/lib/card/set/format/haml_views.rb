class Card
  module Set
    module Format
      TEMPLATE_DIR = "template".freeze
      # Support haml templates in a Rails like way:
      # If the view option `template: :haml` is set then wagn expects a haml template
      # in a corresponding template path and renders it.

      #
      # @example
      #   # mod/core/set/type/basic.rb
      #   view :my_view, template: :haml  # renders mod/core/view/type/basic/my_view.haml
      #
      #   view :with_instance_variables, template: :haml do
      #     @hello = "haml"
      #   end
      #
      #   # mod/core/view/type/basic/with_instance_variables.haml
      #   Hello
      #     = hello
      #
      #   > render :with_instance_variables  # => "Hello haml"
      module HamlViews
        def haml_view_block view, &block
          template = ::File.read haml_template_path view
          if block_given?
            haml_temlate_render_block_with_locals view, template, &block
          else
            haml_template_render_block view, template
          end
        end

        def haml_template_render_block view, template
          proc do |view_args|
            voo = View.new(self, view, view_args, @voo)
            with_voo voo do
              haml_to_html template, view_args
            end
          end
        end

        def haml_template_render_block_with_locals view, template
          proc do |view_args|
            instance_exec view_args, &block
            locals = instance_variables.each_with_object({}) do |var, h|
              h[var.to_s.tr("@", "").to_sym] = instance_variable_get var
            end
            voo = View.new(self, view, view_args, @voo)
            with_voo voo do
              haml_to_html template, locals
            end
          end
        end

        def haml_template_path view, source=nil
          source ||= source_location
          basename = ::File.basename(source, ".rb")
          source_dir = ::File.dirname(source)
          ["./#{basename}", "."].each do |template_dir|
            path = try_haml_template_path(template_dir, view, source_dir)
            binding.pry
            return path if path
          end
          raise(Card::Error, "can't find haml template for #{view}")
        end

        def try_haml_template_path template_path, view, source_dir, ext="haml"
          path = ::File.expand_path("#{template_path}/#{view}.#{ext}", source_dir)
                   .sub(%r{(/mod/[^/]+)/set/}, "\\1/#{TEMPLATE_DIR}/")
          ::File.exist?(path) && path
        end

        def haml_to_html haml, locals, a_binding=nil
          a_binding ||= binding
          ::Haml::Engine.new(haml).render a_binding, locals || {}
        end
      end
    end
  end
end
