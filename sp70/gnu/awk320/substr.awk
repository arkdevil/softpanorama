# Abbreviate the country names to their first three characters
# AKW p43

{ $1 = substr($1, 1, 3); print $0 }
