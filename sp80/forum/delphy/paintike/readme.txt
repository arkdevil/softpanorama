
Here is a simple example of how to paint your minimized window and create
a corresponding dynamic icon that Windows will use to drag your app and 
display when you Alt+Tab.  

To get the minimized painting stuff to work I had to use the Application 
HookMainWindow method.  I tried using a Application OnMessage handler, but
couldn't get it to work - if anyone figures out the trick please let me
know.

This code is FREE.  Do what you want with it, but don't blame me.

All comments are welcome!

Tim Noonan 
75212,664