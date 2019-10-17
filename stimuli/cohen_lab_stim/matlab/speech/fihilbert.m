%function [HarmonicData]=fihilbert(X,Fs,fo,BW,ATT,L)
%	
%	FILE NAME       : FI HILBERT
%	DESCRIPTION     : Find the instantanous frequency profile for the ith
%                     harmonic, Fi. Bandpass filters to extract the ith
%                     harmonic and then uses the hilbert transform to
%                     estimate the phase and Fi.
%
%	X               : Signal
%   fo              : Approximate mean of fundamental frequency (Hz)
%   BW              : Bandwidth used to filter fundamental (Hz)
%   ATT             : Filter attenuation (dB)
%   L               : Number of Harmonics to extract
%
%   RETURNED VARIABLES
%
%   HarmonicData(k) : Array of data structure containing
%                     .Y
%                     .Phase
%                     .Fi
%
% (C) Monty A. Escabi, June 2010
%
function [HarmonicData]=fihilbert(X,Fs,fo,BW,ATT,L)

for k=1:L

    %Generating Bandpass filters
    BWi=min(BW*k,fo);
    f1=fo*k-BWi/2*k;
    f2=fo*k+BWi/2*k;
    TW=(f2-f1)/2;
    [H] = bandpass(f1,f2,TW,Fs,ATT,'n');

    %Extracting Harmonics
    Y=conv(H,X);
    N1=(length(H)-1)/2;

    %Computing Analitic Signal and Extracting Fi
    Z=hilbert(Y);
    Phase=unwrap(angle(Z));
    Fi=1/2/pi*diff(Phase)*Fs;

    %Lowpass filtering Fi to remove distortions that exceed bandwidht
    H=lowpass(BW/2,TW,Fs,ATT,'n');
    N2=(length(H)-1)/2;
    Fi=conv(H,Fi);
    Fi=Fi(N1+N2+1:length(Fi)-N1-N2);

    %Adding results to data structure
    HarmonicData(k).Phase=Phase(N1+1:length(Phase)-N1);
    HarmonicData(k).Fi=Fi;
    HarmonicData(k).Y=Y(N1+1:length(Y)-N1);;
    HarmonicData(k).Z=Z;
    HarmonicData(k).Fs=Fs;

end