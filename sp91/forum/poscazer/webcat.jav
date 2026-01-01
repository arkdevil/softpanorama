// WebCat - fetch URLs and write them to stdout
//
// Fetches the specified URLs and dumps them to stdout.
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

import java.net.*;
import java.io.*;

public class WebCat extends Acme.Application
    {

    static final String progName = "WebCat";

    // Old-style main() routine.  Calls compatibility routine for newMain().
    public static void main( String[] args )
        {
        (new WebCat()).compat( args );
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
	    cat( args[argn] );
	return 0;
	}

    private void usage()
	{
	err.println( "usage:  " + progName + " URL ..." );
	}

    void cat( String urlStr )
	{
	try
	    {
	    URL url = new URL( urlStr );
	    InputStream f = url.openStream();
	    byte[] buf = new byte[4096];
	    int len;
	    while ( ( len = f.read( buf ) ) != -1 )
		out.write( buf, 0, len );
	    f.close();
	    }
	catch ( Exception e )
	    {
	    err.println( progName + ": " + e );
	    }
	}

    }
