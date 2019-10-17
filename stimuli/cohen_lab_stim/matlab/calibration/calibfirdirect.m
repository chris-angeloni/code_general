%
%function [CalibData] = calibfirdirect(DirectData,f1,f2,L,ATT,NFFT,Disp)
%
%   FILE NAME   : CALIB FIR DIRECT
%   DESCRIPTION : Generates a linear phase FIR inverse filter impulse
%                 response for given input / output calibration data.
%                 For this FIR filter it is not necessary to assign a 
%                 desired spectral resolution. It will be detirmined 
%                 automatically from L and ATT. Similar to CALIBFIR but 
%                 has additional results related to the power and cross
%                 spectrum.
%
%   DirectData   : Data structures containing calibration data
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
%       NFFT    : FFT Size for spectral estimates (Default,
%       NFFT=1024*4)
%       Disp    : Display output - 'y' or 'n' (Default, 'n')
%
%RETURNED DATA
%
%       CalibData  : Data structure containng the calibration resulsts     
%                     .hinv     - Impulse response of inverse calibration
%                                 filter at probe end
%                     .Gain     - Gain applied to hinv so that amplitude
%                                 does not exceed 8 Vpp
%                     .H        - Forward speaker transfer function
%                     .Hinv     - Inverse filter transfer function (1/H)
%                     .P1yy     - Spectrum at point 1
%                     .P1xx     - Input spectrum
%                     .P1yx     - Cross spectrum between input and point 1
%                     .F        - Frequency axis (Hz)
%                     .NFFT     - FFT Size
%
%(C) Monty A. Escabi, February 11, 2014
%
function [CalibData] = calibfirdirect(DirectData,f1,f2,L,ATT,NFFT,Disp)

%Input Arguments
if nargin<7
    ATT=100;
end
if nargin<8
    NFFT=1024*4;
end
if nargin<9
    Disp='n';
end

%Converting Signals to Pascals, note X does is in Volts and does not need
%to be converted to Pascals. Only Y is converted.
X=DirectData.X;
X=X-mean(X);
Y=DirectData.Y.*1000./10^(DirectData.MicGain/20)/DirectData.MicSensitivity;
Y=Y-mean(Y);
try 
    Ynoise=DirectData.YRoomNoise.*1000./10^(DirectData.MicGain/20)/DirectData.MicSensitivity;
    Ynoise=Ynoise-mean(Ynoise);
catch 
end

%Generating Kaiser Window for Spectrum Calculations
[Beta,N,wc] = fdesignk(ATT,0.1*pi,pi/2);
W=kaiser(NFFT,Beta);

%Generating Speaker Transfer Functions
Fs=DirectData.Fs;
[P,F]= spectrum(Y,X,NFFT,NFFT*7/8,W,DirectData.Fs);
Pyy=P(:,1);
Pxx=P(:,2);
Pyx=P(:,3);
H=Pyx./Pxx;  %Forward transfer function, NOT the inverse, FREQZ inverts!
try 
    [Pnoise,F]= spectrum(Ynoise,NFFT,NFFT*7/8,W,DirectData.Fs);
end

%Generates the Inverse Filter Impulse Response
W=(0:NFFT/2)/(NFFT/2)*pi;
[Hband] = bandpass(f1,f2,1500,Fs,40,'n');
[B,A] = invfreqz(H,W,0,L-length(Hband));
CalibData.hinv=conv(A,Hband);
CalibData.Gain=8/max(abs(conv(CalibData.hinv,X)));
CalibData.hinv=CalibData.Gain*CalibData.hinv;     %Assures that output amplitude does not exceed +/- 8 Volts

%Storing Transfer Function Results
CalibData.H=H;
CalibData.Hinv=1./H;
CalibData.Pyy=Pyy;
CalibData.Pxx=Pxx;
CalibData.Pyx=Pyx;
try
    CalibData.Pnoise=Pnoise;
end
CalibData.F=F;
CalibData.NFFT=NFFT;

%Plotting Summary Data
Po=2.2E-5;          %Threshold of hearing in Pascals
if strcmp(Disp,'y')
    figure
    F=F/1000;
    
    subplot(221)
    plot(F,20*log10(abs(H./Po)),'k')
    hold on
    plot((0:NFFT-1)/NFFT*Fs/1000,20*log10(abs(fft(CalibData.hinv./Po,NFFT))),'r')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('Transfer function=BLACK, Inverse filter=RED')

    subplot(222)
    Offset=10*log10((872161/Fs).^2);
    %Offset=20;                                  %NEED TO CHECK
    plot(F,10*log10(Pyy/NFFT*2./Po.^2)+Offset,'k')
    try
        hold on
        plot(F,10*log10(Pnoise(:,1)/NFFT*2./Po.^2)+Offset,'r')
        hold off
    end
    title('Output Spectrum=BLACK, Noise Spectrum=RED')
end


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