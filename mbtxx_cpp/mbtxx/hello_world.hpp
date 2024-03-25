/**
 * @file
 * @brief Initial external libs include test, to be removed.
 *
 * @copyright (c) 2024 Oleksandr Khorolskyi
 *
 */


#ifndef MBTXX_APP_HELLO_WORLD_HPP
#define MBTXX_APP_HELLO_WORLD_HPP

#include "mbtxx/external.hpp"

namespace mbtxx::app {

inline void hello_boost()
{
    json::object obj;
    obj["Hello"] = "World";
    std::cout << obj << std::endl;
}


inline void hello_lua_and_sol()
{
    sol::state lua;
    lua.open_libraries(sol::lib::base, sol::lib::package);
    lua.script("print('Hello, World!')");
}


} // namespace mbtxx::app


#endif // MBTXX_APP_HELLO_WORLD_HPP
