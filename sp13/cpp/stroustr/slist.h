// 7.3.1
// This header file declares:-

class slist;
class slist_iterator;

typedef void* ent;

class slink {
friend class slist;
friend class slist_iterator;
    slink* next;
    ent e;
    slink(ent a, slink* p) { e=a; next =p; }
};

class slist {
friend class slist_iterator;
    slink* last;
public:
    int insert(ent a);
    int append(ent a);
    ent get();
    void clear();

    slist()      { last=0; }
    slist(ent a) { last=new slink(a,0); last->next=last; }
    ~slist()     { clear(); }
};    

// 7.3.2
class slist_iterator {
    slink* ce;
    slist* cs;
public:
    slist_iterator(slist& s) { cs = &s; ce = 0; }

    ent operator()() {
        slink* ll;
        if (ce == 0)
           ll = ce = cs->last;
        else {
            ce = ce->next;
            ll = (ce==cs->last) ? 0 : ce;
        }
        return ll ? ll->e : 0;
     }
};
