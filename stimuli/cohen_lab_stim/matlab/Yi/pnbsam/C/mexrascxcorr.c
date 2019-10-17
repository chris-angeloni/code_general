/* rascxcorr.c*/
#include "mex.h"
// # include <malloc.h> 
void mexrascxcorr(double rmatrix[499500][40], double ras[1000][40], int ntrial)
{
 void mexcxcorr();
 
 /* double * c; double * r; */
 int nsample = 40;   /* # of sample points per trial */
 int k,l,j; 
 int i=0; double temp;
 double a[40], b[40], r[40];
 /* c = (double*)malloc(2*nsample*sizeof(double) );
 r = (double*)malloc(1*nsample*sizeof(double) ); */
 
 /* ras = (double*)malloc(ntrial*nsample*sizeof(double) ); 
 rmatrix = (double*)malloc(ntrial*(ntrial-1)/2*nsample*sizeof(double) ); */
 
for(k=1;k<ntrial;k++){
    printf("Computing cross-channel correlation for channel: %d\n",k);
    for(l=0;l<=k-1;l++){
        for(j=0;j<nsample;j++){
        a[j]=ras[k][j];
        b[j]=*(*(ras+l)+j);
        }
     mexcxcorr(r,a,b);
     for (j=0;j<nsample;j++){
     rmatrix[i][j]=r[j];}
  
     i++;
    }
}
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

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *ras,*rmatrix;
    int mrows, ncols, ntrial;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    ras = mxGetPr(prhs[0]);
    ntrial = mxGetScalar(prhs[1]);
    plhs[0] = mxCreateDoubleMatrix(mrows*(mrows-1)/2 ,ncols,mxREAL);
    rmatrix = mxGetPr(plhs[0]);
    
    mexrascxcorr(rmatrix,ras,ntrial);
}











