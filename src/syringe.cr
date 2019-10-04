require "./syringe/*"

module Syringe
	macro included
		Syringe.wrap(\{{@type}})
	end

	macro wrap(klass)
		macro finished
			\{% for ctor in {{klass}}.methods.select { |m| m.name == "initialize" } %}
				 def {{klass}}.new
				    \{% nodule = {{klass.id.split("::").reject { |k| k == klass.id.split("::").last}.join("::") }} %}
					\{% module_classes = Object.all_subclasses.select { |k| nodule != "" && k.id.includes?(nodule) }.map { |k| k.id.split("::").last } %}
					 new(
						\{% for arg in ctor.args %}
							\{% if arg.restriction.is_a?(Generic) && arg.restriction.name.resolve == Array %}
								\{% array_type_classes = arg.restriction.type_vars.map { |v| v.resolve } %}
								\{% array_type_classes_descendants = Object.all_subclasses.select { |m| array_type_classes.any? {|k| m.ancestors.includes?(k) } } %}
							 	\{{arg.name.id}}: [
									\{% for injectable_class in array_type_classes_descendants %}
										\{% if arg.restriction.is_a?(Generic) && arg.restriction.name.resolve == Array %}
											\{% if module_classes.includes?(injectable_class) %}
												Syringe.get\{{nodule.id.tr(":","_")}}__\{{injectable_class.id.tr(":","_")}},
											\{% else %}
												Syringe.get\{{injectable_class.id.tr(":","_")}},
											\{% end %}
										\{% end %}
									\{% end %}
								] of \{{ array_type_classes.first }}
							\{% else %}
								\{% if module_classes.includes?(arg.restriction.id.stringify) %}
									\{{arg.name.id}}: Syringe.get\{{nodule.id.tr(":","_")}}__\{{arg.restriction.id.tr(":","_")}},
								\{% else %}
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

	macro injectable(klass)
		macro finished
			def Syringe.get{{ klass.id.tr(":","_") }}
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
