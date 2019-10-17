/* Header file for module: WINER
//
// Routines for winer Non Linear analysis of system to
// White Noise
//
// remember to delete this structure when no longer needed
*/
#include "tools.h"

#ifndef WINERLIB
#define WINERLIB

#define SPIKE   3 

typedef short dtype;
typedef struct wk1 *WK1;
typedef struct wk2 *WK2;
typedef struct header *HEADER;
 

struct wk1 
{
ARRAYf array;
float *taxis;
};

struct wk2 
{
int Nx;
int Ny;
float *data;
float *taxisx;
float *taxisy;
};

struct header
{
long int M;
float Fs;
};
 
WK1	winer1(FILE *rfp,float twin,int nspikes);
WK2	winer2(FILE *rfp,float twin,int nspikes);
ARRAYf  revcorr(FILE *rfp,float twin,int nspikes);
ARRAYf  revcorr2(FILE *rfp,float twin,int nspikes);
ARRAYf	Xcorr2(FILE *rfp,float twin,int nspikes);
ARRAYi	find_spikes(FILE *rfp,ARRAYi spike,int nspikes);
ARRAYf  find_ps_win(FILE *rfp,ARRAYi spike,int WN);
ARRAYf	norm_dc_rv1(ARRAYf array,int numspikes,float A);
ARRAYf  norm_dc_rv2(ARRAYf rvcor2,ARRAYf psw,ARRAYi spike,float Fs,int WN);
ARRAYf  norm_dc_xc2(ARRAYf xcor2,ARRAYf psw,ARRAYi spike,float Fs,int WN);
void 	print_wk1(FILE *wfp,WK1 wk);
void	print_wk2(FILE *wfp,WK2 wk);
HEADER	read_header(FILE *rfp,HEADER H);
WK2 	WK2_alloc(int Nx,int Ny);

ARRAYf read_data_block(FILE *rfp,int M);

#endif
