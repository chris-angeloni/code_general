%
%function [Noise]=noiseunif(fb,Fs,M,seed)
%
%       FILE NAME       : NOISE UNIF
%       DESCRIPTION     : Bandlimited Uniformly Distributed Noise
%
%       fb              : Upper Bandlimit Frequency - if fb is a two
%                         element vector then the routine generates
%                         bandpass noise with f1=fb(1) and f2=fb(2)
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%       seed            : Seed for random number generator
%                         (Default = no seed)
%
% (C) Monty A. Escabi, Edit Aug 2008
%
function [Noise]=noiseunif(fb,Fs,M,seed)

if nargin<4
    rand('twister',sum(100*clock));
else
    rand('seed',seed);    
end
if length(fb)==2
   f1=fb(1);
   f2=fb(2);
   fb=(f2-f1)/2;
end

Noise=0;
while length(Noise)<M				%Make sure at least M elemnts

	%Generating Noise
	L=Fs/(fb*2);				%Interpolation Factor
	Noise=rand(1,ceil(M/L*2))-.5;
	N=length(Noise);
	NL=round(N*L);
	if L<10
		Noise=interp1((0:N-1)/(N-1),Noise,(0:NL-1)/(NL-1),'cubic')';
	elseif L<100 
		NL=round(NL/10);
		Noise=interp1((0:N-1)/(N-1),Noise,(0:NL-1)/(NL-1),'cubic')';
		Noise=interp10(Noise,1);
	else
		NL=round(NL/100);
		Noise=interp1((0:N-1)/(N-1),Noise,(0:NL-1)/(NL-1),'cubic')';
		Noise=interp10(Noise,2);
	end

	%Normalizing and Applying Non-Linearity 
	indexp=find(Noise>0);
	indexn=find(Noise<0);
	stdN=std(Noise);
	Noise(indexp)=(1./(1+10.^(-Noise(indexp)/stdN/2.4))-.5);
	Noise(indexn)=-(1./(1+10.^(Noise(indexn)/stdN/2.4))-.5);
	index=find(min(Noise)*.8<Noise & Noise<max(Noise)*.8);
	Noise=Noise(index);
	Noise=norm1d(Noise);
end

%Truncating to Length M
Noise=Noise(1:M);
L=size(Noise);
if L(1) > L(2)
	Noise=Noise';
end

%Shifting spectrum
if exist('f1')
    Noise=(Noise-mean(Noise)).*sin(2*pi*(f1+f2)/2*(1:M)/Fs)*2;
end