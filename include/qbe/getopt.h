extern char *optarg;
extern int optind;
extern int opterr;
extern int optopt;
struct option { char *name; int has_arg; int *flag; int val; };
int getopt(int, char **, char *);
int getopt_long(int, char **, char *, struct option *, int *);
#define no_argument 0
#define required_argument 1
#define optional_argument 2
