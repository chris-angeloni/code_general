%
% function [] = opticalildwav(filename,T,RT,ILD,Fs,M)
%
%	FILE NAME 	: OPTICAL ILD WAV 
%	DESCRIPTION : Generates a interaural level difference wav file for use
%                 with optical recordings. Uses an MLS sound and generates
%                 a ILD using the consant average binaural difference
%                 method.
%
%   filename    : Wav filename        
%   T           : Desired sound window duration (msec). The actual value is
%                 is adjusted because the MLS the duration has to be a 
%                 integer multiple of 2 (i.e., number of samples).
%   RT          : Window rise time (msec)
%   ILD         : Array containg the ILD conditiosn to generate (dB)
%   Fs          : Sampling rate (Hz)
%   M           : Total number of samples for file. Note that M/Fs 
%                 corresponds to the period for the optical Fourier 
%                 analysis. The exact number of samples is slightly
%                 adjusted so that the number of ILD conditions fit
%                 perfectly in the stimulus duration.
%
% RETURNED DATA
% 
% (C) Monty A. Escabi, March 2008
%
function [X1,X2] = opticalildwav(filename,T,RT,ILD,Fs,M)

%Calculating Number of samples per period and for the entire sound
L=length(ILD);
Nperiod=round(M/L);    %Number of samples per period
M=Nperiod*length(ILD); %Total number of samples in the WAV file

%Generatign MLS
NB=nextpow2(T/1000*Fs)-1;
[W]=window(Fs,3,2,RT);
W=W(1:floor(length(W)/2));
NW=length(W);
XX=mls(NB,0);
%[XX]=noiseunif(Fs/2,Fs,2^NB-1);
%XX=randn(1,2^NB-1);

XX(1:NW)=XX(1:NW).*W;
XX(2^NB-1:-1:2^NB-1-NW+1)=XX(2^NB-1:-1:2^NB-1-NW+1).*W;
X=zeros(1,Nperiod);
X(1:length(XX))=XX;

%Generating ILD sequence
X1=[];
X2=[];
for k=1:length(ILD)
    X1=[X1 10.^(ILD(k)/2/20).*X];
    X2=[X2 10.^(-ILD(k)/2/20).*X];
end

%Normalizing
%Note: Need to standardize so that we choose a fixed SPL??????
Max=max(abs([X1 X2]));
X1=round(X1/Max.*.95*(2^23-1)*256);
X2=round(X2/Max.*.95*(2^23-1)*256);
XX(1:2:length(X1)*2)=X1;
XX(2:2:length(X1)*2)=X2;

%Generating Wav File
%wavwrite([X1' X2'],Fs,32,filename);         %24 bit equivalent - uses 24 most significant bits out of 32
wavwri(XX,Fs,32,2,filename);