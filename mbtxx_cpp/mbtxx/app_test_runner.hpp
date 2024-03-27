/**
 * @file
 * @brief Test Runner class.
 *
 * @copyright (c) 2024 Oleksandr Khorolskyi
 *
 */


#ifndef MBTXX_APP_TEST_RUNNER_HPP
#define MBTXX_APP_TEST_RUNNER_HPP

#include <set>
#include <string>
#include <filesystem>


#include <boost/format.hpp>

#include "mbtxx/external.hpp"
#include "mbtxx/app_cli_handler.hpp"

namespace mbtxx::app {


class TestRunner
{
    CliHandler cli_handler_;
    std::ostream& os_;

    bool run_script(const std::string& input)
    {
        sol::state lua;
        lua.open_libraries(
            sol::lib::base,
            sol::lib::package,
            sol::lib::coroutine,
            sol::lib::string,
            sol::lib::os,
            sol::lib::math,
            sol::lib::table,
            sol::lib::debug,
            sol::lib::bit32,
            sol::lib::io
        );

        std::string add_path = std::filesystem::path(input).parent_path().append("?.lua;");
        std::string path_upd = (format("package.path = \"%s/\" .. package.path") % add_path).str();
        lua.script(path_upd);


        sol::load_result fx = lua.load_file(input);
        if (!fx.valid()) {
            sol::error err = fx;
            std::cerr << "failed to load string-based script into the program" << err.what() << std::endl;
            return false;
        }

        sol::protected_function_result result = fx(cli_handler_.exec_path(), input);

        if (!result.valid()) {
            sol::error err = result;
            std::cerr << "failed to execute the loaded script" << err.what() << std::endl;
            return false;
        }

        return true;
    }

  public:
    TestRunner(int argc, char* argv[], std::ostream& os = std::cout)
        : cli_handler_{argc, argv}
        , os_{os}
    {
    }


    int run()
    {
        if (cli_handler_.is_help())
        {
            cli_handler_.print_help(os_);
            return 0;
        }

        for (const auto& input : cli_handler_.inputs())
        {
            os_ << "Processing file: " << input << "\n";
            try
            {
                run_script(input);
            }
            catch(const std::exception& e)
            {
                std::cerr << e.what() << '\n';
            }
        }
        return 0;
    }
};

} // namespace mbtxx::app



#endif // MBTXX_APP_TEST_RUNNER_HPP
