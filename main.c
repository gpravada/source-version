#include "foobar_version.h"

#include <stdio.h>



int main(void) {

    printf("Version: %s\n", FOOBAR_VERSION);
    printf("SHA    : %s\n", GIT_SHA);  
    printf("Branch : %s\n", GIT_BRANCH);  
    printf("Dirty? : %s\n", GIT_IS_DIRTY);  
    printf("Time   : %s\n", BUILD_TIMESTAMP);  

    return 0;

}
