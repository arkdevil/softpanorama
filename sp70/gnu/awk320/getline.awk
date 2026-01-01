# Date:  04-19-89  09:22
# From:  Will Duquette
# To:    Rob Duff
# Subj:  Awk V2.12
# 
# Using the "gsub()" function in certain ways breaks the "getline"
# function.  For example,
{ 
    gsub(/!/, ".")
    print
    getline
    print
}

