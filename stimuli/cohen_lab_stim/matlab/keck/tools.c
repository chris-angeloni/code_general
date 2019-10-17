#include        <stdio.h>
#include        <stdlib.h>
#include        <math.h>
#include        <string.h>
#include        <malloc.h>
#include	"tools.h"

/******************************************************************
 *                                                                *
 *FUNCTION NAME: INIT ARRAYs                                      *
 *DESCRIPTION  : Initializes a short array of N.                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYs init_ARRAYs(int N)
{
ARRAYs A;

A=(ARRAYs)malloc(sizeof(struct arrays));
A->data=(short *)calloc(N,sizeof(short));
A->N=N;

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: INIT ARRAYi                                      *
 *DESCRIPTION  : Initializes an int array of N.                   *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYi init_ARRAYi(int N)
{
ARRAYi A;

A=(ARRAYi)malloc(sizeof(struct arrayi));
A->data=(int *)calloc(N,sizeof(int));
A->N=N;

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: INIT ARRAYf                                      *
 *DESCRIPTION  : Initializes a float array of N.                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf init_ARRAYf(int N)
{
ARRAYf A;

A=(ARRAYf)malloc(sizeof(struct arrayf));
A->data=(float *)calloc(N,sizeof(float));
A->N=N;

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: RE INIT ARRAYs                                   *
 *DESCRIPTION  : Re Initializes a short array of N.               *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYs re_init_ARRAYs(ARRAYs A,int N)
{
A->data=realloc(A->data,N*sizeof(short));
A->N=N;

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: RE INIT ARRAYi                                   *
 *DESCRIPTION  : Re Initializes an int array of N.                *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYi re_init_ARRAYi(ARRAYi A,int N)
{
A->data=realloc(A->data,N*sizeof(int));
A->N=N;

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: RE INIT ARRAYf                                   *
 *DESCRIPTION  : Re Initializes a float array of N.               *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf re_init_ARRAYf(ARRAYf A,int N)
{
A->data=realloc(A->data,N*sizeof(float));
A->N=N;

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: OPEN INFILE                                      *
 *DESCRIPTION  : Oepens the input filename and creates infile     *
 *               ptr.                                             *
 *                                                                *
 ******************************************************************/

FILE *OpenInfile(char *infile,char str[5])
{
FILE *RFP;

if((RFP=fopen(infile,str))==NULL)
        {
        printf("Can not open %s.",infile);
        exit(0);
        }

return RFP;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: OPEN OUTFILE                                     *
 *DESCRIPTION  : Opens the output filename and creates outfile    *
 *               ptr.                                             *
 *                                                                *
 ******************************************************************/

FILE *OpenOutfile(char *Outfile,char str[5])
{
FILE *WFP;

if((WFP=fopen(Outfile,str))==NULL)
        {
        printf("Can not open %s.",Outfile);
        exit(0);
        }

return WFP;
}
