# from the article:
# "A Walk Through AWK" by Leon S. Levy
# SIGPLAN Notices, V18, #12, December 1983

                                # Prepare a formatted listing of
                                # all occurances of a given keyword
                                # in a file

BEGIN {
        pagesize = 16
        outlines = 0
        NR = -1;
}

outlines % pagesize == 0 && length(lines) != 0 {
                                # new page initialization
                                # print the page header

        printf "\n Pages and lines where AWK occurs\n"
        printf " Page        Lines\n"
        printf " ____        _____\n\n"

        outlines = 6
        newoutpage = 1
}

/AWK/ {                         # if the string "AWK"
                                # occurs in the current record
        occurances++
        pageno = int(NR / 33) + 1
        lineno = (NR % 66) + 1
        if (lines == "") {
                pages = pageno
                lines = lineno
        }
        else if (pages == pageno && length(lines) < 40)
                lines = lines ", " lineno
        else {
                printf "%5d        %s\n",pages, lines
                outlines++
                pages = pageno
                lines = lineno
        }
}
END {
        if (lines != "")
                printf "%5d        %s\n", pages, lines
        printf "\n%d occurances of AWK\n", occurances
}

