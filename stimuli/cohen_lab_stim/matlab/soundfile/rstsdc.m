%
%function [X,Param]=rstsdc(f1,f2,dt,Fs,M,NS,df,SD,seed)
%
%       FILE NAME       : RSTS (Random SpectroTemporal Dynamic Contrast Stimuli)
%       DESCRIPTION     : Generates random spectro temporal stimuli. 
%                         Motivated by Yu and Young (2000,2007). The
%                         contrast is varied dynamically similar to
%                         Robinowitz (2007).
%
%       f1              : Lowest frequency (Hz)
%       f2              : Upper frequency (Hz)
%       dt              : Window duration (msec). This window is used to
%                         generate the temporal modulations. The maximum
%                         modulation frequency is ~1/2/(dt/1000) Hz.
%       Fs              : Sampling rate (Hz)
%       M               : Number of time samples
%       NS              : Number of sinusoids per octave
%       df              : Frequency resolution for each spectral level 
%                         (in octaves; determines the number of adjacent 
%                         channels that have the same spectral level)
%       SD              : Spectral contrast array expressed as a standard
%                         deviation (in dB). The elements in the array
%                         designate the contrast conditions that will be
%                         delivered dynamically.
%       dtc              : 
%       seed            : Starting seed for random number generator
%
%RETURNED VALUES
%
%       X               : Sound waveform
%       Param           : Structure containing stimulus parameters
%
%               .f1     : Lowest frequency (Hz)
%               .f2     : Upper frequency (Hz)
%               .dt     : Window duration (msec). This window is used to
%                         generate the temporal modulations. The maximum
%                         modulation frequency is ~1/2/(dt/1000) Hz.
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
%               .P      : Carrier phases
%               .seed   : Random seed used to generate sound
%    
%   (C) M. Escabi, August 2012
%
function [X,Param]=rstsdc(f1,f2,dt,Fs,M,NS,df,SD,seed)

%Input Args
if nargin<9
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

%Generating spectrotemporal envelope
[W]=window(Fs,10,dt,dt);
L=length(W)/2+1;
N=length(1:dN:Nf);  %Number of spectral segments with resolution df
Le=length(1:L:M);
for k=1:N

    Et=zeros(1,M);
    Et(1:L:M)=SD*((rand(1,Le)+rand(1,Le)+rand(1,Le)+rand(1,Le))-2)/(1/sqrt(3));
    Et=conv(Et,W);
    E(k,:)=Et(1:M);
    
end

%Generating sound
P=rand(1,length(E))*2*pi;
X=zeros(1,M);
taxis=(0:M-1)/Fs;
for k=1:length(faxis)
    X=X+10.^(E(floor((k-1)/dN)+1,:)/20).*sin(2*pi*faxis(k)*taxis+P(k));
end

%Parameter Structure
Param.f1=f1;
Param.f2=f2;
Param.dt=dt;
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