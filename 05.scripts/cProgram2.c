#include <stdio.h>

int main() {
    int maxDepth = 0;
    int currentDepth = 0;

    // Level 1
    if (1) {
        currentDepth++;
        if (1) {
            currentDepth++;
            if (1) {
                currentDepth++;
                if (1) {
                    currentDepth++;
                    if (1) {
                        currentDepth++;
                        if (1) {
                            currentDepth++;
                            if (1) {
                                currentDepth++;
                                if (1) {
                                    currentDepth++;
                                    if (1) {
                                        currentDepth++;
                                        if (1) {
                                            currentDepth++;
                                            if (1) {
                                                currentDepth++;
                                                if (1) {
                                                    currentDepth++;
                                                    if (1) {
                                                        currentDepth++;
                                                        if (1) {
                                                            currentDepth++;
                                                            if (1) {
                                                                currentDepth++;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Level 2
    for (int i = 0; i < 5; i++) {
        currentDepth++;
        // Level 3
        for (int j = 0; j < 3; j++) {
            currentDepth++;
            // Level 4
            for (int k = 0; k < 2; k++) {
                currentDepth++;
            }
        }
    }

    maxDepth = currentDepth;

    printf("The deepest nesting level is: %d\n", maxDepth);
    return 0;
}
