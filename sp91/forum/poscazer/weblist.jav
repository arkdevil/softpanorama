// WebList - make a list of the files in a web subtree
//
// This is basically "ls" for the web.  You give it one or more URLs
// as arguments.  It enumerates the files reachable at or below those
// URLs, and displays the nicely formatted results.
//
// Sample output:
//     % WebList http://www.acme.com/jef/flow/
//     text/html           993 Mar  8  9:52 .
//     image/jpeg         3107 Mar  1 18:14 troublemaker_small.jpg
//     text/html         39759 Mar 27  0:01 cdec.html
//     text/html          4046 Mar  5 19:34 noyo.html
//
// Copyright (C) 1996 by Jef Poskanzer <jef@acme.com>.  All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// Visit the ACME Labs Java page for up-to-date versions of this and other
// fine Java utilities: http://www.acme.com/java/

import java.util.*;
import java.net.*;
import java.io.*;

public class WebList extends Acme.Application
    {

    static final String progName = "WebList";

    // Old-style main() routine.  Calls compatibility routine for newMain().
    public static void main( String[] args )
	{
	(new WebList()).compat( args );
	}

    public int newMain( String[] args )
	{
	int argc = args.length;
	if ( argc == 0 )
	    {
	    usage();
	    return -1;
	    }
	for ( int argn = 0; argn < argc; ++argn )
	    {
	    if ( argc > 1 )
		{
		if ( argn > 0 )
		    out.println( "" );
		out.println( args[argn] + ":" );
		}
	    list( args[argn] );
	    }
	return 0;
	}

    private void usage()
	{
	err.println( "usage:  " + progName + " URL ..." );
	}

    void list( String urlStr )
	{
	String base = Acme.Utils.baseUrlStr( urlStr );
        Enumeration as;
        try
	    {
            as = new Acme.Spider( urlStr, err );
	    }
        catch ( MalformedURLException e )
            {
            err.println( e );
            return;
            }

	while ( as.hasMoreElements() )
	    {
	    URLConnection uc = (URLConnection) as.nextElement();
	    URL thisUrl = uc.getURL();
	    String thisUrlStr = thisUrl.toExternalForm();
	    if ( thisUrlStr.startsWith( base ) )  // should always be true
		{
		thisUrlStr = thisUrlStr.substring( base.length() );
		if ( thisUrlStr.length() == 0 )
		    thisUrlStr = ".";
		}
	    String mimeType = uc.getContentType();
	    int len = uc.getContentLength();
	    long mod = uc.getLastModified();
	    Date modDate = new Date( mod );
	    String modDateStr = Acme.Utils.lsDateStr( modDate );
	    out.println(
		Acme.Fmt.fmt( mimeType, 14, Acme.Fmt.LJ ) + " " + 
		Acme.Fmt.fmt( len, 8 ) + " " + 
		modDateStr + " " + thisUrlStr );
	    // Open and close, just to make sure it gets read.
	    try
		{
		InputStream in = uc.getInputStream();
		in.close();
		}
	    catch ( IOException e ) {}
	    }
	}

    }
