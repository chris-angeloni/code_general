%
%function [X]=ammodnoise(BW,Fm,gamma,T,dt,rt,Fs)
%
%   FILE NAME   : AM MOD NOISE
%   DESCRIPTION : Generates a .WAV file which is used for 
%                 MTF experiments. Stimulus consists of periodic noise
%                 bursts with a duration of dt.
%
%   BW          : Noise Bandwidth
%                 Default==inf (Flat Spectrum Noise)
%                 Otherwise BW=[F1 F2]
%                 where F1 is the lower cutoff and
%                 F2 is the upper cutoff frequencies
%   Fm          : Modulation Frequency (Hz)
%   gamma       : Modulation Index (0 < gamma < 1)
%   T           : Stimulus Duration (sec)
%   dt          : Noise Burst Window Width (msec)
%   rt          : Noise Burst Rise Time (msec)
%   Fs          : Sampling frequency
%
%RETURNED VARIBLES
%
%	X       : AM NOISE 
%             Normalized for a fixed energy per Hz
%
% (C) Monty A. Escabi, Oct 2005
%
function [X]=ammodnoise(BW,Fm,gamma,T,dt,rt,Fs)

%Generaging Burst Modulation Segment 
W=window(Fs,3,dt,rt);
M=round(Fs/Fm);
X1=zeros(1,M);
X1(1:length(W))=W;

%Number of Modulation Cycles
L=floor(T*Fs/M);

%Generating Noise
if BW==inf
	N=2*(rand(1,round(Fs*T))-0.5);
%	N=randn(1,round(Fs*T));
else
	%N=noiseblfft(BW(1),BW(2),Fs,round(Fs*T));
    N=noiseblh(BW(1),BW(2),Fs,round(Fs*T));   %Changed 12/10/10, better statistics, closer to normal distribution
end

%Normalizing Power Per Frequency Band
if BW~=inf
    N=N/std(N);
    N=N*sqrt(2*(BW(2)-BW(1))/Fs);
end

%Generating Modulation Envelope
Env=[];
for k=1:L
	Env=[Env X1];
end
Env=[Env zeros(1,length(N)-length(Env))];

%Generating Modulated Noise
X=(Env*gamma+(1-gamma)).*N;