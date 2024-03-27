load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe",)

def external_repositories():



    lua_release = "5.4.6"
    maybe(
        http_archive,
        name = "lua",
        build_file = "@com_github_horolsky_mbtxx//bazel/third_party:lua.BUILD",
        sha256 = "7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88",
        strip_prefix = "lua-{}".format(lua_release),
        urls = [
            "https://www.lua.org/ftp/lua-{}.tar.gz".format(lua_release),
        ],
    )

    sol2_release = "v3.3.0"
    sol2_base_url = "https://github.com/ThePhD/sol2/releases/download/{}".format(sol2_release)

    http_file(
        name = "sol2_header",
        downloaded_file_path = "sol.hpp",
        url = "{}/sol.hpp".format(sol2_base_url),
        sha256 = "e095a961a5189863745e6c101124fce944af991f3d4726a1e82c5b4a885a187f"
    )

    http_file(
        name = "sol2_fwd",
        downloaded_file_path = "forward.hpp",
        url = "{}/forward.hpp".format(sol2_base_url),
        sha256 = "8fc34d74e9b4b8baa381f5e6ab7b6f6b44114cd355c718505495943ff6b85740"
    )

    http_file(
        name = "sol2_cfg",
        downloaded_file_path = "config.hpp",
        url = "{}/config.hpp".format(sol2_base_url),
        sha256 = "6c283673a16f0eeb3c56f8b8d72ccf7ed3f048816dbd2584ac58564c61315f02"
    )


    native.new_local_repository(
        name = "sol",
        path = "..",
        build_file = "@com_github_horolsky_mbtxx//bazel/third_party:sol.BUILD",
    )
