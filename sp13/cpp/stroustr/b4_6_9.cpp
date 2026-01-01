#include <stream.hxx>

struct user {
     char *name;
     char* id;
     int dept;
};

typedef user* Puser;

user heads[] = {
   "Mcilroy M.D",     "doug", 11271,
   "Aho A.v.",        "ava",  11272,
   "Weinberger P.J.", "pjw",  11273,
   "Schryer N.L.",    "nls",  11274,
   "Schryer N.L.",    "nls",  11275, 
   "Kernighan B.W.",  "bwk",  11276
};

typedef int (*CFT)(char*,char*);

void sort(char* base, unsigned n, int sz, CFT cmp)
{
   for (int i=0; i<n-1; i++)
       for (int j=n-1; i<j; j--) {
           char* pj = base+j*sz;
           char *pj1 = pj-sz;
           if ((*cmp)(pj,pj1) < 0)
              // swap b[j] and b[j-1]
             for (int k=0; k<sz; k++) {
                 char temp = pj[k];
                 pj[k] = pj1[k];
                 pj1[k] = temp;
             }
       }
} 

void print_id(Puser v, int n)
{
    for (int i=0; i<n; i++)
        cout << v[i].name << "\t"
             << v[i].id   << "\t"
             << v[i].dept << "\n";
}
extern int strcmp(char*, char*);

int cmp1(char* p, char* q)
{
    return strcmp(Puser(p)->name, Puser(q)->name);
}

int cmp2(char* p, char* q)
{
    return Puser(p)->dept - Puser(q)->dept;
}

main ()
{
    sort((char*)heads,6,sizeof(user),cmp1);
    print_id(heads,6);
    cout << "\n";
    sort ((char*)heads,6,sizeof(user),cmp2);
    print_id(heads,6);       // in department number order 
}

