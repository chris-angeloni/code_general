/* Replaces data[1..2*nn] by its discrete Fourier transform, if isign is input as 1; or replaces
data[1..2*nn] by nn times its inverse discrete Fourier transform, if isign is input as -1. */

#include <math.h>
#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

void mexfouri(double dataout[], double data[], unsigned long nn, int isign)
{
	unsigned long n,mmax,m,j,istep,i,k;
	double wtemp,wr,wpr,wpi,wi,theta;
	float tempr,tempi;
    
    for (k=0;k<nn*2;k++){
    dataout[k]=data[k];}
    
   n=nn << 1;
	j=1;
	for (i=1;i<n;i+=2) {
		if (j > i) {
			SWAP(dataout[j],dataout[i]);
			SWAP(dataout[j+1],dataout[i+1]);
		}
		m=n >> 1;
		while (m >= 2 && j > m) {
			j -= m;
			m >>= 1;
		}
		j += m;
	}
	mmax=2;
	while (n > mmax) {
		istep=mmax << 1;
		theta=isign*(6.28318530717959/mmax);
		wtemp=sin(0.5*theta);
		wpr = -2.0*wtemp*wtemp;
		wpi=sin(theta);
		wr=1.0;
		wi=0.0;
		for (m=1;m<mmax;m+=2) {
			for (i=m;i<=n;i+=istep) {
				j=i+mmax;
				tempr=wr*dataout[j]-wi*dataout[j+1];
				tempi=wr*dataout[j+1]+wi*dataout[j];
				dataout[j]=dataout[i]-tempr;
				dataout[j+1]=dataout[i+1]-tempi;
				dataout[i] += tempr;
				dataout[i+1] += tempi;
			}
			wr=(wtemp=wr)*wpr-wi*wpi+wr;
			wi=wi*wpr+wtemp*wpi+wi;
		}
		mmax=istep;
	}
}
#undef SWAP


/* void four1(float data[], unsigned long nn, int isign) */
#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *dataout, *data; 
    unsigned long nn;
    int isign;
    int mrows, ncols;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    data = mxGetPr(prhs[0]);
    nn = mxGetScalar(prhs[1]);
    isign = mxGetScalar(prhs[2]);
    plhs[0] = mxCreateDoubleMatrix(mrows,2*nn,mxREAL);
    dataout = mxGetPr(plhs[0]);
    
    mexfouri(dataout,data,nn,isign);
}
