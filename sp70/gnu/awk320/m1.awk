# From Jon Bentley's article in Computer Language June '90 (v7n6)
# LISTING 4

function error(s) {

    print "m1: " s >"CON"                                               #
    exit 1
}

function dofile(fname, savefile, savebuffer, newstring) {

    if (fname in activefiles)
        error("recursively reading file: " fname)
    activefiles[fname] = 1
    savefile = file
    file = fname
    savebuffer = buffer
    buffer = ""
    while (readline() != EOF) {
        if (index($0, "@") == 0) {
            print $0
        }
        else if ($0 ~ /^@define[ \t]/) {
            dodef(1)                                                    #
        }
        else if ($0 ~ /^@default[ \t]/) {
            dodef(0)                                                    #
        }
        else if ($0 ~ /^@include[ \t]/) {
            if (NF != 2) error("bad inlcude line")
            dofile(dosubs($2))
        }
        else if ($0 ~ /^@if[ \t]/) {
            if (NF != 2) error("bad if line")
            if (!($2 in symtab) || symtab[$2] == 0) gobble()
        }
        else if ($0 ~ /^@unless[ \t]/) {
            if (NF != 2) error("bad unless line")
            if (($2 in symtab) && symtab[$2] != 0) gobble()
        }
        else if ($0 ~ /^@fi[ \t]?/) {    # could do error checking
        }
        else if ($0 ~ /^@comment[ \t]?/) {
        }
        else {
            newstring = dosubs($0)
            if ($0 == newstring || index(newstring, "@") == 0)
                print newstring
            else
                buffer = newstring "\n" buffer
        }
    }
    close(fname)
    delete activefiles[fname]
    file = savefile
    buffer = savebuffer
}

function readline(      i, status) {

    status = ""
    if (buffer != "") {
        i = index(buffer, "\n")
        $0 = substr(buffer, 1, i - 1)
        buffer = substr(buffer, i + 1)
    }
    else {
        if (file == "-") {                                              #
            i = getline                                                 #
        }                                                               #
        else {                                                          #
            i = getline < file                                          #
        }                                                               #
        status = i <= 0 ? "EOF" : ""                                    #
    }
    return status
}

function gobble(        ifdepth) {

    ifdepth = 1
    while (readline()) {
        if ($0 ~ /^@(if|unless)[ \t]/) ifdepth++
        if ($0 ~ /^@fi[ \t]?/ && --ifdepth <= 0) break
    }
}

function dosubs(s,      l, r, i, m) {

    if (index(s, "@") == 0) return s
    l = ""  # Left of current pos: ready for output
    r = s   # Right of current: unexamined at this time
    while ((i = index(r, "@")) != 0) {
        l = l substr(r, 1, i - 1)
        r = substr(r, i + 1)            # Currently scanning @
        i = index(r, "@")
        if (i == 0) {
            l = l "@"
            break
        }
        m = substr(r, 1, i - 1)
        r = substr(r, i + 1)
        if (m in symtab) {
            r = symtab[m] r
        }
        else {
            l = l "@" m
            r = "@" r
        }
    }
    return l r
}

function dodef(def,     str, name) {

    name = $2
    sub(/^[ \t]*[^ \t]+[ \t]+[^ \t]+[ \t]+/, "")    # $0=$P($0,FS,3,NF)
    str = $0
    while (str ~ /\\$/) {
        if (readline() == EOF)
            error("EOF inside definition")
        sub(/^[ \t]+/, "")
        sub(/[ \t]*\\$/, "\n" $0, str)
    }
    if (def || !(name in symtab))                                       #
        symtab[name] = str
}

BEGIN {

    EOF = "EOF"
    if (ARGC == 1) dofile("-")                                          #
    else if (ARGC == 2) dofile(ARGV[1])
    else {
        print "Usage: m1 [file]" >"CON"                                 #
        exit
    }
}
