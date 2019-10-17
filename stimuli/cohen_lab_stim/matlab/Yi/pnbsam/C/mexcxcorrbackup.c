/* xcorr.c */
#include "mex.h"

void mexcxcorr(double r[1024],double c[1024][1024])
{
 int i,j,k,l; double t; double temp; int n; double a[1024],b[1024];
 n= 1024;
 
 for (j=0;j<n;j++){
     a[j]=c[0][j];
     b[j]=c[1][j];
 }
 
 for (i=n-1;i>=0;i--)
 {
  t=b[0];
  for (k=0;k<=n-2;k++) {b[k]=b[k+1];}
  b[n-1]=t;
  temp=0;
  for (l=0;l<n;l++) {temp = temp+a[l]*b[l];}
  r[i]=temp;
 }
 
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *c, *r;
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
        
    plhs[0]=mxCreateDoubleMatrix(1,ncols,mxREAL);
    
   /* the point for input and output */
    c=mxGetPr(prhs[0]);
    r=mxGetPr(plhs[0]);
    
    mexcxcorr(r,c);
    
}