%
%function [dT,dF,dT3dB,dF3dB]=finddtdfw(W,Fs,N)
%
%	
%	FILE NAME 	: FIND DT DF W
%	DESCRIPTION 	: Finds the spectro-temporal resolution of a Window
%			  Works for window functions only
%			  Will not work for a filter function!!!
%			  For a filter function use finddtdfh
%
%	W		: Window Function
%	Fs		: Sampling Rate
%	N		: FFT length for calculating Spectral Resolution 
%			  Optional !!! N=1024*16=='Default'
%
%RETURNED VALUES
%	dT		: Temporal Resolution
%	dF		: Frequency Resolution
%	dT3dB		: Temporal 3dB Width
%	dF3dB		: 3dB BandWidth
%
%	Note: By the uncertainty principle  dt*dw > 1/2 or dt*df>1/4/pi
%		dt = std(W(t))
%		dw = std(W(w)) or df=std(W(f))
%
%	This is the Chui deffinition but I will use slightly different
%	definition.  Instead I use:
%		dt = 2 * std(W(t))
%		df = 2 * std(W(f))
%
%	under these conditions the uncertainty principle becomes:
%
%		dt * df > 1/pi
%
% (C) Monty Escabi, Edit 11/14
%
function [dT,dF,dT3dB,dF3dB]=finddtdfw(W,Fs,N)

%Input Arguments
if nargin==2
	N=1024*16;
end
Ts=1/Fs;

%Finding Temporal Resolution - Performed by Normalized Window 
%Method used in Leon Cohen Book and in Charles Chui
WN=W./sqrt(sum(W.^2)*Ts);
M=length(W);
taxis=(1:M)*Ts;
meanT=sum(taxis.*WN.^2)*Ts;
dT=2 * sqrt(sum((taxis-meanT).^2.*WN.^2)*Ts); % Window Temporal Width

%Finding 3dB Temporal Resolution
%index=find(W>0.5*max(W));
index=find(W.^2>0.5*max(W.^2));     %Edit 11/14 - correct 3dB point
dT3dB=length(index)*Ts;

%Finding Spectral Resolution
N=max( 2^(ceil(log2(N))) ,  2^(ceil(log2(length(W)))) );
faxis=(-N/2+.5:N/2-.5)/N*Fs;
WW=fftshift(abs(fft(W,N)));
WW=WW./sqrt(sum(WW.^2)*Fs/N);
dF=2 * sqrt( sum( faxis.^2.*WW.^2 )*Fs/N );	%Window Spectral Width 

%Finding 3dB Spectral Resolution
index=find(WW.^2>0.5*max(WW.^2));   %Edit 11/14
dF3dB=length(index)*Fs/N;


