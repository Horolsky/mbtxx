#define BOOST_TEST_MODULE My Test
#include <boost/test/unit_test.hpp>

#include "mbtxx/mbtxx.hpp"

BOOST_AUTO_TEST_CASE(test_boost_lib)
{
    mbtxx::app::hello_boost();
}

BOOST_AUTO_TEST_CASE(test_sol_lib)
{
    mbtxx::app::hello_lua_and_sol();
}
