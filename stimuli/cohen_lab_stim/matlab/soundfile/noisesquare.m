%
%function [Noise]=noisesquare(f1,f2,Fs,M,seed)
%
%       FILE NAME       : NOISE SQUARE
%       DESCRIPTION     : Bandlimited square wave noise 
%			  Similar to m-sequence
%
%       f1              : Lower Bandlimit Frequency
%       f2              : Upper Bandlimit Frequency
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%	seed		: Random Number Generator Seed
%			  (Optional, Integer Valued)
%
function [Noise]=noisesquare(f1,f2,Fs,M,seed)

%Generating Noise
if exist('seed')
	X=noiseunifh(f1,f2,Fs,M,seed);
else
	X=noiseunifh(f1,f2,Fs,M);
end
Noise=round(X);
