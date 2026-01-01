# accumulate totals and transactions for each person
# print the transactions in a separate file for each person
# print the total and average when done

NF == 2 { a[$1] += $2; b[$1]++
          printf "%-6s %3d %3d %3d\n", $1, $2, a[$1], b[$1] >$1
        }
END     { print ""
          for (i in a)
                printf "%-6s %3d %6.1f %3d\n", i, a[i], a[i]/b[i], b[i]
        }

