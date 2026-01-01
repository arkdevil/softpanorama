Xref: feenix.metronet.com comp.infosystems.www:693
Newsgroups: comp.infosystems.www
Path: feenix.metronet.com!news.utdallas.edu!wupost!spool.mu.edu!agate!linus!linus.mitre.org!linus!sbakke
From: sbakke@xcuseme.MITRE.org (Steve Bakke)
Subject: C to HTML converter
Message-ID: <SBAKKE.93Jul9073807@xcuseme.MITRE.org>
Lines: 177
Sender: news@linus.mitre.org (News Service)
Nntp-Posting-Host: xcuseme.mitre.org
Organization: MITRE Corp. McLean Va.
Date: Fri, 9 Jul 1993 11:38:07 GMT
Lines: 177


Hello,

  here is a perl script that takes ctags output and converts C source to
hyper text files.  This will allow you to walk through your source code
as easily as walking through any other hyper text documentation.  


Steve Bakke

c-to-html
--------- CUT HERE ---------------
#!/usr/local/bin/perl
#
#  NAME
#    c-to-html
#
#  SYNOPSIS
#    c-to-html 
#    
#  DESCRIPTION
#    This perl script will generate hyper text files from C source code
#    using ctags output.  
#
#  HOW TO USE
#
#    1. Run ctags for your source directory tree.
#       Something like:
#       
#       ctags -txw *.c *.h > CTAGS
#
#       Or for a source tree:
#
#	find . \( -name '*.h' -o -name '*.c' \) -exec ctags -txw {} > CTAGS \;
#
#
#    2. Now run:
#
#       c-to-html CTAGS
#       
#       This should read CTAGS and place each hypertext file in a subdirectory
#       called html.
#
#  AUTHOR
#    Steven M. Bakke sbakke@mitre.org
#      
#  NOTES
#    As this is one of my first perl scripts, please let me
#    know how this can be improved.  Please send any changes and 
#    suggestions to sbakke@mitre.org.
#
#


$_ = shift(ARGV);

if ($_)  {
    $tagsfile = $_;
}
else {
    print "usage: c-to-html ctags-file\n";
    exit;
}




if (!open(TAGS, $tagsfile)) {
    print STDERR "Could not open tags file.\n";
}

if (!(-d "html")) {
    system("mkdir html");
}

@tags = <TAGS>;

foreach $line (@tags) {
    ($node, $lno, $path, $pat) = $line =~ /(\w[^0123456789 ]*)\s*(\d*)\s*(\S*)\s*(.*)$/;

#    print "LINE: [$node]\t[$lno]\t[$path]\t[$pat]\n";

    @path_split = split(/\//, $path);
    $file = $path_split[$#path_split];
    @files{$path} = $file;	# Save the filename from the path.

    @patterns{"$path:$lno"} = "$node:$lno:$path:$pat";
    @references{$node} = "$node:$lno:$path:$pat";
}


#exit(0);
foreach $file (keys(%files)) {



    #
    # Open the source file.
    # 
    print "opening: $file -- [$files{$file}]\n";
    if (!open(INFILE, $file)) {
	print STDERR "Can't open $file. bye\n";
    }
    else {

	# 
	# Create the hypertext file.
	# 
	$outfile = "> html/$files{$file}.html";
	if (!open(OUTFILE, $outfile)) {
	    print STDERR "Can't open output file for $outfile.\n";
	    exit(0);
	}
	
	$line_count = 0;
	
	print OUTFILE "<PRE>";
	print OUTFILE "<LI><H2>FILE: $file</H2>";
	while ($_ = <INFILE>) {
	    $line_count++;
	    
	    chop;
	    s/ /y/;			# Remove this annoying character.
	    s/</&lt;/;		
	    s/>/&gt;/;

#	s/\/\*/<H4>\/\*/;	# Put comments in H4 bold
#	s/\*\//\*\/<\/H4>/;	# End comment bold.
	    
	    

	    if (($info = $patterns{"$file:$line_count"})) {
		($node, $lno, $path, $pat) = split(/:/,$info);
		print OUTFILE "<LI><H3><a name=\"$node\">$_</a></H3>\n"
		}
	    
	    # 
	    # Setup link for includes.
	    # 
	    elsif (/include/) {
		if (/&lt;/) {
		    $li = "&lt;";
		    $ri = "&gt;";
		}
		else {
		    $li = $ri = "\"";
		}
		
		($left, $include_file, $right)  = split(/\"|&lt;|&gt;/, $_);
		print OUTFILE "$left $li<A NAME=$line_count HREF=\"$include_file.html\">$include_file</A>$ri $right\n";
	    }
	    else {
		$found = 0;
		
		@words = split(/\W/, $_);
		
		foreach $word (@words) {
		    if (!$found && $word && (($ref_info = $references{$word}))) {
			
			($node, $lno, $path, $pat) = split(/:/, $ref_info);
			($left, $right) = split(/$word/, $_);
			
			print OUTFILE "$left<a href=\"$files{$path}.html\#$word\">$word</a>$right\n";
			$found = 1;
			
		    }
		}
		
		if (!$found) {
		    print OUTFILE $_, "\n";
		}
	    }
	    
	}
    }
}

