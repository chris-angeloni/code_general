%
%function [Noise]=ngausunif(fb,Fs,M)
%
%       FILE NAME       : NGAUSUNIF
%       DESCRIPTION     : Band Limited Noise having gausian and uniformly
%			  distributed noise properties
%
%       fb              : Upper Bandlimit Frequency
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%
function [Noise]=ngausunif(fb,Fs,M)

%Generating Noise
N=noiseblfft(0,fb,Fs,M);
indexp=find(N>=0);
indexn=find(N<0);
Noise(indexp)=(1./(1+10.^(-N(indexp)/std(N)))-.5);
Noise(indexn)=-(1./(1+10.^(-abs(N(indexn))/std(N)))-.5);
Noise=Noise+.5;
