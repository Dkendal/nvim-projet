def fennel_project(name, srcs, visibility = None):
    for f in srcs:
        out = f.replace("fnl", "lua")

        native.genrule(
            name = f + "-fnl",
            cmd = "$(location @fennel//file) "
            srcs = [f],
            outs = [out],
            visibility = visibility,
            tools = ["@fennel//file"]
        )
