%
% function [] = opticalildbpwav(filename,f1,f2,T,RT,ILD,Fs,M)
%
%	FILE NAME 	: OPTICAL ILD BP WAV 2
%	DESCRIPTION : Generates a interaural level difference wav file for use
%                 with optical recordings. Uses a bandpass filtered MLS 
%                 sound and generates a ILD using the consant average 
%                 binaural difference method. The MLS is filtered using a
%                 bandwidth of dX octaves. dX octave bands are tested
%                 between frequencies f1 and f2.
%
%   filename    : Wav filename
%   f1          : Lower cutoff frequency for testing
%   f2          : Upper cutoff frequency for testing
%   dX          : Noise bandwidht in octaves (for instance 1/3 octave)
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
function [X1,X2] = opticalildbpwav2(filename,f1,f2,dX,T,RT,ILD,Fs,M)

%Calculating Number of samples per period and for the entire sound
L=length(ILD);
Nperiod=round(M/L);    %Number of samples per period
M=Nperiod*length(ILD); %Total number of samples in the WAV file

%Generatign MLS
NB=nextpow2(T/1000*Fs)-1;
XX=mls(NB,0);
W=windowm(Fs,3,length(XX),RT);
XX=XX.*W;
X=zeros(1,Nperiod);
X(1:length(XX))=XX;

%Filtering Low and High frequencies
NX=log2(f2/f1)/dX;

%Generating ILD sequence
X1=[];
X2=[];
for k=1:length(ILD)
    for l=1:NX
        
        %Filtering Sound
        fl=f1*2^((l-1)/3);
        fh=f1*2^(l/3);
        H=bandpass(fl,fh,(fh-fl)/4,Fs,30,'n');
        XX=ifft(fft(X).*fft(H,length(X)));
        
        X1=[X1 10.^(ILD(k)/2/20).*XX];
        X2=[X2 10.^(-ILD(k)/2/20).*XX];
    end

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