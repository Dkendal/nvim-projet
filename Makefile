FNL = fennel --require-as-include \
			--add-fennel-path spec/?.fnl \
			--add-fennel-path fnl/?.fnl \
			--add-package-path lua/?.lua \
			--add-package-path build/lua/?.lua \
			--compile

@PHONY:
test:
	fd .fnl ./fnl/ --exec-batch mkdir -p build/{//}
	fd .fnl ./fnl/ --exec sh -c "${FNL} {} > build/{.}.lua"
	fd _spec.fnl / --exec-batch mkdir -p build/{//}
	fd _spec.fnl ./spec/ --exec sh -c "${FNL} {} > build/{.}.lua"
	busted build/spec

%.rock:
	luarocks install $*

deps: fennel.rock
	luarocks install fennel
	luarocks install inspect
	luarocks install lume
	luarocks install lpeg

deps.test: deps
	luarocks install inspect
	luarocks install busted
