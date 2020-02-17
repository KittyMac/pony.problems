
// This is an example C header which the Pony transpiler will convert to Pony FFI definitions automagically


#define SQLITE_VERSION        "3.7.7.1"
#define SQLITE_VERSION_NUMBER 3007007
#define SQLITE_SOURCE_ID      "2011-06-28 17:39:05 af0d91adf497f5f36ec3813f04235a6e195a605f"

#define SQLITE_OPEN_READONLY         0x00000001
#define SQLITE_OPEN_READWRITE        0x00000002
#define SQLITE_OPEN_CREATE           0x00000004
#define SQLITE_OPEN_DELETEONCLOSE    0x00000008
#define SQLITE_OPEN_EXCLUSIVE        0x00000010
#define SQLITE_OPEN_AUTOPROXY        0x00000020
#define SQLITE_OPEN_URI              0x00000040
#define SQLITE_OPEN_MAIN_DB          0x00000100
#define SQLITE_OPEN_TEMP_DB          0x00000200
#define SQLITE_OPEN_TRANSIENT_DB     0x00000400
#define SQLITE_OPEN_MAIN_JOURNAL     0x00000800
#define SQLITE_OPEN_TEMP_JOURNAL     0x00001000
#define SQLITE_OPEN_SUBJOURNAL       0x00002000
#define SQLITE_OPEN_MASTER_JOURNAL   0x00004000
#define SQLITE_OPEN_NOMUTEX          0x00008000
#define SQLITE_OPEN_FULLMUTEX        0x00010000
#define SQLITE_OPEN_SHAREDCACHE      0x00020000
#define SQLITE_OPEN_PRIVATECACHE     0x00040000
#define SQLITE_OPEN_WAL              0x00080000


// Handle grouping sparse #defines into their own primitives
// ie Ideally this translates to
// primitive SqliteShm
//  fun unlock():U32 => 1
//  fun lock():U32 => 1
//  fun shared():U32 => 1
//  fun exclusive():U32 => 1

#define SQLITE_SHM_UNLOCK       1     // This is a comment, which should not break the grouping
#define SQLITE_SHM_LOCK         2
#define SQLITE_SHM_SHARED       4
#define SQLITE_SHM_EXCLUSIVE    8

// Handle strings the same way
// primitive ErrorMessage
//  fun app_did_finish():String => "Application did finish launching"
//  fun app_did_terminate():String => "Application did terminate"
//  fun unexpected_error():String => "An unexpected error was encountered"

#define ERROR_MESSAGE_APP_DID_FINISH       "Application did finish launching"
#define ERROR_MESSAGE_APP_DID_TERMINATE    "Application did terminate"
#define ERROR_MESSAGE_UNEXPECTED_ERROR     "An unexpected error was encountered"



typedef struct Inner
{
  int x;
} Inner;

typedef struct Outer
{
  struct Inner inner_embed;
  struct Inner* inner_var;
} Outer;

typedef struct {
  int x;
  int y;
  int z;
} StructWithNoName;


void modify_via_outer(Outer* s);
void modify_inner(Inner* s);


// TODO
enum CXCursorKind {
  CXCursor_UnexposedDecl                 = 1,
  CXCursor_StructDecl                    = 2,
  CXCursor_UnionDecl                     = 3,
  CXCursor_ClassDecl                     = 4,
  CXCursor_EnumDecl                      = 5,
}


int rand(void);
int rand_r(unsigned *seed);
void srand(unsigned seed);
void sranddev(void);

int printf(const char * restrict format, ...);
int fprintf(FILE * restrict stream, const char * restrict format, ...);
int sprintf(char * restrict str, const char * restrict format, ...);
int snprintf(char * restrict str, size_t size, const char * restrict format, ...);
int asprintf(char **ret, const char *format, ...);
int dprintf(int fd, const char * restrict format, ...);
int vprintf(const char * restrict format, va_list ap);
int vfprintf(FILE * restrict stream, const char * restrict format, va_list ap);
int vsprintf(char * restrict str, const char * restrict format, va_list ap);
int vsnprintf(char * restrict str, size_t size, const char * restrict format, va_list ap);
int vasprintf(char **ret, const char *format, va_list ap);
int vdprintf(int fd, const char * restrict format, va_list ap);

