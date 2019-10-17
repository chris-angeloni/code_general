%
%function [dT,dF,dT3dB,dF3dB]=finddtdfh(H,Fs,N)
%
%	
%	FILE NAME 	: FIND DT DF H
%	DESCRIPTION 	: Finds the spectro-temporal resolution of a 
%			  Band Pass Filter
%
%	H		: Filter Impulse Response
%	Fs		: Sampling Rate
%	N		: FFT length for calculating Spectral Resolution 
%			  Optional !!! N=1024*16=='Default'
%
%RETURNED VALUES
%	dT		: Temporal Resolution  - Uncertainty Principle
%	dF		: Frequency Resolution - Uncertainty Principle
%	dT3dB		: Temporal Resolution  (width) - 3dB Points
%	dF3dB		: Frequency Resolution (width) - 3dB Points
%	
%	Note: By the uncertainty principle  dt*dw > 1/2 or dt*df>1/4/pi
%		dt = std(H(t))
%		dw = std(H(w)) or df=std(H(f))
%
%	This is the Chui deffinition but I will use slightly different
%	definition.  Instead I use:
%		dt = 2 * std(H(t))
%		df = 2 * std(H(f))
%
%	under these conditions the uncertainty principle becomes:
%
%		dt * df > 1/pi
%
function [dT,dF,dT3dB,dF3dB]=finddtdfw(H,Fs,N)

%Input Arguments
if nargin==2
	N=1024*16;
end
Ts=1/Fs;

%Finding Temporal Resolution - Performed by Normalized Window 
%Method used in Leon Cohen Book and in Charles Chui
HN=H./sqrt(sum(H.^2)*Ts);
M=length(H);
taxis=(1:M)*Ts;
meanT=sum(taxis.*HN.^2)*Ts;
dT=2 * sqrt(sum((taxis-meanT).^2.*HN.^2)*Ts); % Filter Temporal Width

%Spectral Resolution - Uncertainty Principle
N=max( 2^(ceil(log2(N))) ,  2^(ceil(log2(length(H)))) );
faxis=(0:N-1)/N*Fs;
HH=abs(fft(H,N));
if HH(1)>0.05*max(HH)
	HH=fftshift(HH);		%Low Pass Filter
else
	HH(N/2+1:N)=zeros(1,N/2);	%Band Pass Filter
end
HH=HH./sqrt(sum(HH.^2)*Fs/N);
HH=HH./sqrt(sum(HH.^2));
MeanF=sum(faxis.*HH.^2);
dF=2 * sqrt( sum( (faxis-MeanF).^2.*HH.^2 ) ); % Filter Spectral Width 

%Finding 3dB Spectral Resolution - Obtained by using standard definition of 
%bandwidth dF=f2-f1
index=find(HH.^2>.499*max(HH.^2));  %Edit 11/14
f1=faxis(index(1));
f2=faxis(max(index));
dF3dB=f2-f1;

%Finding Temporal Filter 3dB Width
%This Follows Directly From the Fact that dt*df<1
%Ref: Multi Rate Systems and Filter Banks, P.P. Vaidyanathan, Pg. 481
%dT3dB=1/dF3dB;
index=find(H.^2>0.5*max(H.^2));     %Edit 11/14 - correct 3dB point
dT3dB=length(index)*Ts;

