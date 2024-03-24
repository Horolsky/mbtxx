
#include <iostream>
#include <boost/json.hpp>

void test_boost()
{
    boost::json::object obj;
    obj["Hello"] = "World";
    std::cout << obj << std::endl;
}
