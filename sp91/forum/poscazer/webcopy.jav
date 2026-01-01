// WebCopy - copy a remote web subtree to the local disk
//
// Given one or more URLs as arguments, enumerates the files reachable at
// or below those URLs and copies them to the local disk, creating
// subdirectories as necessary.
//
// Options:
//
//   -v
//     Verbose.  Shows names of files being copied.
//
//   -f
//     Force overwriting of existing files.  Otherwise they are left alone.
//
//   -d
//     Maximum depth to copy.  Depth refers to how many links to follow.
//     A depth of 0 means just copy the file given on the connald line,
//     don't follow any links at all.  Without this flag there is no limit
//     on the depth, the entire subtree is copied.
//
//   -e
//     Edit local URLs.  If an HTML file contains a URL that is
//     <B>unnecessarily</B> absolute - i.e. it's absolute but it refers to
//     a location within the tree being copied - then convert it to a
//     relative URL.  Without this flag, all files are copied verbatim.
//     With it, the copied tree is a self-contained functional snapshot
//     of the remote.
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

public class WebCopy extends Acme.Application implements Acme.HtmlEditObserver
    {

    static final String progName = "WebCopy";

    static final String index_html = "index.html";

    // Old-style main() routine.  Calls compatibility routine for newMain().
    public static void main( String[] args )
        {
        (new WebCopy()).compat( args );
        }

    private boolean verbose = false;
    private boolean forceOverwrite = false;
    int maxDepth = -1;
    private boolean editLocalUrls = false;

    private String baseUrlStr;

    public int newMain( String[] args )
	{
	int argc = args.length;
	int argn;

	// Parse args.
	for ( argn = 0; argn < argc && args[argn].charAt( 0 ) == '-'; ++argn )
	    {
	    if ( args[argn].equals( "-v" ) )
		verbose = true;
	    else if ( args[argn].equals( "-f" ) )
		forceOverwrite = true;
	    else if ( args[argn].equals( "-d" ) )
		{
		++argn;
		maxDepth = Integer.parseInt( args[argn] );
		}
	    else if ( args[argn].equals( "-e" ) )
		editLocalUrls = true;
	    else
		{
		usage();
		return -1;
		}
	    }

	if ( argc - argn < 1 )
	    {
	    usage();
	    return -1;
	    }

	for ( ; argn < argc; ++argn )
	    copy( args[argn] );
	return 0;
	}

    private void usage()
	{
	err.println( "usage:  " + progName + " [-v] [-f] [-d maxDepth] [-e] URL ..." );
	}

    void copy( String urlStr )
	{
	baseUrlStr = Acme.Utils.baseUrlStr( urlStr );
        Enumeration spider;
        try
	    {
            spider = new WebCopySpider( urlStr, err, this );
	    }
        catch ( MalformedURLException e )
            {
            err.println( e );
            return;
            }

        while ( spider.hasMoreElements() )
            {
            URLConnection uc = (URLConnection) spider.nextElement();
	    if ( uc == null )	// non-fatal error
		continue;
            URL thisUrl = uc.getURL();
            String thisUrlStr = thisUrl.toExternalForm();
	    InputStream s = null;

            try
		{
		// Open the input file.  We have to do this up here instead of
		// down where we open the output file because Spider requires
		// us to always open and close the input file - that's what
		// causes it to scan the file for links.  So we always open
		// it, and we call close() in a finally block.
		s = uc.getInputStream();

		// Figure out the local filename.
		if ( ! thisUrlStr.startsWith( baseUrlStr ) )
		    {
		    err.println(
			"Something's wrong - " + thisUrlStr +
			" doesn't begin with the base URL, " + baseUrlStr );
		    continue;
		    }
		String localName = thisUrlStr.substring( baseUrlStr.length() );
		localName = localName.replace( '/', File.separatorChar );
		if ( localName.length() == 0 ||
		     localName.charAt( localName.length() - 1 ) ==
			 File.separatorChar )
		    localName = localName + index_html;
		else if ( Acme.Utils.urlStrIsDir( thisUrlStr ) )
		    localName = localName + File.separatorChar + index_html;

		// Make sure the local directories exist.
		if ( localName.lastIndexOf( File.separatorChar ) != -1 )
		    {
		    String localDirs = localName.substring(
			0, localName.lastIndexOf( File.separatorChar ) );
		    File dirsFile = new File( localDirs );
		    if ( dirsFile.exists() )
			{
			// Something exists there.  Is it a directory?
			if ( ! dirsFile.isDirectory() )
			    {
			    // We have a file where we want a directory.  Ugh.
			    // Rename the file to be index.html in the
			    // directory.
			    String tempName = progName + ".tmp";
			    File tempFile = new File( tempName );
			    if ( ! dirsFile.renameTo( tempFile ) )
				{
				err.println(
				    "Error renaming existing file for " +
				    localName );
				continue;
				}
			    if ( ! dirsFile.mkdirs() )
				{
				err.println(
				    "Error creating directories for " +
				    localName );
				continue;
				}
			    String newName =
				localDirs + File.separatorChar + index_html;
			    File newFile = new File( newName );
			    if ( ! tempFile.renameTo( newFile ) )
				{
				err.println(
				    "Error renaming temporary file for " +
				    localName );
				continue;
				}
			    }
			}
		    else
			{
			// The directory doesn't exist yet, so make it.
			if ( ! dirsFile.mkdirs() )
			    {
			    err.println(
				"Error creating directories for " + localName );
			    continue;
			    }
			}
		    }

		// Check the output file.
		File localFile = new File( localName );
		if ( localFile.exists() && ! forceOverwrite )
		    {
		    err.println( localName + " already exists - skipping" );
		    continue;
		    }

		if ( verbose )
		    err.println(
			"Copying " + thisUrlStr + " to " + localName );

		// If we're editing the URLs, interpose an HtmlEditScanner.
		if ( editLocalUrls && ( s instanceof Acme.HtmlScanner ) )
		    s = new Acme.HtmlEditScanner( (Acme.HtmlScanner) s, this );

		// Open the output file.
		OutputStream out = new FileOutputStream( localFile );

		// Copy the file.
		byte[] buf = new byte[4096];
		int len;
		while ( ( len = s.read( buf ) ) != -1 )
		    out.write( buf, 0, len );

		out.close();
		}
            catch ( IOException e ) {}
	    finally
		{
		try
		    {
		    if ( s != null )
			s.close();
		    }
		catch ( IOException e ) {}
		}
            }
	}

    /// Callback from HtmlEditScanner.
    public String editAHREF( String urlStr, URL contextUrl, Object junk )
	{
	return editAny( urlStr, contextUrl );
	}

    /// Callback from HtmlEditScanner.
    public String editIMGSRC( String urlStr, URL contextUrl, Object junk )
	{
	return editAny( urlStr, contextUrl );
	}

    /// Callback from HtmlEditScanner.
    public String editBASEHREF( String urlStr, URL contextUrl, Object junk )
	{
	return editAny( urlStr, contextUrl );
	}

    /// Callback from HtmlEditScanner.
    public String editAREAHREF( String urlStr, URL contextUrl, Object junk )
	{
	return editAny( urlStr, contextUrl );
	}

    // If the URL is absolute but doesn't need to be, then make it
    // relative.
    private String editAny( String urlStr, URL contextUrl )
	{
	if ( ! editLocalUrls )
	    return null;
	// If the URL is not absolute, leave it alone.
	if ( ! Acme.Utils.urlStrIsAbsolute( urlStr ) )
	    return null;
	// It's absolute.
	try
	    {
	    String fullUrlStr =
		Acme.Utils.fixDirUrlStr(
		    Acme.Utils.absoluteUrlStr( urlStr, contextUrl ) );
	    if ( ! fullUrlStr.startsWith( baseUrlStr ) )
		return null;
	    // It's unnecessarily absolute.  Trim it.
	    String contextUrlStr =
		Acme.Utils.fixDirUrlStr( contextUrl.toExternalForm() );
	    int sameSpan = Acme.Utils.sameSpan( contextUrlStr, fullUrlStr );
	    int sameSlashSpan =
		fullUrlStr.lastIndexOf( '/', sameSpan - 1 ) + 1;
	    String samePart =
		fullUrlStr.substring( 0, sameSlashSpan );
	    String differentPart =
		fullUrlStr.substring( sameSlashSpan );
	    int contextSlashes =
		Acme.Utils.charCount( contextUrlStr, '/' );
	    int sameSlashes =
		Acme.Utils.charCount( samePart, '/' );
	    StringBuffer newUrlStr = new StringBuffer();
	    if ( sameSlashes < contextSlashes )
		{
		// Going up.
		for ( int i = contextSlashes; i > sameSlashes; --i )
		    newUrlStr.append( "../" );
		}
	    // And back down the other side.
	    newUrlStr.append( differentPart );
	    // If we're left with nothing at all, make it be index.html.
	    if ( newUrlStr.length() == 0 )
		newUrlStr.append( index_html );
	    // That ought to do it.
	    return newUrlStr.toString();
	    }
	catch ( MalformedURLException e )
	    {
	    // Bogus URL?  Ignore.
	    return null;
	    }
	}

    }


class WebCopySpider extends Acme.Spider
    {
    private WebCopy parent;
    
    public WebCopySpider( String urlStr, PrintStream err, WebCopy parent ) throws MalformedURLException
	{
	super( urlStr, err );
	this.parent = parent;
	}

    protected boolean doThisUrl( String thisUrlStr, int depth, String baseUrlStr )
	{
	if ( thisUrlStr.startsWith( baseUrlStr ) &&
	     ( parent.maxDepth == -1 || depth <= parent.maxDepth ) )
	    return true;
	return false;
	}
    }
