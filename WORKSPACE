workspace(name = "com_github_horolsky_mbtxx")



load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

# Boost
# Famous C++ library that has given rise to many new additions to the C++ Standard Library
# Makes @boost available for use: For example, add `@boost//:algorithm` to your deps.
# For more, see https://github.com/nelhage/rules_boost and https://www.boost.org
http_archive(
    name = "com_github_nelhage_rules_boost",

    # Replace the commit hash in both places (below) with the latest, rather than using the stale one here.
    # Even better, set up Renovate and let it do the work for you (see "Suggestion: Updates" in the README).
    url = "https://github.com/nelhage/rules_boost/archive/973dc7b0f9b8f8a9c133232f1d30c20c2765de79.tar.gz",
    strip_prefix = "rules_boost-973dc7b0f9b8f8a9c133232f1d30c20c2765de79",
)
load("@com_github_nelhage_rules_boost//:boost/boost.bzl", "boost_deps")
boost_deps()



load("//:bazel/repositories.bzl", "external_repositories")

external_repositories()
