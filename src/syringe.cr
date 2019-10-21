require "./syringe/*"

module Syringe
	macro included
		Syringe.wrap(\{{@type}})
	end

	macro wrap(klass)
		macro finished
			\{% for ctor in {{klass}}.methods.select { |m| m.name == "initialize" } %}
				def {{klass}}.new
				  \{% klass_module = {{klass.id.split("::").reject { |k| k == klass.id.split("::").last}.join("::") }} %}
					# Find all classes within this module.
					\{% module_classes = Object.all_subclasses.select { |k| klass_module != "" && k.id.includes?(klass_module) }.map { |k| k.id.split("::").last } %}
					# Call the defined constructor with injectable classes as the arguments.
					new(
            # Generate a block for every type defined in the constructor.
            \{% for arg in ctor.args %}
              # If the arg is an array of generics, we want to inject all descendants of a class.
              \{% if arg.restriction.is_a?(Generic) && arg.restriction.name.resolve == Array %}
                # Get the array base type.
                \{% array_type_classes = arg.restriction.type_vars.map { |v| v.resolve } %}
                # Get the descendants of a base type.
								\{% array_type_classes_descendants = Object.all_subclasses.select { |m| array_type_classes.any? {|k| m.ancestors.includes?(k) } } %}
							 	\{{arg.name.id}}: [
                  # Get instances for all descendants, and define the in an array.
                  \{% for injectable_class in array_type_classes_descendants %}
                    # If injected class is defined in module of this class.
                    \{% if module_classes.includes?(injectable_class) %}
                      # Call the get injected class method with the module.
                      Syringe.get\{{klass_module.id.tr(":","_")}}__\{{injectable_class.id.tr(":","_")}},
                    \{% else %}
                      # Call the get injected class method.
                      Syringe.get\{{injectable_class.id.tr(":","_")}},
                    \{% end %}
                  \{% end %}
                # All items in array have to be of this array class method.
                ] of \{{ array_type_classes.first }}
              \{% else %}
                # If injected class is defined in module of this class.
                \{% if module_classes.includes?(arg.restriction.id.stringify) %}
                  # Call the get injected class method with the module.
									\{{arg.name.id}}: Syringe.get\{{klass_module.id.tr(":","_")}}__\{{arg.restriction.id.tr(":","_")}},
                \{% else %}
                  # Call the get injected class method.
									\{{arg.name.id}}: Syringe.get\{{arg.restriction.id.tr(":","_")}},
								\{% end %}
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

  macro injectable_as(klass_to_inject)
		Syringe.injectable_as(\{{@type}}, klass_to_inject)
	end

	macro injectable(klass)
    macro finished
      def Syringe.get{{ klass.id.tr(":","_") }}
        return {{ klass.id }}.new
      end
		end
  end

  macro injectable_as(klass, klass_to_inject)
    macro finished
      def Syringe.get{{ klass_to_inject.id.tr(":","_") }}
        return {{ klass.id }}.new
      end
		end
	end

	macro provide(*klasses)
		macro finished
			{% for klass in klasses %}
				def Syringe.get{{klass.id.tr(":","_")}}
					return \{{@type}}.getInstance
				end
			{% end %}
		end
	end
end
