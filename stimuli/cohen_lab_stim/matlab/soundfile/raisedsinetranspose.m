%
%function [X,Xm] = raisedsinetranspose(fm,fc,flow,beta,alpha,B,Fs,M)
%	
%	FILE NAME       : RAISED SINE TRANSPOSE
%	DESCRIPTION 	: Generates a raised-sine transpose signal.
%
%   fm              : Modulation Frequency (Hz)
%   fc              : Carrier frequency (Hz). If a two element vector is
%                     specified then fc=[f1 f2] where f1 and f2 are the
%                     lower and uppert cutoff frequencies for bandlimited
%                     noise carrier, respectively.
%   flow            : Lower cutoff freuqnecy used to lowpass filter the
%                     envelope
%   beta            : Modulation index
%   alpha           : Raised power exponent
%   B               : B-spline filter order
%   Fs              : Sampling rate (Hz)
%   M               : Number of samples
%
%RETURNED VARIABLES
%
%   X               : Returned signal
%   Xm              : Modulation Envelope
%
% (C) Monty A. Escabi, December 2007 (Edit Escabi, March 2009)
%
function [X,Xm] = raisedsinetranspose(fm,fc,flow,beta,alpha,B,Fs,M)

%Generating Carrier Signal
if length(fc)==1
    Xc=sin(2*pi*fc*(0:M-1)/Fs);
else
    %Xc=noiseunifh(f1,f2,Fs,M);
    Xc=noiseblh(fc(1),fc(2),Fs,M);
end

%Generating Envelope
[H]=bsplinelowpass(flow,B,Fs);
NH=(length(H)-1)/2;
NT=ceil(1/fm*Fs);
Xm=max(sin(2*pi*fm*(0:M+6*max(NH,NT)-1)/Fs),0);
Xm=conv(Xm,H);
Nstart=ceil((2*NH+1)/NT)*NT-NT/4+NH+1;
Xm=Xm(Nstart+1:Nstart+M);
Xm=((Xm-min(Xm))/(max(Xm)-min(Xm))).^alpha;
Xm=(Xm-min(Xm))/(max(Xm)-min(Xm))*beta+(1-beta);
%Xm=( (1-(1-beta)^(1/alpha))*Xm + (1-beta)^(1/alpha) ).^alpha;

%Modulating Carrier Signal
X=Xm.*Xc;