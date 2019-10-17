%
%function [H] = lowpass(fc,TW,Fs,ATT,Disp)
%	
%	FILE NAME       : Low Pass Filter Design
%	DESCRIPTION 	: Impulse response of optimal Low Pass filter 
%                     as designed by Roark/Escabi.
%
%	H               : Calculated impulse response
%	fc              : Cutoff frequency (in Hz)
%	TW              : Transition width (in Hz)
%	Fs              : Sampling Frequency (in Hz)
%	ATT             : Passband and stopband error (Attenuationin dB)
%	Disp            : optional -> 'n' to turn display off
%                     default  -> 'n'
%
% (C) Monty A. Escabi, Last Edit December 2007
%
function [H] = lowpass(fc,TW,Fs,ATT,Disp)

%Preliminaries
if nargin<5
	Disp='n';
end

%Designing low pass filter 
wc=2*pi*fc/Fs;	%Center Frequency in discrete domain
tw=2*pi*TW/Fs;  %Tranzition width in discrete domain

%Finding Low pass filter parameters and impulse response
[P,N,alpha,wl] = fdesignh(ATT,tw,wc);
[H] = h(-N:N,wl,alpha,P);

%Display
M=2^ceil(log2(length(H)))*16;
L=round(M*fc/Fs);
if strcmp(Disp,'y')
	subplot(211)
	HH=abs(fft(H,M));
	plot((1:M)/M*Fs,20*log10(HH),'r'),axis([0 Fs/2 min(20*log10(HH)) 0])
	ylabel('Power Spectrum (dB)'),xlabel('Frequency (Hz)')

	subplot(212)
	plot((1:L)/M*Fs,HH(1:L)),axis([0 L/M*Fs 1-10^(-ATT/20) 1+10^(-ATT/20)])
	ylabel('Linear Passband Amplitude'),xlabel('Frequency (Hz)')
end