/**
 * @file
 * @brief Test Runner class.
 *
 * @copyright (c) 2024 Oleksandr Khorolskyi
 *
 */


#ifndef MBTXX_APP_TEST_RUNNER_HPP
#define MBTXX_APP_TEST_RUNNER_HPP


#include <filesystem>
#include <iostream>
#include <set>
#include <string>


#include "mbtxx/external.hpp"
#include "mbtxx/app_cli_handler.hpp"
#include "mbtxx/app_lua_handler.hpp"


namespace mbtxx::app {


class TestRunner
{
    CliHandler cli_handler_;

    std::ostream& os_;

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

        for (const auto& script : cli_handler_.inputs())
        {
            os_ << "Processing file: " << script << "\n";
            try
            {
                LuaHandler lua_handler(script, cli_handler_.lib_path());
                auto result = lua_handler(cli_handler_.tags());

                if (!result.valid()) {
                    sol::error err = result;
                    std::cerr << "failed to execute the loaded script" << err.what() << std::endl;
                }
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
