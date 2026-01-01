/^#/ {
    print
    next
}

NF > 0 {
    if (start == "")
        start = $1
    end = $1
    $1 = ""
    l[end] = $0
}

END {

    h[start] = start
    q[1] = start
    n = 1
    m = 2
    while (n < m) {
        s = q[n++]                      #get next item in queue.
        split(l[s], b)                  #get connections
        for (i in b) {
            t = b[i]
            if (!(t in h)) {
                h[t] = h[s] "-" t
                if (t in l)
                    q[m++] = t          #add to end of queue
            }
        }
    }
    print "Solution"
    print ""
    if (end in h)
        print h[end]
    else
        print "no route from", start, "to", end
    print ""
    e[start] = ""
    e[end] = ""
    print "How-to-get-here list: Starting at", start
    print ""
    printf "%-20s  %s\n","Location:","Route:"
    for (x in h)
        if (!(x in e))
            printf "%-20s  %s\n",x":",h[x]
    print ""
    print "Inaccessible locations:"
    for (x in l)
        if (!(x in h))
            print x
}

