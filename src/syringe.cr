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
							  \{{arg.name.id}}: Syringe.get\{{arg.restriction}},
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
end
