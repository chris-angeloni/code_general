%
%function [X,Env,Fm]=pnbsplinemodnoise(BW,Fm,gamma,fc,p,T,Fs)
%
%   FILE NAME   : PERIODIC B SPLINE MOD NOISE
%   DESCRIPTION : Generates a periodic B-spline modulated noise signal for
%                 MTF experiments.
%
%   BW          : Noise Bandwidth
%                 Default==inf (Flat Spectrum Noise)
%                 Otherwise BW=[F1 F2]
%                 where F1 is the lower cutoff and
%                 F2 is the upper cutoff frequencies
%   Fm          : Modulation Frequency (Hz)
%   gamma       : Modulation Index (0 < gamma < 1)
%   fc          : Cardinal B-Spline lowpass filter cutoff (Hz)
%   p           : Cardinal B-Spline lowpass filter order
%   T           : Stimulus Duration (sec)
%   Fs          : Sampling frequency
%   seed        : Random seed - used to set the random number generator for
%                 creating the carrier noise signal. This is usefull if you
%                 want to create frozen noise carrier (OPTIONAL, randomized
%                 seed using clock and 'twizter' algorithm, see RAND)
%
%RETURNED VARIBLES
%
%   X       : Periodic B-Spline noise (PBS)
%             Normalized for a fixed energy per Hz
%   Env     : Periodic B-spline envelope
%   Fm      : Rounded off modulation frequency (Hz)
%
% (C) Monty A. Escabi, March 2009
%
function [X,Env,Fm]=pnbsplinemodnoise(BW,Fm,gamma,fc,p,T,Fs,seed)

if nargin<8
    rand('twister',sum(100*clock));
else
    rand('twister',seed);
end

%Generaging Burst Modulation Segment
N=round(Fs/Fm);
Fm=Fs/N;
X1=zeros(1,N);
X1(1)=1;

%Number of Modulation Cycles
L=floor(T*Fs/N);

%Number of Samples
NS=round(Fs*T);
%Generating Modulation Envelope - In this first step generate a periodic
%pulse train
Env=[];
for k=1:L
	Env=[Env X1];
end
Env=[zeros(1,N) Env];
if length(Env)<NS
   Env=[Env zeros(1,NS-length(Env))];
end

%Filtering Periodic Pulse train with B-Spline lowpass filter - This
%generates the periodic B-spline envelope
h=bsplinelowpass(fc,p,Fs);
Nh=ceil(length(h)-1)/2;
Env=conv(h,Env);
Env=Env/max(Env);
Env=Env(Nh:length(Env)-Nh-1);

%Generating Noise
if BW==inf
	N=2*(rand(1,length(Env))-0.5);
else
	N=noiseblfft(BW(1),BW(2),Fs,length(Env));
end

%Normalizing Power Per Frequency Band
if BW~=inf
    N=N/std(N);
    N=N*sqrt(2*(BW(2)-BW(1))/Fs);
end

%Generating Modulated Noise
X=(Env*gamma+(1-gamma)).*N;