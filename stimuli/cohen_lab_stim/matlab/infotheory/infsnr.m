%
%function [I,IS,Rate,F,SNR,SNRS]=infsnr(spetA,spetB,Fs,Fsd,df)
%
%
%       FILE NAME       : INF SNR
%       DESCRIPTION     : Computes the mutual information from two spike train
%			  trials using SNR measurement between trials
%
%       spetA		: Spike Event Times for trial A 
%       spetB		: Spike Event Times for trial B
%	Fs		: Sampling Rate for 'spet'
%	Fsd		: Sampling rate for generating SNR
%	df		: Minimum desired frequency resoultion for coherence
%			  measurement
%
%Returned Variables
%	I		: Mutual Information
%	IS		: Spike Shuffled Mutual Information - Bias Removal
%	Rate		: Spike Rate
%	F		: Frequency Array
%	SNR		: Spike SNR
%	SNRS		: Spike Shuffled SNR - Bias Removal
%
function [I,IS,Rate,F,SNR,SNRS]=infsnr(spetA,spetB,Fs,Fsd,df)

%Computing Auto and Cross Spectral Density
[F,Pab,Pxyc,Pxyp,K,Stdx,Stdy]=csdspike(spetA,spetB,Fs,Fsd,df,0.01,0.5,'n','y');
[F,Paa,Cxxc,Cxxp,K,Vara]=psdspike(spetA,Fs,Fsd,df,0.01,0.5,'n');
[F,Pbb,Cxxc,Cxxp,K,Varb]=psdspike(spetB,Fs,Fsd,df,0.01,0.5,'n');

%Computing Spike Shuffled Cross Spectral Density
[F,PabS,Pxyc,Pxyp,K,Stdx,Stdy]=csdspike(shiftspet(spetA,Fs,max(spetA)/Fs/4),spetB,Fs,Fsd,df,0.01,0.5,'n','y');

%Computing Singal-to-Noise Ratio
Pab=abs(Pab);
PabS=abs(PabS);
Pxx=(abs(Paa)+abs(Pbb))/2;
%Pxx=sqrt(abs(Paa).*abs(Pbb));	%This option is identical to coherence
SNR=Pab./(Pxx-Pab);
SNRS=PabS./(Pxx-Pab);

%Mutual Information Calculation for Original and Shifted Data
%Note that 1/2 is not needed because we are integrating from 0 to Fs/2 
dF=mean(diff(F));
I=sum(log2(1+SNR))*dF;
IS=sum(log2(1+SNRS))*dF;

%Firing Rate 
Rate=(length(spetA)/max(spetA)*Fs+length(spetB)/max(spetB)*Fs)/2;
