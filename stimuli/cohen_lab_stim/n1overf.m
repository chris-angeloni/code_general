%
%function [taxis,Noise]=n1overf(f1,f2,alpha,Fs,M)
%
%       FILE NAME       : n1overf
%       DESCRIPTION     : Bandlimited 1/f noise
%
%       f1              : Lower Cutoff Frequency
%       f2              : Upper Cutoff Frequency
%	alpha		: Power Law Exponent - Defined for PSD
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%
function [taxis,Noise]=n1overf(f1,f2,alpha,Fs,M)

%Making sure M is dyadic
Morig=M;
M=2^nextpow2(M);

%Generating Noise
alpha=alpha/2;
Noise=zeros(1,M);
N1=ceil(f1/Fs*M+1);
N2=floor(f2/Fs*M);
Noise(N1:N2)=exp(i*2*pi*rand(1,N2-N1+1)).*( (N1:N2)*Fs/M ).^(-alpha)*(N1*Fs/M).^alpha;
Noise(M-N2+2:M)=conj(Noise(N2:-1:2));
Noise=ifft(Noise);
Noise=real(Noise)*2*sqrt(M);

%Setting up Axis and Truncating Noise Signal
Noise=Noise(1:Morig);
taxis=(0:Morig-1)/Fs;
