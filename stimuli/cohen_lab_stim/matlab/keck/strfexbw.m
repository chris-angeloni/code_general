%function [] = strfexbw(taxis,faxis,STRF,Level)
%
%	FILE NAME	: STRF EX BW
%	DESCRIPTION	: Finds the excitatory Bandwidth,
%			  Peak Frequency, and Peak Delay
%			  at a desired threshold Level
%
%	taxis		: STRF Time axis
%	faxis		: STRF Frequency Axis
%	STRF		: Receptive field
%	Level		: Threshold Level (Default==1/exp(1))
%
%RETURNED VALUES
%	PeakFreq	: Peak Frequency
%	PeakDelay	: Peak Delay
%	BWs		: Spectral Bandwidth 
%	BWt		: Temporal Bandwidth
%
function [PeakFreq,PeakDelay,BWs,BWt]=strfexbw(taxis,faxis,STRF,Level)

%Input Argument Check
if nargin<4
	Level=1/exp(1);   
end

%Finding the Excitatory Peak Location of the STRF
Max=max(max(STRF));
[i, j]=find(STRF==Max);

%Excitatory Spectral Receptive Field Crossection
SRFPeak=STRF(:,j);
m=find(SRFPeak/Max<Level);
SRFPeak(m)=zeros(size(m));

%Excitatory Temporal Receptive Field Crossection
TRFPeak=STRF(i,:);
n=find(TRFPeak/Max<Level);
TRFPeak(n)=zeros(size(n));

%Spectral BandWidth
k=i;
while SRFPeak(k)/Max>Level
	k=k+1;
end
k2=k;
k=i;
while SRFPeak(k)/Max>Level
	k=k-1;
end
k1=k;
BWs=log2(faxis(k2))-log2(faxis(k1));

%Temporal BandWidth
l=j;
while TRFPeak(l)/Max>Level
	l=l+1;
end
l2=l;
l=j;
while TRFPeak(l)/Max>Level
	l=l-1;
end
l1=l;
BWt=taxis(l2)-taxis(l1);
