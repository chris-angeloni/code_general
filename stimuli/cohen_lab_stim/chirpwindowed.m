%
%function [X]=chirpwindowed(f1,f2,M,Fs,p,rt,method)
%
%       FILE NAME       : CHIRP WINDOWED
%       DESCRIPTION     : Generates a linear or Log chirp. The chirp is
%                         windowed with a p-th order B-spline window  
%
%       f1              : Lower frequency (Hz, > 1e-6 for 'log')
%       f2              : Upper frequency (Hz)
%       M               : Number of samples
%       Fs              : Sampling frequency (Hz)
%       p               : B-spline order
%       rt              : B-spline rise time (msec)
%       method          : Type of chirp ('lin' or 'log')
%       ChirpGain       : Highpass preemphasis gain (dB). Signal magnitude
%                         increases by ChirpGain (dB) from start to finish.
%                         (Default==0). Linear increase in dB per time.
%
function [X]=chirpwindowed(f1,f2,M,Fs,p,rt,method,ChirpGain)

%Input arguments
if nargin<8 | isempty(ChirpGain)
    ChirpGain=0;
end

%Generating Windowed Chirp
X = chirp((0:M-1)/Fs,f1,(M-1)/Fs,f2,method);
W=windowm(Fs,p,M,rt);
X=X.*W;

%Adding Preemphasis Highpass Gain - linear increase in dB per Hz
time=(0:M-1)/Fs;
Beta=10^(ChirpGain/20/max(time));
Gain=Beta.^time;
X=X.*Gain;
