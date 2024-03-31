/**
 * @file
 * @brief Test Runner class.
 *
 * @copyright (c) 2024 Oleksandr Khorolskyi
 *
 */


#ifndef MBTXX_APP_CLI_HANDLER_HPP
#define MBTXX_APP_CLI_HANDLER_HPP

#include <array>
#include <string>
#include <vector>

#include "mbtxx/external.hpp"

namespace mbtxx::app {


class CliHandler
{
    static constexpr char* kInputKey{"script"};
    static constexpr char* kHelpKey{"help"};
    static constexpr char* kTagsKey{"tags"};
    static constexpr char* kLibKey{"lib-path"};

    std::string exec_path_ {};
    po::variables_map varmap_ {};
    std::vector<std::string> inputs_ {};
    po::options_description options_ {make_descr(inputs_)};


    static po::options_description make_descr(std::vector<std::string> &store_in)
    {

        po::options_description options("Options");
        options.add_options()
            (kHelpKey, "print help message")
            (kLibKey, po::value<std::string>(), "lib")
            (kTagsKey, po::value<std::string>(), "tags")
            (kInputKey, po::value(&store_in), "list of files")
        ;

        return options;
    }

  public:
    CliHandler(int argc, char* argv[])
    : exec_path_{argv[0]}
    {
        po::positional_options_description positional;
        positional.add(kInputKey, -1);

        auto parsed = po::command_line_parser(argc, argv)
            .options(options_)
            .positional(positional)
            .run();

        po::store(parsed, varmap_);
        po::notify(varmap_);

        if (inputs_.empty() && !is_help())
        {
            throw po::error("No input files provided");
        }
    }

    bool is_help() const
    {
        return varmap_.count(kHelpKey);
    }

    void print_help(std::ostream& os) const
    {
        os  << "Usage:\n  " << exec_path_ << " [OPTIONS] INPUT...\n\n"
            << options_ << "\n";
    }

    std::string const& exec_path() const
    {
        return exec_path_;
    }

    std::vector<std::string> const& inputs() const
    {
        return inputs_;
    }

    std::string tags() const
    {
        if (varmap_.count(kTagsKey))
        {
            return varmap_[kTagsKey].as<std::string>();
        }

        return {""};
    }

    std::string lib_path() const
    {
        if (varmap_.count(kLibKey))
        {
            return varmap_[kLibKey].as<std::string>();
        }

        return {""};
    }
};

} // namespace mbtxx::app

#endif // MBTXX_APP_CLI_HANDLER_HPP
