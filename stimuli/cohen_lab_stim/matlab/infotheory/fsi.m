%
%function [FSI1,FSI2,FSI3]=fsi(p,pr)
%
%	FILE NAME       : Feature Selectivity Index
%	DESCRIPTION     : Evaluates the feature Selectivity index
%			  using the strfvar data derived from 
%			  dBVar and LinVar Analysis
%
%	p		: Array of correlation coefficients 
%	pr		: Array of correlation coefficients for 
%			  random spikes
%
%RETURNED VALUE
%	FSI1		: Feature selectivity index - derived from CDF
%	FSI2		: Feature selectivity index - derived from mean
%	FSI3		: Feature selectivity index - derived from median
%
function [FSI1,FSI2,FSI3]=fsi(p,pr)

%Generating Cummulative Distribution Function
[N,X]=hist(p,-3:.0626:1);
N=N/sum(N);
[Nr,Xr]=hist(pr,-3:.0626:1);
Nr=Nr/sum(Nr);
CDF=(intfft(N)-min(intfft(N)))/ (max(intfft(N))-min(intfft(N)));
CDFr=(intfft(Nr)-min(intfft(Nr)))/ (max(intfft(Nr))-min(intfft(Nr)));

%Generating Cummulative Distribution Function - Ideal Feature Detector 
CDFi=zeros(1,64);
CDFi(64)=1;

%Feature Selectivity Index
FSI1=sum(CDFr-CDF)/sum(CDFr-CDFi);
FSI2=(mean(p)-mean(pr))/(1-mean(pr));
FSI3=(median(p)-median(pr))/(1-median(pr));
