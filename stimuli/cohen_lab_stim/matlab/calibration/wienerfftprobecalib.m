%
%function [Hinv] = wienerfftprobecalib(DataProbe1,DataProbe2,DataCalib,beta,N)
%
%	FILE NAME 	: WIENER FFT PROBE CALIB
%	DESCRIPTION	: Optimal Wiener Inverese Filter Estimate for in situ
%                 animal calibration. 
%                 Derived using frequency domain estimator.
%
%	DataProbe1  : Probe calibration data structure at the ear canal
%                 location. Typically taken with the 1/8 inch microphone
%                 .X - Input
%                 .Y - Output
%   DataProbe2  : Probe calibration data structure at probe end location.
%                 Typically taken witht he 1/2 inch microphone
%                 .X - Input
%                 .Y - Output
%   DataProbe3  : Calibration Data with Animal in place
%                 .X - Input 
%                 .Y - Output at probe end
%   S1          : Microphone Sensitivity (mv/pascal)
%   S2          : Microphone Sensitivity (mv/pascal)
%   S3          : Microphone Sensitivity (mv/pascal)
%	beta		: Kaiser window smoothing factor
%	N           : Filter order
%
%RETURNED VARIABLES
%   
%   Hinv        : Inverse filter impulse response coefficients
%
% (C) Monty A. Escabi, June 2009
%
function [Hinv] = wienerfftprobecalib(DataProbe1,DataProbe2,DataProbe3,S1,S2,S3,beta,N)

%Removing DC and converting to pascals
Y1=(DataProbe1.Y-mean(DataProbe1.Y))/(S1/1000);
Y2=(DataProbe2.Y-mean(DataProbe2.Y))/(S2/1000);
Y3=(DataProbe3.Y-mean(DataProbe3.Y))/(S3/1000);
X1=DataProbe1.X-mean(DataProbe1.X);
X2=DataProbe2.X-mean(DataProbe2.X);
X3=DataProbe3.X-mean(DataProbe3.X);

%Probe Impulse responses
[H1] = wienerfft(X1,Y1,beta,N);
[H2] = wienerfft(X2,Y2,beta,N);

%In Situ Impulse response
[H3] = wienerfft(X3,Y3,beta,N);

%Generating inverse filter
Fs=97656.25;
faxis=(0:N-1)/N*Fs;
HH1=fft(H1);
HH2=fft(H2);
HH3=fft(H3);
HHprobe=HH2./HH1;
HHinv=HHprobe./HH3;
HW=lowpass(40000,500,Fs,40,'n');
Hinv=fftshift(real(ifft(fft(HW,N).*HHinv)));
%Hinv=1;

semilogx(faxis',20*log10(HH2./HH1),'b')