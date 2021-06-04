FNL = fennel --require-as-include \
			--add-fennel-path spec/?.fnl \
			--add-fennel-path fnl/?.fnl \
			--add-package-path lua/?.lua \
			--compile

@PHONY:
test:
	fd _spec.fnl ./spec/ --exec-batch mkdir -p build/{//}
	fd _spec.fnl ./spec/ --exec sh -c "${FNL} {} > build/{.}.lua"
	busted build/spec
