#ifdef MAIN
	#define EXTERN
#else
	#define EXTERN extern
#endif

#ifndef DOS_DATE
#define DOS_DATE
typedef union {
	unsigned u;
	struct {
                unsigned Day   : 5;
		unsigned Month : 4;
		unsigned Year  : 7;
		} b;
	} DOS_FILE_DATE;
#endif

#ifndef DOS_TIME
#define DOS_TIME
typedef union {
	unsigned u;
	struct {
		unsigned Second : 5;
		unsigned Minute : 6;
		unsigned Hour   : 5;
		} b;
	} DOS_FILE_TIME;
#endif

struct ZipLocalFileHeader {
	unsigned VersionNeededToExtract;
	unsigned GeneralPurposeBitFlag;
	unsigned CompressionMethod;
	DOS_FILE_TIME LastModFileTime;
	DOS_FILE_DATE LastModFileDate;
	unsigned long Crc32;
	unsigned long CompressedSize;
	unsigned long UncompressedSize;
	unsigned FileNameLength;
	unsigned ExtraFieldLength;
	};

struct CentralDirectoryFileHeader {
	unsigned VersionMadeBy;
	unsigned VersionNeededToExtract;
	unsigned GeneralPurposeBitFlag;
	unsigned CompressionMethod;
	DOS_FILE_TIME LastModFileTime;
	DOS_FILE_DATE LastModFileDate;
	unsigned long Crc32;
	unsigned long CompressedSize;
	unsigned long UncompressedSize;
	unsigned FileNameLength;
	unsigned ExtraFieldLength;
	unsigned FileCommentLength;
	unsigned DiskNumberStart;
	unsigned InternalFileAttributes;
	unsigned long ExternalFileAttributes;
	unsigned long RelativeOffsetLocalHeader;
	};

struct EndCentralDirRecord {
	unsigned NumberThisDisk;
	unsigned CentralDirectoryStartDisk;
	unsigned CentralDirEntries_ThisDisk;
	unsigned TotalEntriesCentralDirectory;
	unsigned long SizeCentralDirectory;
	unsigned long OffsetStartCentralDirectory;
	unsigned ZipFileCommentLength;
	};

typedef unsigned long SIGNATURE;
typedef struct ZipLocalFileHeader ZIP_LOCAL_FILE_HEADER;
typedef struct CentralDirectoryFileHeader CENTRAL_DIRECTORY_FILE_HEADER;
typedef struct EndCentralDirRecord END_CENTRAL_DIRECTORY_RECORD;

#define LOCAL_FILE_HEADER_SIGNATURE 0x04034B50L
#define CENTRAL_FILE_HEADER_SIGNATURE 0x02014B50L
#define END_CENTRAL_DIR_SIGNATURE 0x06054B50L
#define SEARCH_SIZE 2048

#ifdef MAIN
char *ZipCompression[] = {
	" Stored ", " Shrunk ", "Reduce-1", "Reduce-2", "Reduce-3", "Reduce-4"
	};
#else
extern char *ZipCompression[];
#endif

/*   Prototypes for ZIP Processing Functions 	*/

void DoZip (char *Name);
void ProcessHeaders (FILE *ZIPFile, char *Path);
void ProcessLocalFileHeader (FILE *ZIPFile);
void ProcessCentralFileHeader (FILE *ZIPFile, char *Path);
void ProcessEndCentralDir (FILE *ZIPFile);
void GetString (FILE *ZIPFile, int Size, char *Buffer);
