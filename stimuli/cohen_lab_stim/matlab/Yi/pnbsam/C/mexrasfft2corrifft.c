#include "mex.h"

void mexrasfft2corrifft(double corrifft_r[499500][40], double corrifft_i[499500][40], double rasfft_r[1000][40], double rasfft_i[1000][40])
{
int k,l,j;
int i=0;
//rasifft_r = (double*)malloc(ntrial*(ntrial-1)/2*nsample*sizeof(double) );
//rasifft_i = (double*)malloc(ntrial*(ntrial-1)/2*nsample*sizeof(double) );
for (k=1;k<ntrial;k++){
    for (l=0;l<k-1;l++){
        for (j=0;j<nsample;j++){
        //*(rasifft_r+i*nsample+j) = (*(rasfft_r+k*nsample+j))*(*(rasfft_r+l*nsample+j))+(*(rasfft_i+k*nsample+j))*(*(rasfft_i+l*nsample+j));
        //*(rasifft_i+i*nsample+j) = (*(rasfft_r+k*nsample+j))*(0-(*(rasfft_i+l*nsample+j)))+(*(rasfft_i+k*nsample+j))*(*(rasfft_r+l*nsample+j));
       rasifft_r[i][j] = rasfft_r[k][j]*rasfft_r[l][j]+rasfft_i[k][j]*rasfft_i[l][j];
       rasifft_i[i][j] = rasfft_r[k][j]*(0-rasfft_i[l][j])+rasfft_i[k][j]*rasfft_r[l][j];
        }
        i++;
}
}
//free(rasifft_r);
//free(rasifft_i);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *rasifft_r, *rasifft_i, *rasfft_r, *rasfft_i;
    unsigned long ntrial, nsample;
    int mrows, ncols;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    rasfft_r = mxGetPr(prhs[0]);
    rasfft_i = mxGetPr(prhs[1]);
    ntrial = mxGetScalar(prhs[2]);
    nsample = mxGetScalar(prhs[3]);
    plhs[0] = mxCreateDoubleMatrix(1,ntrial*(ntrial-1)/2,mxREAL);
    rasifft_r = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(1,ntrial*(ntrial-1)/2,mxREAL);
    rasifft_i = mxGetPr(plhs[1]);
    
    mexrasfft2corrifft(rasifft_r,rasifft_i,rasfft_r,rasfft_i,ntrial,nsample);
}
