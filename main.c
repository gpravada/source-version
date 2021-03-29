#include "foobar_version.h"

#include <stdio.h>



int main(void) {

    printf("Version: %s\n", FOOBAR_VERSION);
    printf("SHA    :    %s\n", GIT_SHA);  

    return 0;

}
