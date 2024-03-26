/**
 * @file
 * @brief Test Runner class.
 *
 * @copyright (c) 2024 Oleksandr Khorolskyi
 *
 */


#ifndef MBTXX_APP_TEST_RUNNER_HPP
#define MBTXX_APP_TEST_RUNNER_HPP

#include "mbtxx/external.hpp"
#include "mbtxx/app_cli_handler.hpp"

namespace mbtxx::app {

    // https://stackoverflow.com/questions/39932089/how-to-add-a-description-to-boostprogram-options-positional-options



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

        for (const auto& input : cli_handler_.inputs())
        {
            os_ << "Processing file: " << input << "\n";
        }
        return 0;
    }
};

} // namespace mbtxx::app



#endif // MBTXX_APP_TEST_RUNNER_HPP
