%
%function  [H]=ncshilbert(Data,f1,f2,TW,ATT)
%
%DESCRIPTION: Bandpass filtered Hilber transform applied to multi
%	      channel data from NCS file
%
%   Data	: Data structure containg all NCS channels from single 
%		  recording session (obtained using READALLNCS)
%   f1		: Bandpass filter lower cutoff (Hz)
%   f2	 	: Bandpass filter upper cutoff (Hz)
%   TW		: Bandpass filter transition width (Hz)
%   ATT		: Bandpass filter attenuation (dB)
%
%RETURNED VARIABLES
%
%    H		: Hilbert Transform Data Structure for all Channels
%		  X : Hilber tranform
%		  A : Modulation Amplitude
%		  P : Phase
%		  Fs: Sampling Rate
%
%Monty A. Escabi, Aug. 24, 2004
%
function  [H]=ncshilbert(Data,f1,f2,TW,ATT)

%Bandpass Filtering Data / Computing Hilbert Transform
h=bandpass(f1,f2,TW,Data(1).Fs,ATT,'off');
N=(length(h)-1)/2;
for k=1:length(Data)
	Y=conv(Data(k).X,h);
	YY=Y(N+1:length(Y)-N);
	H(k).X=hilbert(YY);	
	H(k).Fs=Data(1).Fs;
	H(k).A=abs(H(k).X);
	H(k).P=unwrap(angle(H(k).X));
end

