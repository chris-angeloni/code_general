%
% function [Y,Envelope] = stimgenerator(f1,f2,Fm,ModIndex,dt,rt,p,Duration,CarrierDelay,EnvDelay,Fs,seed)
%
%	FILE NAME 	: STIM GENERATOR
%	DESCRIPTION : Generates a modulated or non modulated signal. The
%                 carrier signal can be either a tone or bandlimited noise.
%                 The carrier and envelope can be delayed independently. 
%
%   f1          : Lower Frequency (Hz)
%   f2          : Upper Frequency (Hz)
%   Fm          : Modulation Frequency (Hz)
%   ModIndex    : Modulation Index
%   dt          : Window Duration (msec)
%   rt          : Window Rise Time (msec)
%   p           : Window Order
%   Duration    : Total Stimulus Duration (msec), including off segment
%   CarrierDelay: Delay for the carrier signal (msec)
%   EnvDelay    : Delay for Envelope (msec)
%   Fs          : Sampling Rate (Hz)
%   seed        : Random number generator seed
%
% RETURNED DATA
%
%   X           : Returned Sound
%
% (C) Monty A. Escabi, May 2008
%
function [Y,Envelope] = stimgenerator(f1,f2,Fm,ModIndex,dt,rt,p,Duration,CarrierDelay,EnvDelay,Fs,seed)

%Generating Envelope
N=round(Duration/1000*Fs);
K=round(EnvDelay/1000*Fs);
L=round(CarrierDelay/1000*Fs);
W=window(Fs,p,dt,rt);                               %Generating Window
W=[W zeros(1,N-length(W))];                         %Appending Zeros
Envelope=(1+ModIndex*sin(2*pi*Fm*(1:N)/Fs)).*W;     %Generating Modulated Envelope
Envelope=[zeros(1,K) Envelope(1:N-K)];              %Adding Delay

%Generating Carrier
if f1==f2                                           %Sinusoide Carrier
    fc=f1;
    X=sin(2*pi*fc*( (1:N)/Fs - L/Fs));              %Note that it includes Delay
elseif f1==0 & f2==Fs/2                             %Broadband Noise Carrier
    randn('state',seed)
    X=randn(1,N+L);
    X=fliplr(X(L:N+L-1));
else
    X=noiseblh(f1,f2,Fs,N+L,seed,'n');              %Bandlimited Noise Carrier
    X=fliplr(X(L:N+L-1));
end

%Modulating
Y=X.*Envelope;