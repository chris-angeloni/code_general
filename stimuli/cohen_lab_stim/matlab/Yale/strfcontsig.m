%
%function [STRFSigData]=strfcontsig(STRFData,alpha,NB1,NB2)
%
%   FILE NAME   : STRF CONT SIG
%   DESCRIPTION : Finds significant STRF for continuous field potential
%                 response (no spike train). Uses bootstrap shuffled STRF
%                 samples to find a significance threshold at a desired
%                 alpha-value.
%                 
%   STRFData    : Data Structure containing the following elements
%                 .taxis   - Time Axis
%                 .faxis   - Frequency Axis (Hz)
%                 .STRF1A  - STRF for channel 1 on trial A
%                 .STRF2A  - STRF for channel 2 on trial A
%                 .STRF1B  - STRF for channel 1 on trial B
%                 .STRF2B  - STRF for channel 2 on trial B
%                 .STRF1As - Phase Shuffled STRF for channel 1 on trial A
%                 .STRF2As - Phase Shuffled STRF for channel 2 on trial A
%                 .STRF1Bs - Phase Shuffled STRF for channel 1 on trial B
%                 .STRF2Bs - Phase Shuffled STRF for channel 2 on trial B
%                 .SPLN  - Sound Pressure Level per Frequency Band
%   alpha       : Significance level
%   NB1 	: Number of bootstraps for determining significance threshold
%   NB2 	: Number of bootstraps for reliability index
%
%RETURNED VARIABLES
%   STRFSigData : Data structure containng results for significance testing
%		
%		.STRF1s - Significant STRF for channel 1
%		.STRF2s - Significant STRF for channel 2
%		.Tresh1 - Threshold for channel 1
%               .taxis	- Time Axis
%               .faxis	- Frequency Axis (Hz)
%		.Tresh2 - Threshold for channel 2
%		.sigma1 - Standard devation of noise STRF1
%		.sigma2 - Standard devation of niose STRF2
%		.P1     - Amplitude distribution for noise STRF1
%		.P2     - Amplitude distribition for noise STRF2
%		.X      - Amplitude for P1 and P2
%		.R1     - Reliability index for STRF1
%		.R2     - Reliability index for STRF2
%		.R1s	- Reliability index for shuffled STRF1
%		.R2s 	- Reliability index for shuffled STRF2
%
% (C) Monty A. Escabi, Aug 2010
%
function [STRFSigData]=strfcontsig(STRFData,alpha,NB1,NB2)

try
	%Averaging STRF across all bootstrap segments
	STRF1=mean((STRFData.STRF1A+STRFData.STRF1B)/2,3);
	STRF2=mean((STRFData.STRF2A+STRFData.STRF2B)/2,3);

	%Combining Bootstrap samples from trial A and B into single STRF
	STRF1AB=cat(3,STRFData.STRF1A,STRFData.STRF1B);
	STRF2AB=cat(3,STRFData.STRF2A,STRFData.STRF2B);
	STRF1ABs=cat(3,STRFData.STRF1As,STRFData.STRF1Bs);
	STRF2ABs=cat(3,STRFData.STRF2As,STRFData.STRF2Bs);
catch
	%Averaging STRF across all bootstrap segments
	STRF1=mean(STRFData.STRF1A,3);
	STRF2=mean(STRFData.STRF2A,3);

	%Combining Bootstrap samples from trial A and B into single STRF
	STRF1AB=[STRFData.STRF1A];
	STRF2AB=[STRFData.STRF2A];
	STRF1ABs=[STRFData.STRF1As];
	STRF2ABs=[STRFData.STRF2As];
end

%Reshaping the Shuffled STRF Data and resampling
X1s=[];
X2s=[];
for k=1:NB1
	N=size(STRF1ABs,3);
	index1=randsample([1:N],N,1);
	index2=randsample([1:N],N,1);
	STRF1s=mean(STRF1ABs(:,:,index1),3);
	STRF2s=mean(STRF2ABs(:,:,index2),3);
	X1s=[X1s reshape(STRF1s,1,numel(STRF1s))];
	X2s=[reshape(STRF2s,1,numel(STRF2s))];
