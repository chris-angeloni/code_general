%
%function [h] = calibspectrum(ProbeData,ATT,NFFT)
%
%   FILE NAME   : CALIB SPECTRUM
%   DESCRIPTION : Computes the power spectrum and cross spectrum from calibration data.
%
%   ProbeData   : Data structures containing calibration data
%                 .X                - Input white noise signal
%                 .Y                - Recorded speaker output signal
%                 .YRoomNoise       - Recorded room noise, no input
%                                     (optional)
%                 .Fs               - sampling rate (Hz)
%                 .MicGain          - B&K Amplifier Gain (dB)
%                 .SPL              - RMS SPL (dB re 2.2E-5 Pa)
%                 .SPLmax           - Maximum SPL (dB re 2.2E-5 Pa)
%                 .MicSerialNumber  - Serial number from spec sheet
%                 .DateTime         - Date and time that data was acuired 
%                                     (see 'clock' command for format)
%       ATT     : Filter sidelobe error, (Default 100 dB)
%       NFFT    : FFT Size
%
%RETURNED DATA
%
%       ProbeSpectrum - Data structure containing
%
%                        .Pyy       - output spectrum
%                        .Pxx       - input spectrum
%                        .Pyx       - cross spectrum
%                        .Pnoise    - Room noise spectrum
%                        .F         - Frequency axis (Hz)
%                        .NFFT      - fft size
%
%(C) Monty A. Escabi, Aug 2010
%
function [ProbeSpectrum] = calibspectrum(ProbeData,ATT,NFFT)

%Input Arguments
if nargin<2
    ATT=100;
end

%Converting Signals to Pascals, note X does is in Volts and does not need
%to be converted to Pascals. Only Y is converted.
X=ProbeData.X;
X=X-mean(X);
Y=ProbeData.Y.*1000./10^(ProbeData.MicGain/20)/ProbeData.MicSensitivity;
Y=Y-mean(Y);
try Ynoise=ProbeData.YRoomNoise.*1000./10^(ProbeData.MicGain/20)/ProbeData.MicSensitivity; catch end
try Ynoise=Ynoise-mean(Ynoise); catch end

%Generating Kaiser Window for Spectrum Calculations
[Beta,N,wc] = fdesignk(ATT,0.1*pi,pi/2);
W=kaiser(NFFT,Beta);

%Generating Spectrum
Fs=ProbeData.Fs;
[P,F]= spectrum(Y,X,NFFT,NFFT*7/8,W,ProbeData.Fs);
Pyy=P(:,1);
Pxx=P(:,2);
Pyx=P(:,3);
try [Pnoise,F]= spectrum(Ynoise,NFFT,NFFT*7/8,W,ProbeData.Fs); catch end

%Storing Spectrum
ProbeSpectrum.Pyy=Pyy;
ProbeSpectrum.Pxx=Pxx;
ProbeSpectrum.Pyx=Pyx;
try ProbeSpectrum.Pnoise=Pnoise(:,1); catch end
ProbeSpectrum.F=F;
ProbeSpectrum.NFFT=NFFT;

%NOTE - for MATLAB Parsevals Theorem is written out as
%
%mean(Y.^2)=mean(Pyy) or sum(Pyy/NFFT*2)
%
%So this appears to be the correct normalization. I also used this normalization 
%in riplespec. However, when I compare the MAXIMUM SPL from the chirp traces 
%to the SPL I measure using the above normalization It is about 40 dB lower! 
%Why is this?  I believe its because we are averaging over 10 seconds. The 
%PSD computes the average power in a given band over ~10 seconds. The ~10 
%seconds means the power is down by ~40 dB. However, instantaneously, the power 
%can be very high, about ~40 dB higher. The sound is slightly shorter than
%10 seconds (for chirp its 872161 samples, 8.9 seconds)
%