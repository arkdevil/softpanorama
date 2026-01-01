# calculate and print the factorial of the input

function factorial(n) {
    if (n <= 1)
        return 1
    else
        return n * factorial(n - 1)
}
{
    print $1, factorial($1)
}
