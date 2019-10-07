require "./syringe/*"

module Syringe
	macro included
		Syringe.wrap(\{{@type}})
	end

	macro wrap(klass)
		macro finished
			\{% for ctor in {{klass}}.methods.select { |m| m.name == "initialize" } %}
				 def {{klass}}.new
					 new(
						\{% for arg in ctor.args %}
							\{% if arg.restriction.is_a?(Generic) && arg.restriction.name.resolve == Array %}
								\{% array_type_classes = arg.restriction.type_vars.map { |v| v.resolve } %}
								\{% array_type_classes_descendants = Object.all_subclasses.select { |m| array_type_classes.any? {|k| m.ancestors.includes?(k) } } %}
							 	\{{arg.name.id}}: [
									\{% for injectable_class in array_type_classes_descendants %}
										Syringe.get\{{injectable_class}},
									\{% end %}
								] of \{{ array_type_classes.first }}
							\{% else %}
								\{{arg.name.id}}: Syringe.get\{{arg.restriction}},
							\{% end %}
					 	\{% end %}
					 )
				 end
			\{% end %}
		end
	end

	macro injectable
		Syringe.injectable(\{{@type}})
	end

	macro injectable(klass)
		macro finished
			def Syringe.get{{ klass }}
				return {{ klass.id }}.new
			end
		end
	end

	macro provide(*klasses)
		macro finished
			{% for klass in klasses %}
				def Syringe.get{{klass}}
					return \{{@type}}.getInstance
				end
			{% end %}
		end
  end

  macro auto_wrap(klass)
    \{% if !{{klass}}.methods.select { |m| m.name == "initialize" }.empty? %}
      \{% if !{{klass}}.methods.select { |m| m.name == "initialize" }[0].args.empty? %}
        Syringe.wrap({{klass}})
      \{% end %}
    \{% end %}
  end

  macro define_providers(*klasses)
    {% for klass in klasses  %}
      module {{ klass.id.split("::").reject { |k| k == klass.id.split("::").last}.join("::").id }}
        class {{ klass }}Provider
          Syringe.provide({{klass}})

          def self.getInstance
            {{klass}}.new
          end
        end
      end

      Syringe.auto_wrap({{klass}})
    {% end %}
  end

  macro define_singleton_providers(*klasses)
    {% for klass in klasses  %}
      module {{ klass.id.split("::").reject { |k| k == klass.id.split("::").last}.join("::").id }}
        class {{ klass }}Provider
          Syringe.provide({{klass}})

          @@instance = {{klass}}.new

          def self.getInstance
            @@instance
          end
        end
      end

      Syringe.auto_wrap({{klass}})
    {% end %}
  end
end
