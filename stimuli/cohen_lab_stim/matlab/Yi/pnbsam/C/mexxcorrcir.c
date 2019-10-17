/* Circular correlation using FFT */
/* (c) Yi Zheng, July 2007 */

void mexxcorrcir(double rcir[], double data1[], double data2[], unsigned long nn)
{
    void mexfouri(double dataout[], double data[], unsigned long nn, int isign);
    double *fft1, *fft2, *temp;
    unsigned long i;
    
    
    mexfouri(fft1,data1,nn,1);  /* fft1=fft(data1) */
    mexfouri(fft2,data2,nn,1);  /* fft2=fft(data2) */
    
    /* temp = fft(data1).*conj(fft(data2)) */
    for (i=0; i<2*nn; i+=2) {
       *(temp+i)=(*(fft1+i))*(*(fft2+i)) + (*(fft1+i+1))*(*(fft2+i+1));
       *(temp+i+1)=(*(fft1+i+1))*(*(fft2+i)) - (*(fft1+i))*(*(fft2+i+1));
    }
   mexfouri(rcir, temp, nn, -1); 
    
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
    
    for (k=0;k<=n;k++){
    dataout[k]=data[k];}
    
	for (i=1;i<n;i+=2) {
		if (j > i) {
			SWAP(data[j],data[i]);
			SWAP(data[j+1],data[i+1]);
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
#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *rcir, *data1, *data2; 
    unsigned long nn;
    int isign;
    int mrows, ncols;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    data1 = mxGetPr(prhs[0]);
    data2 = mxGetPr(prhs[1]);
    nn = mxGetScalar(prhs[2]);
    plhs[0] = mxCreateDoubleMatrix(mrows,2*nn,mxREAL);
    rcir = mxGetPr(plhs[0]);
    
    mexxcorrcir(rcir,data1,data2,nn);
}
