%
%function [E]=bandpassenvelope(X,f1,f2,fm,Fs,FiltType)
%
%   FILE NAME   : BANDPASSENVELOPE
%   DESCRIPTION : Extracts the envelope of a signal within a band between
%                 f1 and f2. The modulations are limited to a frequency fm.
%
%   X           : Input signal
%   f1          : Lower cutoff frequency of bandpass filter (Hz)
%   f2          : Upper cutoff frequency of bandpass filter (Hz)
%   fm          : Upper modulation frequency limit (Hz)
%   Fs          : Samping rate (Hz)
%   FiltType    : Filter type: b-spline ('b') or Kaiser ('k'). Default=='b'
%
%RETURNED OUTPUTS
%
%   E           : Bandlimited envelope
%
function [E,Xa] = bandpassenvelope(X,f1,f2,fm,Fs,FiltType)

%Inputu Args
if nargin<6
    FiltType='b';
end

%Generating input and output filters
ATT=60;
TWa=0.25*(f2-f1);
TWb=0.25*fm;
Ha=bandpass(f1,f2,TWa,Fs,ATT,'n');
Na=(length(Ha)-1)/2;
if strcmp(FiltType,'k')
    Hb=lowpass(fm,TWb,Fs,ATT,'n');
else
    Hb=bsplinelowpass(fm,5,Fs);
end
Nb=(length(Hb)-1)/2;
Hb=Hb/sum(Hb);  %Normalized for unit DC gain

%Bandpass filtering input
Xa=conv(X,Ha);
Xa=Xa(Na+1:end-Na);

%Extracting Envelope
E=abs(hilbert(Xa));

%Lowpass filtering Envelope
E=conv(E,Hb);
Nb=(length(Hb)-1)/2;
E=abs(E(Nb+1:end-Nb));
