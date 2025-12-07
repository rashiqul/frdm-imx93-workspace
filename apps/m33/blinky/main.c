#include <stdint.h>

volatile uint32_t counter = 0;

int main(void) {
    // TODO: init clocks, gpio for LED, etc.
    while (1) {
        counter++;
        // spin to simulate work
        for (volatile uint32_t i = 0; i < 100000; ++i) {}
        // TODO: toggle LED
    }
    return 0;
}
