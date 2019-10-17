%
%function [Noise]=noiseunifh(f1,f2,Fs,M,seed)
%
%       FILE NAME       : NOISE UNIF H
%       DESCRIPTION     : Band Limited Uniformly Distributed Noise Generator
%			  Designed by filtering gaussian noise and taking
%			  inverse transformation - ERF
%
%       f1              : Lower Cutoff Frequency
%       f2              : Upper Cutoff Frequency
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%	seed		: Random Number Generator Seed
%			  (Optional, Integer Valued)
%
function [Noise]=noiseunifh(f1,f2,Fs,M,seed)

%Generating Gaussianly Distributed Band Limited Noise
if exist('seed')
	Noise=noiseblh(f1,f2,Fs,M,seed);
else
	Noise=noiseblh(f1,f2,Fs,M);
end

%Converting from gaussian to uniform distribution
%This is similar to the ERF transformation depending on the flag
Noise=norm2unif(Noise,0,1);
