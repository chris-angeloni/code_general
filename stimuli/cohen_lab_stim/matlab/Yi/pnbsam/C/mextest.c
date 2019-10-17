
#include "mex.h"
#include "malloc.h"
#include "stdlib.h"

void mextest(double rcir[], double data1[], double data2[], unsigned long nn)
{
    void mexfouri();
    unsigned long i;
    double *fft1, *fft2, *fftr;
    
    data1 = (double*)malloc(2*nn*sizeof(double) );
    data2 = (double*)malloc(2*nn*sizeof(double) );
    // rcir = (double*)malloc(2*nn*sizeof(double) );
    fft1 = (double*)malloc(2*nn*sizeof(double) );
    fft2 = (double*)malloc(2*nn*sizeof(double) );
    fftr = (double*)malloc(2*nn*sizeof(double) );
    mexfouri(fft1,data1,nn,1);
    mexfouri(fft2,data2,nn,1);
    free(data1);
    free(data2);
    /* temp = fft(data1).*conj(fft(data2)) */
    for (i=0; i<2*nn; i++) {
       *(fftr+i)=(*(fft1+i))*(*(fft2+i))+(*(fft1+i+1))*(*(fft2+i+1)); 
       *(fftr+i+1)=(*(fft1+i))*(0-*(fft2+i+1))+(*(fft1+i+1))*(*(fft2+i));
    }
    free(fft1);
    free(fft2);
    mexfouri(rcir,fftr,nn,-1);
    free(fftr);
    // free(rcir);
}

#include <math.h>
#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr
void mexfouri(double dataout[], double data[], unsigned long nn, int isign)
{
	unsigned long n,mmax,m,j,istep,i,k;
	double wtemp,wr,wpr,wpi,wi,theta;
	float tempr,tempi;

	n=nn << 1;
	j=1;
    
    for (k=0;k<nn;k++){
    dataout[k]=data[k];}
    
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
				tempr=wr*data[j]-wi*data[j+1];  /* Danielson-Lanczos formula */
				tempi=wr*data[j+1]+wi*data[j];
				dataout[j]=data[i]-tempr;
				dataout[j+1]=data[i+1]-tempi;
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

/* void mexxcorrcir(double rcir[], double data1[], double data2[], unsigned long nn) */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *rcir, *data1, *data2; 
    unsigned long nn;
    int mrows, ncols;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    data1 = mxGetPr(prhs[0]);
    data2 = mxGetPr(prhs[1]);
    nn = mxGetScalar(prhs[2]);
    plhs[0] = mxCreateDoubleMatrix(mrows,ncols,mxREAL);
    rcir = mxGetPr(plhs[0]);
    
    mextest(rcir,data1,data2,nn);
}
