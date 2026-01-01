// ToPpm - dump out an image URL as PPM
//
// Given a URL as argument, it fetches the file and writes it onto stdout
// in the PPM image file format.
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
import java.util.*;
import java.awt.*;
import java.awt.image.*;

public class ToPpm extends Acme.Application
    {

    static final String progName = "ToPpm";

    // Old-style main() routine.  Calls compatibility routine for newMain().
    public static void main( String[] args )
        {
        (new ToPpm()).compat( args );
        }

    public int newMain( String[] args )
	{
	int argc = args.length;
	if ( argc != 1 )
	    {
	    usage();
	    return -1;
	    }
	dump( args[0] );
	return 0;
	}

    private void usage()
	{
	err.println( "usage:  " + progName + " URL" );
	}

    // Got to make one of these even if we don't use it, cause it loads
    // in some necessary native methods.
    private Toolkit tk = new Acme.JPM.StubToolkit();

    private void dump( String urlStr )
	{
	try
	    {
	    URL url = new URL( urlStr );
	    URLConnection uc = url.openConnection();
	    uc.connect();

	    // Got to open a stream to get around Java NullPointerException bug.
	    InputStream f = uc.getInputStream();

	    String mimeType = uc.getContentType();

	    // Java prints (not throws!) a ClassNotFoundException if you try
	    // a getContent on text.html or audio/basic (or no doubt many
	    // other types).
	    if ( ! mimeType.startsWith( "image/" ) )
		err.println( progName + ": " + urlStr + " is not an image" );
	    else
		{
		Object content = uc.getContent();
		if ( ! ( content instanceof ImageProducer ) )
		    err.println(
			progName + ": " + urlStr +
			" is not a known image type" );
		else
		    {
		    ImageProducer prod = (ImageProducer) content;
		    Acme.JPM.Encoders.ImageEncoder ie =
			new Acme.JPM.Encoders.PpmEncoder( prod, out );
		    ie.encode();
		    }
		}

	    // Done with unnecessary stream.
	    f.close();
	    }
	catch ( Exception e )
	    {
	    err.println( progName + ": " + e );
	    }
	}

    }
