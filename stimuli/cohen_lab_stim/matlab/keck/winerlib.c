#include        <stdio.h>
#include	<stdlib.h>
#include	<math.h>
#include        <string.h>
#include	<malloc.h>
#include	"winerlib.h"
#include 	"tools.h"

/******************************************************************
 *                                                                *
 *FUNCTION NAME: MAIN                                             *
 *                                                                *
 ******************************************************************/
void main(int argc,char *argv[])
{
FILE	*rfp,*wfp;			/*Input and Output file pointers*/
char	infile[100],outfile[100];	/*Input and Output file names*/
int	K;				/*Winer Kernel order*/
float	twin;				/*Time Window for kernel*/
int 	nspikes;			/*Number of spikes for calculation*/
WK1 	wk;
WK2	wkk;

/*Usage Information*/
if (argc < 6) 
	{
	printf("\n\n\nusage: %s infile outfile type twin nspikes order\n\n", argv[0]);
	printf("   infile	: Input file name\n");
	printf("   outfile	: Output file name\n");
	printf("   type 	: Output file type: A for ASCII, B for BIN\n");
	printf("   twin		: Time Window for Winer Kernel\n");
	printf("   nspikes	: Number of spikes for kernel calculation(a for all)\n");
	printf("   order	: Winer kernel order  (>=0)\n");
	exit(0);
	}

/*Opening Input and Output Files*/
rfp=OpenInfile(argv[1],"rb");
wfp=OpenOutfile(argv[2],"wt");

/*Winer Kernel Window*/
twin=(float)atof(argv[4]);

/*Number of spikes for calculation*/
if (strcmp("a",argv[5])==0)
	nspikes=-1;
else
	nspikes=atoi(argv[5]);
 
/*Winer Kernel Order*/
K=atoi(argv[6]);

switch(K)
{
case 1:
wk=winer1(rfp,twin,nspikes);
print_wk1(wfp,wk);
break;

case 2:
wkk=winer2(rfp,twin,nspikes);
print_wk2(wfp,wkk);
break;

default:
wk=winer1(rfp,twin,nspikes);
print_wk1(wfp,wk);
}

fclose(rfp);
fclose(wfp);
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: READ DATA BLOCK                                  *
 *DESCRIPTION  : Reads input data Block of size M.                *
 *               Stores data into ARRAYf structure.               *
 *                                                                *
 ******************************************************************/
ARRAYf read_data_block(FILE *rfp,int M)
{
ARRAYf A;

/*Reading data from rfp*/
A=init_ARRAYf(M);
fread(A->data,sizeof(float),M,rfp);

return A;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: WINER1                                           *
 *DESCRIPTION  : First order winer kernel.	                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
WK1 winer1(FILE *rfp,float twin,int nspikes)
{
WK1 wk;
HEADER H;
int i;

/*Reading Header info and rewinding*/
H=read_header(rfp,H);
rewind(rfp);

/*Allocating Memory*/
wk=(WK1)calloc(1,sizeof(struct wk1));
wk->taxis=(float *)calloc(ceil(twin*H->Fs),sizeof(float));
wk->array=init_ARRAYf(1);

/*Finding Discrete Window Size:  wk->N*/
wk->array->N=ceil(twin*H->Fs);

/*Finding 1st order Winer Kernel*/
wk->array=revcorr(rfp,twin,nspikes);

/*Finding time axis*/
for(i=0;i<wk->array->N;i++)
	wk->taxis[i]=i*1/H->Fs;

return wk;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: REVCORR                                          *
 *DESCRIPTION  : Reverse Correlation. 		                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf revcorr(FILE *rfp,float twin,int nspikes)
{
int i=0,count=0;
int k,l,M,WN;
ARRAYf rvcor;			/*Reverse Correlation Array*/
HEADER H;			/*Header*/
ARRAYf inbuff;			/*Input Buffer*/
float A=0;			/*Noise level*/
int countA=0; 			/*Samples used to calculate Noise level*/

/*Reading Header info*/
H=read_header(rfp,H);

/*Number of spikes for calculation*/
if(nspikes==-1)
	nspikes=32000;

/*Finding Discrete Window Size -> WN*/
WN=ceil(twin*H->Fs);

/*Allocating Revcorr Array*/
rvcor=init_ARRAYf(WN);

/*Calculating revcorr*/
while(i*GIG<H->M && count < nspikes)
	{
	/*Reading input into blocks of size M*/
	if(H->M-i*GIG > GIG)
		M=GIG;
	else
		M=H->M-i*GIG;

	inbuff=read_data_block(rfp,M);

	/*Finding Revcorr For ith Block*/	
	for(k=WN+1;k<M && count < nspikes;k++)
		{
		/*Calculating Noise level*/
		if(inbuff->data[k]!=SPIKE)
			{
			A=A+pow(inbuff->data[k],2);
			countA=countA+1;
			}

		if(inbuff->data[k]==SPIKE)
			{
			count=count+1;
			fprintf(stderr,"Fs = %.2f\t Spikes = %u\r",H->Fs,
			count);

			for(l=0;l<WN;l++)
			if(inbuff->data[k-l-1]!=SPIKE)
			rvcor->data[l]=rvcor->data[l]+inbuff->data[k-l-1];
			}	
		}

	i=i+1;
	}
fprintf(stderr,"\n");

/*Noise Level*/
A=sqrt(A/countA);

/*Number of Spikes used*/
nspikes=count;

/*Normalizing and removing DC*/
rvcor=norm_dc_rv1(rvcor,nspikes,A);

/*Rewinding rfp*/
rewind(rfp);

return rvcor; 
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: WINER2                                           *
 *DESCRIPTION  : Second order winer kernel.	                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
WK2 winer2(FILE *rfp,float twin,int nspikes)
{
ARRAYf rvcor2;
ARRAYf Xcor2;
WK2 wk;
int i,k,WN;
HEADER H;

/*Reading Header info*/
H=read_header(rfp,H);

/*Discrete window size*/
WN=ceil(twin*H->Fs);

/*Memory Allocation*/
wk=WK2_alloc(WN,WN);

/*Finding Normalized RevCor and XCor*/
rvcor2=revcorr2(rfp,twin,nspikes);
Xcor2 =Xcorr2(rfp,twin,nspikes);

/*Finding 2nd Order Winer Kernel*/
for(i=0;i<WN;i++)
	for(k=0;k<WN;k++)
		wk->data[k+i*WN]=rvcor2->data[k+i*WN]-Xcor2->data[k+i*WN];

/*Time Axis*/
for(i=0;i<WN;i++)
	wk->taxisx[i]=i*1/H->Fs;
for(i=0;i<WN;i++)
        wk->taxisy[i]=i*1/H->Fs;

return wk;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: XCORR2                                           *
 *DESCRIPTION  : 2nd Order Cross Correlation                      *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf Xcorr2(FILE *rfp,float twin,int nspikes)
{
int i,j,k,l,WN;
int N;
ARRAYf Xcor2;                   /*Cross Correlation Array*/
ARRAYf inbuff;                  /*Input Buffer*/
HEADER H;                       /*Header*/
float A=0;                      /*Noise level*/
int countA=0;                   /*Samples used to calculate Noise level*/
ARRAYi spike;
ARRAYf psw;

/*Message*/
fprintf(stderr,"Finding X-Correlation >");

/*Reading Header info*/
H=read_header(rfp,H);

/*Discrete window size*/
WN=ceil(twin*H->Fs);

/*Find Spikes and all windows prior to spike*/
spike=find_spikes(rfp,spike,nspikes);
psw=find_ps_win(rfp,spike,WN);

/*Allocating Xcor2*/
Xcor2=init_ARRAYf(WN*WN);

/*Finding X Correlation*/
for(l=0;l<spike->N;l++)
	for(i=0;i<WN;i++)
		for(j=0;j<WN;j++)
			for(k=0;k<WN;k++)
			if(i-j+k>0 && i-j+k<WN)
Xcor2->data[k+j*WN]=Xcor2->data[k+j*WN]+psw->data[l*WN+i]*psw->data[l*WN+i-(j-k)];	

/*Normalizing and removing any DC*/
Xcor2=norm_dc_xc2(Xcor2,psw,spike,H->Fs,WN);

return Xcor2;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: REVCORR2                                         *
 *DESCRIPTION  : 2nd Order Reverse Correlation                    *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf revcorr2(FILE *rfp,float twin,int nspikes)
{
int i=0,count=0;
int k,l,WN;
long int M;
ARRAYf rvcor2;                  /*Reverse Correlation Array*/
ARRAYi spike;			/*Array with spike locations*/
ARRAYf inbuff;                  /*Input Buffer*/
HEADER H;                       /*Header*/
ARRAYf psw;			/*Pre Spike Window Data*/

/*Reading Header info*/
H=read_header(rfp,H);

/*Discrete window size*/
WN=ceil(twin*H->Fs);

/*Find SPikes and all windows prior to spike*/
spike=find_spikes(rfp,spike,nspikes);
psw=find_ps_win(rfp,spike,WN);

/*Allocating rvcor2*/
rvcor2=init_ARRAYf(WN*WN);

/*Finding Revcorr*/
for(l=0;l<spike->N;l++)
	for(i=0;i<WN;i++)
		for(k=0;k<WN;k++)
rvcor2->data[k+i*WN]=rvcor2->data[k+i*WN]+psw->data[(l+1)*WN-k]*psw->data[(l+1)*WN-i];	

/*Normalizing and removing any DC*/
rvcor2=norm_dc_rv2(rvcor2,psw,spike,H->Fs,WN);

return rvcor2;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: FIND SPIKE                                       *
 *DESCRIPTION  : Finds indexes for spikes.	                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYi find_spikes(FILE *rfp,ARRAYi spike,int nspikes)
{
HEADER H;
int count=0,i=0,k,M;
ARRAYf inbuff;

/*Message*/
fprintf(stderr,"Finding Spikes > \r");

/*Reading header*/
H=read_header(rfp,H);

/*Memory Allocation*/
spike=init_ARRAYi(1);

/*Number of spikes for calculation*/
if(nspikes==-1)
	nspikes=32000;

/*Finding spikes*/
while(i*GIG<H->M && count < nspikes)
	{
	/*Reading input into blocks of size M*/
       	if(H->M-i*GIG > GIG)
               	M=GIG;
       	else
               	M=H->M-i*GIG;

       	inbuff=read_data_block(rfp,M);

	for(k=0;k<M && count < nspikes;k++)
		if(inbuff->data[k]==SPIKE)
			{
			count=count+1;
			spike=re_init_ARRAYi(spike,count+1);
			spike->data[count-1]=i*GIG+k;
			}
	i=i+1;	
	}

spike->N=count;

rewind(rfp);
return spike; 
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: FIND PS WIN                                      *
 *DESCRIPTION  : Finds pre spike windows.	                  *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf find_ps_win(FILE *rfp,ARRAYi spike,int WN)
{
HEADER H;
ARRAYf psw;			/*Pre Spike Windows*/
int k=0,l=0,i;
float ftemp;

/*Message*/
fprintf(stderr,"Finding Pre Spike Data > \r");

/*Reading header*/
H=read_header(rfp,H);

/*Memory Allocation for psw*/
psw=init_ARRAYf(WN*spike->N);

/*Finding psw*/
for(k=0;k<spike->N;k++)
	{	
	fseek(rfp,(spike->data[k]-WN+1)*sizeof(float),0);

	for(i=0;i<WN;i++)
		{
		fread(&ftemp,sizeof(float),1,rfp);
		if(ftemp!=3)		
			psw->data[i+k*WN]=(float)ftemp;
		else
			psw->data[i+k*WN]=(float)0;
		}
	}

rewind(rfp);
return psw;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: NORM DC RV2                                      *
 *DESCRIPTION  : Normalizes and removes DC From RVCORR2           *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf norm_dc_rv2(ARRAYf rvcor2,ARRAYf psw,ARRAYi spike,float Fs,int WN)
{
int l,i,k;
float No=0,A=0;				/*Spike Rate and Noise Level*/

/*Finding Noise level*/
for(l=0;l<psw->N;l++)
        A=A+pow(psw->data[l],2);
A=sqrt(A/psw->N);

/*Finding Spike Rate*/
No=(float)spike->N/spike->data[spike->N-1]*Fs;

/*Normalizing RevCor*/
for(i=0;i<WN;i++)
        for(k=0;k<WN;k++)
        rvcor2->data[k+i*WN]=(float)No/2/A/A/spike->N*rvcor2->data[k+i*WN];


return rvcor2;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: NORM DC XC2                                      *
 *DESCRIPTION  : Normalizes and removes DC From XCORR2            *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf norm_dc_xc2(ARRAYf xcor2,ARRAYf psw,ARRAYi spike,float Fs,int WN)
{
int l,i,k;
float No=0,A=0;                         /*Spike Rate and Noise Level*/

/*Finding Noise level*/
for(l=0;l<psw->N;l++)
        A=A+pow(psw->data[l],2);
A=sqrt(A/psw->N);

/*Finding Spike Rate*/
No=(float)spike->N/spike->data[spike->N-1]*Fs;

/*Normalizing CrossCor*/
for(i=0;i<WN;i++)
        for(k=0;k<WN;k++)
   xcor2->data[k+i*WN]=(float)No/2/A/A/spike->N/WN*xcor2->data[k+i*WN];

return xcor2;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: NORM DC RV1                                      *
 *DESCRIPTION  : Normalizes and removes DC From RVCORR1           *
 *                                                                *
 *                                                                *
 ******************************************************************/
ARRAYf norm_dc_rv1(ARRAYf array,int nspikes,float A)
{
int i;
float dc=0;

for(i=0;i<array->N;i++)
	dc=dc+array->data[i]/array->N;

for(i=0;i<array->N;i++)
	array->data[i]=(array->data[i]-dc)/nspikes/A;

return array;
}


/******************************************************************
 *                                                                *
 *FUNCTION NAME: READ HEADER                                      *
 *DESCRIPTION  : Reads header from input file rfp.		  *
 *								  *
 *                                                                *
 ******************************************************************/
HEADER read_header(FILE *rfp,HEADER H)
{
/*Memory allocation*/
H=(HEADER)calloc(1,sizeof(struct header));

/*Reading header information*/
rewind(rfp);
fread(&H->M,sizeof(long int),1,rfp);
fread(&H->Fs,sizeof(float),1,rfp);

return H;
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: PRINT WK1                                        *
 *DESCRIPTION  : Prints out 1st Order Wiener Kernel Data          *
 *                                                                *
 *                                                                *
 ******************************************************************/
void print_wk1(FILE *wfp,WK1 wk)
{
int i;

for(i=0;i<wk->array->N;i++)
	fprintf(wfp,"%f\t%f\n",wk->taxis[i],wk->array->data[i]);
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: PRINT WK2                                        *
 *DESCRIPTION  : Prints out 2nd Order Wiener Kernel Data          *
 *                                                                *
 *                                                                *
 ******************************************************************/
void print_wk2(FILE *wfp,WK2 wk)
{
int i,k;

for(i=0;i<wk->Ny;i++)
	{
	fprintf(wfp,"%f\t%f\t",wk->taxisx[i],wk->taxisy[i]);

	for(k=0;k<wk->Nx;k++)
        fprintf(wfp,"%f\t",wk->data[k+i*wk->Ny]);

	fprintf(wfp,"\n");
	}
}

/******************************************************************
 *                                                                *
 *FUNCTION NAME: WK2 ALLOC                                        *
 *DESCRIPTION  : Memory Allocation for 2nd Order Winer Kernel     *
 *                                                                *
 *                                                                *
 ******************************************************************/
WK2 WK2_alloc(int Nx,int Ny)
{
WK2 wk;

wk=(WK2)calloc(1,sizeof(struct wk2));
wk->data=(float *)calloc(Nx*Ny,sizeof(float));
wk->taxisx=(float *)calloc(Nx,sizeof(float));
wk->taxisy=(float *)calloc(Ny,sizeof(float));
wk->Nx=Nx;
wk->Ny=Ny;

return wk;
}

