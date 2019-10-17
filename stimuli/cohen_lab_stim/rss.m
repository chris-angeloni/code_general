%
%function [X,Param]=rss(f1,f2,Fs,M,NS,df,SD,seed)
%
%       FILE NAME       : RSS (Random Spectral Stimuli)
%       DESCRIPTION     : Generates random spectral stimuli similar to
%                         those of Yu and Young (2000,2007)
%
%       f1              : Lowest frequency (Hz)
%       f2              : Upper frequency (Hz)
%       Fs              : Sampling rate (Hz)
%       M               : Number of time samples
%       NS              : Number of sinusoids per octave
%       df              : Frequency resolution for each spectral level 
%                         (in octaves; determines the number of adjacent 
%                         channels that have the same spectral level)
%       SD              : Spectral contrast expressed as a standard
%                         deviation (in dB)
%       seed            : Starting seed for random number generator
%
%RETURNED VALUES
%
%       X               : Sound waveform
%       Param           : Structure containing stimulus parameters
%
%               .f1     : Lowest frequency (Hz)
%               .f2     : Upper frequency (Hz)
%               .faxis  : Frequency Axis
%               .Fs     : Sampling Rate (Hz)
%               .M      : Number of time samples
%               .NS     : Number of sinusoids per octave
%               .df     : Frequency resolution for each spectral level 
%                         (in octaves; determines the number of adjacent 
%                         channels that have the same spectral level)
%               .SD     : Spectral contrast expressed as a standard
%                         deviation (in dB)
%               .E      : Spectrotemporal envelope (downsampled spectrally
%                         by 1/df)
%               .seed   : Random seed used to generate sound
%               .P      : Carrier phases
%    
%   (C) M. Escabi, August 2012
%
function [X,Param]=rss(f1,f2,Fs,M,NS,df,SD,seed)

%Input Args
if nargin<8
    rand('twister',sum(100*clock));
else
    rand('seed',seed);
end

%Generating Logarithmic Frequency Axis
NS=ceil(NS*df)/df;      %Increase NS so that the number of channels is a integer multiple to achieve desired df
dN=NS*df;   %Number of samples per df
XMax=log2(f2/f1);
X=(0:NS*XMax-1)/(NS*XMax)*XMax;
faxis=f1*2.^X;
Nf=length(faxis);

%Generating spectral envelope
E=zeros(1,Nf);
N=length(1:dN:Nf);   %Number of spectral segments with resolution df
E(1:dN:Nf)=SD*((rand(1,N)+rand(1,N)+rand(1,N)+rand(1,N))-2)/(1/sqrt(3));
W=ones(1,dN);
E=conv(E,W);
E=E(1:Nf);

%Generating sound
P=rand(1,length(E))*2*pi;
X=zeros(1,M);
taxis=(0:M-1)/Fs;
for k=1:Nf
    X=X+10.^(E(k)/20).*sin(2*pi*faxis(k)*taxis+P(k));
end

%Parameter Structure
Param.f1=f1;
Param.f2=f2;
Param.faxis=faxis;
Param.Fs=Fs;
Param.M=M;
Param.NS=NS;
Param.df=df;
Param.SD=SD;
Param.E=E;
Param.P=P;
if exist('seed')
    Param.seed=seed;
end