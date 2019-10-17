%
%function [dT,dF]=finddtdfatt(W,Fs,N)
%
%	
%	FILE NAME 	: FIND DT DF ATT
%	DESCRIPTION 	: Finds the spectro-temporal resolution of a Window
%			  at a specified ATT
%
%	W		: Window Function
%	Fs		: Sampling Rate
%	N		: FFT length for calculating Spectral Resolution 
%			  Optional !!! N=1024*16=='Default'
%	dT		: Temporal Resolution
%	dF		: Frequency Resolution
%	
function [dT,dF]=finddtdfatt(W,Fs,ATT,N)

%Input Arguments
if nargin<4
	N=1024*16;
end
Ts=1/Fs;

%Finding Temporal Resolution - points where ATT is reached
W=W/max(W);
WdB=20*log10(W);
index=find(WdB>-ATT);
dT=(max(index)-min(index))/Fs;

%Finding Spectral Resolution
N=max( 2^(ceil(log2(N))) ,  2^(ceil(log2(length(W)))) );
faxis=(-N/2+.5:N/2-.5)/N*Fs;
WW=fftshift(abs(fft(W,N)));
%WW(N/2+1:N)=zeros(1,N/2);
WW=WW/max(WW);
WWdB=20*log10(WW);
index=find(WWdB>-ATT);
dF=faxis(max(index))-faxis(min(index));

