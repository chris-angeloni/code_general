/* Header file for module: TOOLS
//
// I/O and data type tools
//
// remember to delete this structure when no longer needed
*/

#ifndef TOOLS
#define TOOLS

#define YES     1
#define NO      0
#define TRUE    1
#define FALSE   0
#define PI 	3.14159265359
#define GIG	131072	

typedef struct arrays  *ARRAYs;
typedef struct matrixs *MATRIXs;
typedef struct arrayf  *ARRAYf;
typedef struct matrixf *MATRIXf;
typedef struct arrayi  *ARRAYi;
typedef struct matrixi *MATRIXi;

struct arrayf
{
float *data;
int N;
};

struct matrixf
{
float **data;
int Nx;
int Ny;
};

struct arrayi
{
int *data;
int N;
};

struct matrixi
{
int **data;
int Nx;
int Ny;
};

struct arrays
{
short *data;
int N;
};

struct matrixs
{
short **data;
int Nx;
int Ny;
};


FILE	*OpenInfile(char *infile,char *str);
FILE	*OpenOutfile(char *Outfile,char *str);

ARRAYs init_ARRAYs(int N);
ARRAYi init_ARRAYi(int N);
ARRAYf init_ARRAYf(int N);
ARRAYs re_init_ARRAYs(ARRAYs A,int N);
ARRAYi re_init_ARRAYi(ARRAYi A,int N);
ARRAYf re_init_ARRAYf(ARRAYf A,int N);



#endif
