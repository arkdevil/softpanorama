To compile the described modules, put plugin.hpp to their directories.

FileCase
~~~~~~~~
File case conversion command. Compile filecase.cpp to get DLL module.
This is simple plugin and it can be useful to learn how to implement
new FAR commands.

MultiArc
~~~~~~~~
Archive support plugin. Compile multiarc.cpp to get DLL module.
This is large and far from to be easy to understand, but it supports
second level plugins, which allow to add new archiver support,
writing few Kb source. Read MultiArc\Formats\ReadMe.txt for second-level
plugins description.

Network
~~~~~~~
Network browser plugin. Compile network.cpp to get DLL module.
Currently it does not work with some network types under Windows 95.
If you know how to correct it, please write me.

TmpPanel
~~~~~~~~
Temporary panel plugin. Compile tmppanel.cpp to get DLL module.
