%
%function [H] = bandpass(f1,f2,TW,Fs,ATT,Disp)
%	
%	FILE NAME       : Band Pass Filter Design
%	DESCRIPTION 	: Impulse response of optimal Band Pass filter 
%                     as designed by Roark/Escabi.
%
%	H               : Calculated impulse response
%	f1              : Lower cutoff frequency (in Hz)
%	f2              : Upper cutoff frequency (in Hz)
%	TW              : Transition width (in Hz)
%	Fs              : Sampling Frequency (in Hz)
%	ATT             : Passband and stopband error (Attenuationin dB)
%	Disp            : optional -> 'n' to turn display off
%                     default  -> 'n'
%
% (C) Monty A. Escabi, Last Edit Jan 2008
%
function [H] = bandpass(f1,f2,TW,Fs,ATT,Disp)

%Preliminaries
if nargin<6
	Disp='n';
end

%Designing band pass filter 
if f1==0 %Lowpass Filter
	H=lowpass(f2,TW,Fs,ATT,'off');
else
    %Jan 2008, changed procedure
    %Previously subtracted two lowpass filters
    %Now I frequency shift a lowpass filter
    H=lowpass((f2-f1)/2,TW,Fs,ATT,'off');  
    fc=(f2-f1)/2+f1;
    N=(length(H)-1)/2;
    H=2*H.*cos(2*pi*fc*(-N:N)/Fs);  %Frequency shift the filter
end

%Display
M=2^ceil(log2(length(H)))*8;
if strcmp(Disp,'y')
	subplot(211)
	HH=abs(fft(H,M));
	plot((1:M)/M*Fs,20*log10(HH),'r'),axis([0 Fs/2 min(20*log10(HH)) 0])
	ylabel('Power Spectrum (dB)'),xlabel('Frequency (Hz)')
	subplot(212)

	plot((1:M)/M*Fs,HH),axis([f1 f2 1-10^(-ATT/20) 1+10^(-ATT/20)])
	ylabel('Linear Passband Amplitude'),xlabel('Frequency (Hz)')
end
