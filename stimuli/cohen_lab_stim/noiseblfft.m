%
%function [Noise]=noiseblfft(f1,f2,Fs,M)
%
%       FILE NAME       : NOISEBLFFT
%       DESCRIPTION     : Band Limited White Noise Generator
%			  Designed in Frequency Domain using FFT
%
%       f1              : Lower Cutoff Frequency
%       f2              : Upper Cutoff Frequency
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%
function [Noise]=noiseblfft(f1,f2,Fs,M)

%FFT Length
NFFT=2^ceil(log2(M));

%Finding Carrier Frequency
fc=(f1+f2)/2;

%Generating Noise
Noise=zeros(1,NFFT);
N1=2;
Noise(1)=1;
N2=ceil((f2-fc)/Fs*NFFT);
Noise(N1:N2)=exp(i*2*pi*rand(1,N2-N1+1));
Noise(NFFT-N2+2:NFFT)=conj(Noise(N2:-1:2));
Noise=ifft(Noise);
Noise=real(Noise)*2*sqrt(NFFT);
Noise=Noise(1:M);

%Desining a carrier and Modulating
naxis=1:M;
carrier=sin(2*pi*fc/Fs*naxis+rand*2*pi);
Noise=Noise.*carrier;

%Making unit variance
Noise=Noise/std(Noise);
