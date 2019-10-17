%
%function [Fm,RD,RTF,RTFVar]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,Display)
%
%       FILE NAME       : STRF 2 RTF
%       DESCRIPTION     : Converts an STRF to a Ripple Transfer Function
%	
%	taxis		: Time Axis
%	faxis		: Frequency Axis
%	STRF		: Spectro Temporal Receptive Field
%	MaxFm		: Maximum Modulation Rate for Experiment
%	MaxRD		: Maximum Ripple Density for Experiment
%	Display		: Display : 'y' or 'n'
%                 Default : 'n'
%   
%RETRNED VARIABLES
%   Fm          : Temporal modulation frequency array
%   RD          : Ripple density array
%   RTF         : Ripple transfer function (Magnitude)
%   RTFVar      : Noise variance estimated from samples outside MaxFm and
%                 MaxRD. RTFVar is a two dimmensional vector containing:
%
%                 RTFVar(1):    RTF Magnitude Noise Variance
%                 RTFVar(2):    RTF Power Noise Variance
%
%   (C) Monty A. Escabi, Edit March 2009
%
function [Fm,RD,RTF,RTFVar]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,Display)

%Checking Input arguments
if nargin<6
	Display='n';
end

%Sampling Rates
FsT=1/(taxis(3)-taxis(2));
FsX=1/log2(faxis(2)/faxis(1));

%Computing Ripple Transfer Function
N1=size(STRF);
N2=2^nextpow2(N1(2))*2;
N1=2^nextpow2(N1(1))*2;
RTF=fft2(STRF,N1,N2);
RTF=fftshift(RTF.*conj(RTF));
RTF=sqrt(RTF);      %Added July 2007, MAE

%Computing Modulation Frequency and RD axis
RD=(-N1/2:N1/2-1)/N1*FsX;
Fm=(-N2/2:N2/2-1)/N2*FsT;

%Finding Noise Variance - Note that the RTF is possitively biased and is
%not zero mean because we took abs(). Therefore mean is not removed when
%estimating noise variance. Computes the noise variance for both the
%magnitude and power RTF.
index1=find(RD>MaxRD & RD<MaxRD+1);
index2=find(Fm>MaxFm & Fm<MaxFm+100);
RTFVar=sum(sum(RTF(index1,index2).^2))/length(index1)/length(index2);
RTFVar=[RTFVar sum(sum(RTF(index1,index2).^4))/length(index1)/length(index2)];

%Discarding Unecessary Data Samples
index1=find(RD<MaxRD & RD>-MaxRD);
index2=find(Fm<MaxFm & Fm>-MaxFm);
RTF=RTF(index1,index2);
RD=RD(index1);
Fm=Fm(index2);

%Displaying Output
if strcmp(Display,'y')
	pcolor(Fm,RD,RTF),shading flat,colormap jet
	axis([-MaxFm MaxFm 0 MaxRD])
end