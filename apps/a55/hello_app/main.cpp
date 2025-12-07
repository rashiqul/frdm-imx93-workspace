#include <iostream>
#ifdef USE_FMT
  #include <fmt/core.h>
#endif

int main(int argc, char** argv) {
#ifdef USE_FMT
    fmt::print("[A55] Hello from FRDM‑i.MX93! argc={} \n", argc);
#else
    std::cout << "[A55] Hello from FRDM‑i.MX93! argc=" << argc << std::endl;
#endif
    return 0;
}
