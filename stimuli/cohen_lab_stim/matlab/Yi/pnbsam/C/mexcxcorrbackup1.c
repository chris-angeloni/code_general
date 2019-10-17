/* xcorr.c */
#include "mex.h"

void mexcxcorr(double r[40], double c[2][40])
{
int nsample;
double a[40]; double b[40];
int i,j,k,l; double t; double temp;

 /*c = (double*)malloc(2*nsample*sizeof(double));
 r = (double*)malloc(1*nsample*sizeof(double));*/
 nsample=40;

 for (j=0;k<nsample;j++){
     a[j]=c[0][j];
     b[j]=c[1][j];
 }
 
 for (i=nsample-1;i>=0;i--)
 {
  t=b[0];
  for (k=0;k<=nsample-2;k++) {b[k]=b[k+1];}
  b[nsample-1]=t;
  temp=0;
  for (l=0;l<nsample;l++) {temp = temp+a[l]*b[l];}
  r[i]=temp;
 }
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
/*    if (nrhs!=2){
      mexErrMsgTxt("Two input argument allowed."); } 
    else if (nlhs>1){
      mexErrMsgTxt("Two many output arguments."); } */
    
    int mrows0, ncols0;
    double *c, *r;
    mrows0 = mxGetM(prhs[0]);
    ncols0 = mxGetN(prhs[0]);
    
    c = mxGetPr(prhs[0]);
    
    /* Creat matrix for the return argument. */
    plhs[0]=mxCreateDoubleMatrix(1,ncols0,mxREAL);
    r=mxGetPr(plhs[0]);
    
    
    mexcxcorr(r,c);
    
}