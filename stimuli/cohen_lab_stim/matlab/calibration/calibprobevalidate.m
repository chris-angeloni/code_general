%
%function [h] = calibfirprobe(ProbeData1,ProbeData2,ProbeData3,f1,f2,L,ATT,Disp)
%
%   FILE NAME   : CALIB FIR PROBE
%   DESCRIPTION : Generates a linear phase FIR inverse filter impulse
%                 response for given input / output calibration data.
%                 For this FIR filter it is not necessary to assign a 
%                 desired spectral resolution. It will be detirmined 
%                 automatically from L and ATT. Similar to CALIBFIR but 
%                 used for probe tube calibrations.
%
%   Data        : Data structure containing calibration data
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
%       f1      : Lower frequency (Hz)
%       f2      : Maximum frequency (Hz)
%       L       : Number of filter coefficients
%       ATT     : Filter sidelobe error, (Default 100 dB)
%       Disp    : Display output - 'y' or 'n' (Default, 'n')
%
%RETURNED DATA
%
%       h       : Filter impulse response data structure
%                 .hinv - Impulse response of inverse calibration filter
%                 .stdx - Standard deviation of input
%                 .stdy - Standard deviation of output
%
function [ProbeValData] = calibprobevalidate(h,ProbeData3)

%Converting Signals to Pascals, note X does is in Volts and does not need
%to be converted to Pascals. Only Y is converted.
X=ProbeData3.X;
Y=ProbeData3.Y./10^(ProbeData3.MicGain/20)/ProbeData3.MicSensitivity;
Y=Y-mean(Y);

%Generating Speaker Transfer Functions
NFFT=1024*4;
Fs=ProbeData3.Fs;
[P,F]= spectrum(Y,X,NFFT,NFFT*7/8,kaiser(NFFT,4),Fs);
Pyy=P(:,1);
Pxx=P(:,2);
Pyx=P(:,3);
Hinv=fft(h.hinv,NFFT)';
Hinv=Hinv(1:NFFT/2+1);
plot(F,20*log10(abs(Pyx./Pxx./h.Hprobe.*Hinv)))     %Predicted Calibrated Transfer Function

%Saving to Data Structure
ProbeValData.Pyy=Pyy;
ProbeValData.Pxx=Pxx;
ProbeValData.Pyx=Pyx;