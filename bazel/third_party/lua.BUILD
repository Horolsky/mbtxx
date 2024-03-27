package(
    default_visibility = ["//visibility:public"],
)


cc_library(
    name = "lua_includes",
    hdrs = [
        "src/lauxlib.h",
        "src/lua.h",
        "src/luaconf.h",
        "src/lualib.h",
    ],
    includes = ["src"],
)

cc_library(
    name = "lua",
    srcs = glob(["src/l*"], exclude=["src/lua.c", "src/luac.c"]),
    hdrs = [
        "src/lauxlib.h",
        "src/lua.h",
        "src/luaconf.h",
        "src/lualib.h",
    ],
    copts = ["-w"],
    defines = ["LUA_USE_LINUX"],
    includes = ["src"],
    linkopts = [
        "-lm",
        "-ldl",
    ],
)
