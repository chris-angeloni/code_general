/* xcorr.c */
#include "mex.h"

void mexcxcorr(double r[40],double a[40],double b[40])
{
 int i,k,l; double t; double temp; int n;
 n= 40;
 
 /* for (j=0;j<n;j++){
     a[j]=c[j][0];
     b[j]=c[j][1];
 } */
 
 
 for (i=n-1;i>=0;i--)
 {
  t=b[0];
  for (k=0;k<=n-2;k++) {b[k]=b[k+1];}
  b[n-1]=t;
  temp=0; 
  for (l=0;l<=n-1;l++) {temp = temp+a[l]*b[l];}
  r[i]=temp; 
 }
 
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *r, *a, *b;
    int mrows, ncols;
    
    /* if (nrhs!=1)
      mexErrMsgTxt("Only one input argument allowed.");  
    else if (nlhs!=1)
      mexErrMsgTxt("Only one output argument allowed."); */
    
    /*for (i=0; i<nrhs; i++)  {
	mexPrintf("\n\tInput Arg %i is of type:\t%s ",i,mxGetClassName(prhs[i]));
    }*/
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    a=mxGetPr(prhs[0]);
    b=mxGetPr(prhs[1]); 
    
    plhs[0]=mxCreateDoubleMatrix(1,ncols,mxREAL);
    
   /* the point for input and output */
    
    r=mxGetPr(plhs[0]);
    
    mexcxcorr(r,a,b);
    
}