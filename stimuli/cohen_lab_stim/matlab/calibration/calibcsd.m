%
%function [H] = calibcsd(Data,Fs,NFFT,ATT)
%
%	FILE NAME 	: SOUND CALIB CSD
%	DESCRIPTION 	: Computes the transfer function of a sound system
%			  by computing the cross-spectral density of a 
%			  white noise input-output
%
%   Data    : Data structure containing:
%             .X - input white noise signal
%             .Y - recorder speaker output signal
%	Fs		: Sampling rate
%	NFFT    : FFT Size
%	ATT		: Spectral attenuation
%
%RETURNED DATA
%
%	H		: Transfer function data structure
%			  .Fs - Sampling Rate
%             .Hz - Transfer Function
%
function [H] = calibcsd(Data,NFFT,ATT)

%Input Output Calibration Data
X=Data.X;
Y=Data.Y;
Fs=Data.Fs;

%Normalizing for unit standard deviation relative to channel 1
%If the Gain is different between channel 1 and 2 at the output
%This will be reflected in the csd. Assumes that the STD for X1 and X2 
%is identical
%X=X/std(X);
%Y=Y/std(Y);

%Designing Window
[Beta,N,wc] = fdesignk(ATT,0.1*pi,pi/2);
W=kaiser(NFFT,Beta);

%Computing Cross Spectral Density and Fitting With Straight Line
[P,F]= spectrum(Y,X,NFFT,NFFT*7/8,W,Fs);
Pyx=P(:,3);
Pxx=P(:,2);
%[Pyx,F]=csd(Y,X,NFFT,Fs,W);
%[Pxx,F]=psd(X,NFFT,Fs,W);
%[P,S] = polyfit(log10(F(2:length(F))),10*log10(Pxx(2:length(F))),1);
%Pxx2 = 10.^(polyval(P,log10(F(2:length(F)))) / 10);
%Pxx2=[Pxx2(1) ; Pxx2];

%Hz=Pyx./var(X);         %Digital Transfer Function
%Hz=Pyx./Pxx2;         %Digital Transfer Function
%Hz=Pyx./Pxx;         %Digital Transfer Function
Hz=Pyx./1;         %Digital Transfer Function
H.Hz=[Hz; flipud(conj(Hz(2:NFFT/2)))];
H.Fs=Fs;