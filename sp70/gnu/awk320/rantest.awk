# count the number of random numbers in ten bins

BEGIN {
    srand()
    for (i = 0; i < 20; i++) {
        for (j = 0; j < 1000; j++)
            x[int(10 * rand())]++
        printf(".");
    }
    printf("\n");
    for (i in x)
        printf(" %s: %6d\n", i, x[i])
}