end

%Generating Amplitude Distributions
Max=max(abs([X1s X2s]));
X=(-5000:5000)/5000*Max;
[P1,X]=hist(X1s,X);
[P2,X]=hist(X2s,X);

%Finding Standard Deviation 
sigma1=std(X1s);
sigma2=std(X2s);

%Finding the STD Threshold required to exceed a Right Tail 
%Probability of alpha, assuming normal distribution
Tresh1=sigma1*sqrt(2)*erfinv(1-2*alpha);
Tresh2=sigma2*sqrt(2)*erfinv(1-2*alpha);

%Finding Significant STRF
STRF1s=zeros(size(STRF1s));
[i]=find(abs(STRF1)>Tresh1);
STRF1s(i)=STRF1(i);
STRF2s=zeros(size(STRF2s));
[i]=find(abs(STRF2)>Tresh2);
STRF2s(i)=STRF2(i);

%Finding Reliability Index
for k=1:NB2
       	%Finding Bootstrap samples - for half the data without replacement
	N=size(STRF1ABs,3);
	n=randperm(N);
	L=floor(N/2);
        index1=n(1:L);
        index2=n(L+1:2*L);

	%Mean STRFs for two bootstrap sets (a and b)
	STRF1a=mean(STRF1AB(:,:,index1),3);
	STRF1b=mean(STRF1AB(:,:,index2),3);
	STRF2a=mean(STRF2AB(:,:,index1),3);
	STRF2b=mean(STRF2AB(:,:,index2),3);
	STRF1as=mean(STRF1ABs(:,:,index1),3);
	STRF1bs=mean(STRF1ABs(:,:,index2),3);
	STRF2as=mean(STRF2ABs(:,:,index1),3);
	STRF2bs=mean(STRF2ABs(:,:,index2),3);

	%Significance Bootstraped STRF
	index1a=find(abs(STRF1a)<Tresh1*sqrt(2));
	index1b=find(abs(STRF1b)<Tresh1*sqrt(2));
	index2a=find(abs(STRF2a)<Tresh2*sqrt(2));
	index2b=find(abs(STRF2b)<Tresh2*sqrt(2));
	STRF1a(index1a)=zeros(size(index1a));
	STRF1b(index1b)=zeros(size(index1b));
	STRF2a(index2a)=zeros(size(index2a));
	STRF2b(index2b)=zeros(size(index2b));

	%Significance Bootstraped shuffled STRF
	index1a=find(abs(STRF1as)<Tresh1*sqrt(2));
	index1b=find(abs(STRF1bs)<Tresh1*sqrt(2));
	index2a=find(abs(STRF2as)<Tresh2*sqrt(2));
	index2b=find(abs(STRF2bs)<Tresh2*sqrt(2));
	STRF1as(index1a)=zeros(size(index1a));
	STRF1bs(index1b)=zeros(size(index1b));
	STRF2as(index2a)=zeros(size(index2a));
	STRF2bs(index2b)=zeros(size(index2b));

	%Reliability Index
	r1=corrcoef(STRF1a,STRF1b);
	r2=corrcoef(STRF2a,STRF2b);
	r1s=corrcoef(STRF1as,STRF1bs);
	r2s=corrcoef(STRF2as,STRF2bs);
	R1(k)=r1(1,2);
	R2(k)=r2(1,2);
	R1s(k)=r1s(1,2);
	R2s(k)=r2s(1,2);
end

%Adding Data to Structure
STRFSigData.STRF1s=STRF1s;
STRFSigData.STRF2s=STRF2s;
STRFSigData.taxis=STRFData.taxis;
STRFSigData.faxis=STRFData.faxis;
STRFSigData.Tresh1=Tresh1;
STRFSigData.Tresh2=Tresh2;
STRFSigData.sigma1=sigma1;
STRFSigData.sigma2=sigma2;
STRFSigData.P1=P1;
STRFSigData.P2=P2;
STRFSigData.X=X;
STRFSigData.R1=R1;
STRFSigData.R2=R2;
STRFSigData.R2s=R2s;
STRFSigData.R1s=R1s;
