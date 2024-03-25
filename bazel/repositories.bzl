load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe",)

def external_repositories():


    maybe(
        http_archive,
        name = "lua",
        build_file = "@com_github_horolsky_mbtxx//bazel/third_party:lua.BUILD",
        sha256 = "b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b",
        strip_prefix = "lua-5.2.4",
        urls = [
            "https://mirror.bazel.build/www.lua.org/ftp/lua-5.2.4.tar.gz",
            "https://www.lua.org/ftp/lua-5.2.4.tar.gz",
        ],
    )

    sol2_release = "v3.3.0"
    sol2_base_url = "https://github.com/ThePhD/sol2/releases/download/{}".format(sol2_release)

    http_file(
        name = "sol2_header",
        downloaded_file_path = "sol.hpp",
        url = "{}/sol.hpp".format(sol2_base_url),
    )

    http_file(
        name = "sol2_fwd",
        downloaded_file_path = "forward.hpp",
        url = "{}/forward.hpp".format(sol2_base_url),
    )

    http_file(
        name = "sol2_cfg",
        downloaded_file_path = "config.hpp",
        url = "{}/config.hpp".format(sol2_base_url),
    )


    native.new_local_repository(
        name = "sol",
        path = "..",
        build_file = "@com_github_horolsky_mbtxx//bazel/third_party:sol.BUILD",
    )
