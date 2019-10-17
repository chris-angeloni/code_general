%
%function [Noise]=noiseblh(f1,f2,Fs,M,seed,Norm)
%
%       FILE NAME       : NOISE BL H
%       DESCRIPTION     : Band Limited White Noise Generator
%                         Designed by filtering gaussian noise
%
%       f1              : Lower Cutoff Frequency
%       f2              : Upper Cutoff Frequency
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%       seed            : Random Number Generator Seed
%                         (Optional, Integer Valued)
%       Norm            : Normalize for Unit standard deviation
%                         (Default=='y')
%
%RETURNED VARIABLES
%
%       Noise           : Noise vector
%
% (C) Monty A. Escabi, Edited May 2008 (MAE, 2-2016) 
%
function [Noise]=noiseblh(f1,f2,Fs,M,seed,Norm)

%Input Arg
if nargin<6
    Norm='y';
end

%Designing Filter
TW=.1*(f2-f1)/2;
ATT=60;
H=bandpass(f1,f2,TW,Fs,ATT,'off');
N=(length(H)-1)/2;

%Setting the Random Noise Generator State
if exist('seed')
	randn('state',seed);
end

%Generating Noise
Noise=randn(1,2*N+M);
NFFT=2^nextpow2(N+M);
Noise=convfft(Noise,H,0,NFFT,M);    %Edit MAE, 2/2016 - fixed edge ertifact
Noise=Noise(2*N+1:M+2*N+1);         %Truncate to remove edge artifacts, Edit MAE 2/2016

%Normalizing
if strcmp(Norm,'y')
    Noise=Noise/std(Noise);
end