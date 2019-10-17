/* rascxcorr.c*/
/* (c) Yi Zheng, July 2007 */

# include "mex.h"
# include "engine.h"

# include <stdlib.h>
# include "matrix.h"

# include <stdio.h>
# include <string.h>

void mexrascxcorr(double *rmatrix, double *ras, unsigned long ntrial, unsigned long nsample)
{
 Engine *ep;  
 int k,l,j; 
 int i=0;
 double *a, *b, *r=NULL;
 // mxArray *A =NULL, *B=NULL, *R=NULL;
 ras = (double*)malloc(ntrial*nsample*sizeof(double) );
 rmatrix = (double*)malloc(ntrial*(ntrial-1)/2*nsample*sizeof(double) );
 
for(k=1;k<ntrial;k++){
    /* printf("Computing cross-channel correlation for channel: %d\n",k); */
    for(l=0;l<=k-1;l++){
        for(j=0;j<nsample;j++){
        *(a+j)=*(ras+k*nsample+j);
        *(b+j)=*(ras+l*nsample+j);
        }
        r = (double*)malloc(nsample*sizeof(double) ); 
        mexcxcorr(r,a,b);
     for (j=0;j<nsample;j++){
     *(rmatrix+i*nsample+j)=*(r+j);}
        free(r);
  
     i++;
	}
}
 free(ras);
 free(rmatrix);
     /* 
      ep=engOpen("/opt/MATLAB74/bin/MATLAB"); 
    
     A = (double*)mxCalloc(nsample, sizeof(double) );
     B = (double*)mxCalloc(nsample, sizeof(double) );  
     A = mxCreateDoubleMatrix(1,nsample,mxREAL);
     B = mxCreateDoubleMatrix(1,nsample,mxREAL);
     memcpy((void *)mxGetPr(A), (void *)a, sizeof(a));
     memcpy((void *)mxGetPr(B), (void *)b, sizeof(b));
     
     engPutVariable(ep, "A", A);
     engPutVariable(ep, "B", B);
     engEvalString(ep,"R=xcorrcircular(A,B);");
     mxDestroyArray(A);
     mxDestroyArray(B);
     mxFree(A);
     mxFree(B); 
     r = engGetVariable(ep, "R");
     mxDestroyArray(r);
    
     engClose(ep); 
     
     for (j=0;j<nsample;j++){
     *(rmatrix+i*nsample+j)=*(r+j);}
     i++;
    }
 free(r);
 free(ras);
 */
}

void mexcxcorr(double r[40],double a[40],double b[40])
{
 int i,k,l; double t; double temp; int n;
 n= 40;
 
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


/* mexFunction is the gateway routine for MEX-files. */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    double *ras,*rmatrix;
    int mrows, ncols;
    unsigned long ntrial, nsample;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    ras = (double*)mxCalloc(ntrial*nsample, sizeof(double) ); 
    rmatrix = (double*)mxCalloc(ntrial*(ntrial-1)/2*nsample, sizeof(double) ); 
    
    ras = mxGetPr(prhs[0]);
    ntrial = mxGetScalar(prhs[1]);
    nsample = mxGetScalar(prhs[2]);
    plhs[0] = mxCreateDoubleMatrix(mrows*(mrows-1)/2 ,ncols,mxREAL);
    rmatrix = mxGetPr(plhs[0]);
    
    mexrascxcorr(rmatrix,ras,ntrial,nsample);
    
    mxFree(ras);
    mxFree(rmatrix);
}











