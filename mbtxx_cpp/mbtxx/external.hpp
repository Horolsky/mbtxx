/**
 * @file
 * @brief External includes and aliases for the library.
 *
 * @copyright (c) 2024 Oleksandr Khorolskyi
 *
 */

#ifndef MBTXX_EXTERNAL_HPP
#define MBTXX_EXTERNAL_HPP

#include <boost/json.hpp>
#include <boost/mp11.hpp>
#include <boost/program_options.hpp>

#include <sol/sol.hpp>


namespace mbtxx {
using namespace boost;
namespace js = boost::json;
namespace po = boost::program_options;
}

#endif // MBTXX_EXTERNAL_HPP
