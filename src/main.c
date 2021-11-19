#include "tonc.h"
#include "amstrad2y_gly2.h"

int main() {
    // init

    REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;
    pal_bg_mem[0] = 0x0C02; // background color

    // init tte
    // tte_init_chr4c(0, BG_CBB(0)|BG_SBB(31), 0, 0x0201, CLR_WHITE, &verdana9Font, NULL);
    tte_init_chr4c(0, BG_CBB(0)|BG_SBB(31), 0, 0x0201, CLR_WHITE, &amstrad2y_gly2Font, NULL);

    tte_init_con();
    tte_printf("#{P:0,0}abcdefghijklm");
    tte_printf("#{P:0,12}nopqrstuvwxyz");

    while (1) {
        key_poll(); // update inputF
    }
}
