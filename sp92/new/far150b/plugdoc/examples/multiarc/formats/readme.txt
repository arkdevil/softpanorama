Archive support plugin considers all *.fmt DLL modules in Formats
directory as second level plugins. Supplied here examples of such
plugins use mainly Win32 API functions and to reduce size in FAR
distributive they were compiled without standard C startup code.


Second-level archive support plugins have to export the following functions:

----------------------------------------------------------------------------
Called when second-level plugin module is loaded. This function
is optional, you may omit it.

DWORD WINAPI _export LoadFormatModule(
  char *ModuleName
);

Parameters:
  ModuleName - second-level plugin module name

Return value:
  Must be 0. In future it may be used to return second-level
  plugin information.
----------------------------------------------------------------------------
Check, is this file type supported or not.

BOOL WINAPI IsArchive(
  char *Name,
  const unsigned char *Data,
  int DataSize
);

Parameters:
  Name     - archive name
  Data     - archive data
  DataSize - archive data size

Return value:
  TRUE, if this archive type is supported.

----------------------------------------------------------------------------
Open archive and prepare to read it. Called after successful IsArchive.

BOOL WINAPI OpenArchive(
  char *Name,
  int *Type
);

Parameters:
  Name - archive name
  Type - if plugin supports several archive types, it must put type here,
         otherwise set *Type to 0

Return value:
  TRUE, if success.

----------------------------------------------------------------------------
Get next archive item. Called after OpenArchive.

int WINAPI GetArcItem(
  struct PluginPanelItem *Item,
  struct ArcItemInfo *Info
);

Parameters:
  Item - this structure must be filled. Read its description in plugins.hlp.
  Info - additional item info, which should be filled if possible.

    struct ArcItemInfo
    {
      char HostOS[32];       - Host OS name or empty if unknown
      char Description[256]; - Item description or empty string
      int Solid;             - "Solid" flag
      int Comment;           - Set if file comment is present
      int Encrypted;         - Set if file is encrypted
      int DictSize;          - Dictionary size or 0 if unknown
      int UnpVer;            - Version to unpack (HighNumber*256+LowNumber)
                               or 0 if unknown
    };

  This structure is passed to GetArcItem already filled by 0.

Return value:
  GETARC_EOF         End of archive
  GETARC_SUCCESS     Item successfully read
  GETARC_BROKEN      Archive broken
  GETARC_UNEXPEOF    Unexpected end of archive
  GETARC_READERROR   Read error

----------------------------------------------------------------------------
Close archive. Called after last GetArcItem call.

BOOL WINAPI CloseArchive(
  struct ArcInfo *Info
);

Parameters:
  Info - additional archive info, which should be filled if possible.

    struct ArcInfo
    {
      int SFXSize;  - SFX module size
      int Volume;   - Volume flag
      int Comment;  - Archive comment present
      int Recovery; - Recovery record present
      int Lock;     - Archive is locked
      int Flags;    - Additional archive information flags
    };

  'Flags' field can be combination of the following values:

   AF_AVPRESENT     Authenticity information present

   AF_IGNOREERRORS  Archiver commands exit code must be ignored
                    for this archive

  This structure is passed to CloseArchive already filled by 0.

Return value:
  TRUE, if successful.

----------------------------------------------------------------------------
Get archive format name.

BOOL WINAPI GetFormatName(
  int Type,
  char *FormatName,
  char *DefaultExt
);

Parameters:
  Type       - archive type
  FormatName - format name. It will be used to save parameters
               in registry and select desired format
  DefaultExt - default file extension for this format (without dot).
               Used to increase format recognizing speed.

Return value:
  TRUE, if successful. If specified Type value greater than supported,
  FALSE must be returned.

----------------------------------------------------------------------------
Get archiver command strings, used by default.

BOOL WINAPI GetDefaultCommands(
  int Type,
  int Command,
  char *Dest
);

Parameters:
  Type    - archive type
  Command - command number
    0 - extract
    1 - extract without path
    2 - test
    3 - delete
    4 - comment
    5 - comment files
    6 - convert to SFX
    7 - lock
    8 - add recovery record
    9 - recover
   10 - add files
   11 - move files
   12 - add files and folders
   13 - move files and folders
   14 - mask to select all files

  Dest    - buffer to copy the command

Return value:
  TRUE, if successful. If specified Type value greater than supported,
  FALSE must be returned. If Type is supported, but required command
  is absent, return TRUE and set Dest to empty string.

