
MOCHA - the Java decompiler - version beta 1


1. LEGAL CRAP

Mocha is copyright 1995, 1996 by Hanpeter van Vliet

Use at your own risk. I do not guarantee the fitness of Mocha for any purpose, and I do not accept responsibility for any damage you do to yourself or others by using Mocha.

The distribution archive (file "mocha-b1.zip") may be distributed freely, provided its contents ("mocha.zip" and this file, "readme.txt") are not tampered with in any way.

2. INSTALLATION

There is no need to unzip the "mocha.zip" file contained in the distribution zip file; Java knows how to get .class files out of zip files. Simply put "mocha.zip" in a safe place, for instance the JDK directory.

Add the full pathname of "mocha.zip" to your CLASSPATH string, for instance:

    SET CLASSPATH=c:\myclasses;c:\jdk\mocha.zip

3. INVOCATION

Mocha is invoked from the commandline (i.e. DOS box, if you're using Win95) like this:

    java mocha.Decompiler [-v] [-o] Class1.class Class2.class ...

Where
   "java"               invokes the Java virtual machine,
   "mocha.Decompiler"   (note the case!) specifies the class to run,
   "-v"                 optionally specifies verbose output,
   "-o"                 optionally overwrites existing .mocha files,
   "ClassX.class"       specifies the .class file(s) to decompile.

Wildcards (* and ?) are accepted.

4. SUPPORT

Mocha is quite useable but far from perfect, I know. It's only a beta, so be gentle with it! There may be cases where Mocha gets confused and it will tell you so. I will continue to improve Mocha to deal with such situations, and to keep up with evolving Java technology.

Improved versions of Mocha will first be made available on 

    http://www.inter.nl.net/users/H.P.van.Vliet/mocha.htm

Problems can be reported via the form at

    http://www.inter.nl.net/users/H.P.van.Vliet/problem.htm


