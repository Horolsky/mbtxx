#include <iostream>

#include "mbtxx/mbtxx.hpp"


int main(int argc, char* argv[]) {
    return mbtxx::app::TestRunner(argc, argv, std::cout).run();
}
