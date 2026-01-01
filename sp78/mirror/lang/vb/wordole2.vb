
                                    EXPLODE
                                       
                              AUTOMATING MS WORD
                                       
   
   
   Author: [1]Steve Moulton
   
   Unless you have been marooned on a desert island (without any access
   to the Internet) you are probably fully aware of the emphasis
   Microsoft is now placing on the use of OLE automation and Visual Basic
   as the way forward in designing and producing the next generation of
   custom applications for business. There is hardly a Microsoft product
   that has not been revised to include some element of OLE
   functionality, or at least announced that it will be included in the
   next release. Third party software vendors have been equally
   enthusiastic in their support for the technology. But this is not
   surprising given the market for products that interface seamlessly
   with Microsoft Office is substantial. To the developer this opens up a
   whole new tool set with which to build applications. In the same way
   that VBX custom controls have become accepted additions to the Visual
   Basic environment, so too will OLE automation objects.
   
From print to full-blown wordprocessor

   
   
   Imagine starting from scratch in VB to develop a print routine that
   will allow your users to have a print preview function. You might
   already have done one. I have. It is not a difficult task once you
   know the language and the environment, but it does take a considerable
   amount of time. Then, having completed that task the user needs a zoom
   function, then how about a printer set-up routine, the ability to
   change printers, to reformat the style... and so it goes on. Before
   you know it you have written a word processor or at least a pale
   imitation of one. It would be far better (and save an awful lot of
   heartache) if the original print function had simply sent the text to
   a Word document. Once it's there the entire functionality of Word
   would be available to your program and to your user. The same argument
   can apply to all OLE automation objects. Building further capabilities
   into your application can be achieved by utilising the programmable
   objects that other applications expose. Using existing applications
   saves time and money.
   
Start simple

   
   
   You might think that nothing this useful is going to be that easy. In
   principle that's true. To use OLE effectively you have to know the
   subject from both sides, within VB and within each object that you
   want to use. This is no mean task. A complex application like Word or
   Excel has many hundreds of different commands. However, in the same
   way that it's not necessary to know every command in VB before
   producing a useful programs, so a lot can be done with a little
   knowledge of your target application.
   
   
   
   Remember at the end of the day it will be your application that is in
   control. If you don't know about a function then it won't be used. To
   illustrate this I will take you through the few steps required to
   create a powerful utility that will allow your VB application to
   create standard letters based on a Word document template. It will
   enable the user to modify the template after your application is
   distributed including the deletion or addition of data items supplied
   by your application, or even create new templates for letters or
   indeed any purpose. I will break the utility down into small pieces,
   explaining the process as I go, and pointing out any pitfalls that
   must be avoided. To create this utility you must have the professional
   edition of VB 3 and Word 6 installed on your PC.
   
First steps

   
   
   The first thing to do is create a new project with a single form and
   two command buttons called Create Document and Close. At this stage
   the form only needs to be quite small and can be positioned towards
   the bottom of the screen. Next you give the form a caption such as
   'Create Word Document' and add the statement
   
   Dim wrd As object
   
   to the general declarations section. This prepares the necessary
   storage for the OLE automation object. Now you should create a
   routine:
   
   Sub CreateWordDocument ()
   Set wrd = CreateObject("word.basic")
   wrd.FileNewDefault
   wrd.Insert "Test Text"
   End Sub
   
   The CreateObject function will start Word if it is not already
   running, or return a reference to the currently running copy. Note if
   more than one copy of Word is running then an arbitrary choice is made
   by Windows. An alternative command would be to use GetObject. With
   Word the two are synonymous. An existing instance is always returned
   if available, or a new one is created. However, this is not the case
   with all OLE automation objects. When Word is opened in this way there
   will not be an open document so the next statement creates a new
   document using the NORMAL.DOT template. Finally a little text is
   inserted into the document. Another module is required:
   
   Sub CloseWordDocument ()
   wrd.FileClose 2
   Set wrd = Nothing
   End Sub
   
   The FileClose command with the parameter 2 closes the document without
   saving (fine for now). Setting wrd to Nothing frees up the memory used
   within the VB application and causes OLE to reduce the reference count
   on Word by one. If there are no references left, OLE closes Word
   automatically. For this reason it would be normal in a larger project
   to declare the Word object globally so that you do not inadvertently
   cause it to go out of scope and close. You can now call the two
   routines from the appropriate command buttons and add AppActivate and
   the Caption from the form to the Create button and End to the Close
   button. If all goes well clicking the Create button when the
   application will start Word, open a blank document, insert the text
   and then AppActivate will cause the VB application to appear on top.
   Click Close to end the whole thing. To keep things simple you should
   make sure that Word is not currently running.
   
Creating a template

   
   
   Before the next stage you will need to create a document template in
   Word that this application can access. To do this you should open
   Word, select New from the File Menu and choose the new template
   option. Word will present a blank page. You now type a little text on
   the first line, press enter twice and type a little more text and move
   the insertion point back up to the blank line. The whole process is
   made a lot easier if the various markers are visible by selecting
   Options from the Tools menu and clicking the View tab. In particular
   you should ensure that Bookmarks are visible.
   
   
   
   Next you insert a Bookmark by selecting Bookmark from the Edit menu,
   type a name and click Add. A bookmark must consist only of
   alpha-numeric characters plus the underscore and may be no longer than
   forty characters. The template will now contain a grey I-bar at the
   insertion point, referenced by the name you entered. It is this that
   will provide VB with the ability to modify a document created using
   your Template, and ultimately allow your users to modify and create
   documents that your applications can interface with. The template is
   complete so you can Save it as OLEWORD.DOT and move it to the
   sub-directory where the project is saved.
   
Using bookmarks

   
   
   Bookmarks are useful in a number of ways in Word but their most useful
   function is in jumping to a specific location in a document. VB can
   interrogate Word for the names of bookmarks in a document by adding
   the following:
   
   Dim mnBookMarkCount As Integer
   Dim i As Integer
   
   to the declarations section and a routine to the application:
   
   Sub GetBookmarksFromWord ()
   gnBookMarkCount = wrd.CountBookmarks()
   For i = 1 To gnBookMarkCount
   wrd.editbookmark (wrd.BookmarkName(i)), 0, , , True
   wrd.Insert wrd.BookmarkName(i)
   Next
   End Sub
   
   This routine first asks Word for the number of bookmarks that the
   document contains, then for each one jumps to the location using the
   EditBookMark method. Unfortunately VB does not yet support named
   parameters, so it is essential to use the correct number of commas or
   you may add or delete bookmarks. To keep things simple at this stage
   the bookmark name is then inserted into the document. Now amend the
   CreateWordDocument routine:
   wrd.FileNew app.Path & "\OLEWORD.DOT"
   GetBookmarksFromWord
   This time when the application is run the new document is based on the
   previously created template that contains a bookmark. VB moves to the
   bookmark and inserts text at that point.
   
Now try it yourself

   
   
   So now that the application can navigate around a Word document using
   positioning that the user can modify the next stage is to insert some
   useful data. Other issues to consider include how to handle a
   minimised instance, allowing file saving, printing etc. For further
   reading consult the Microsoft Office Developers Kit supplied with the
   professional edition of VB, or watch this space.
   
   
   
   Steve Moulton is a Solution Developer at Datasure VP. A software house
   developing applications for the insurance industry
