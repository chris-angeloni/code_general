%
%function [CalibData1] = calibfirprobe1(ProbeData1,ProbeData2,L,ATT,NFFT,Disp)
%
%   FILE NAME   : CALIB FIR PROBE 1
%   DESCRIPTION : First step of probe calibration procedure used to 
%                 generates a linear phase FIR inverse filter impulse
%                 response for given input / output calibration data.
%                 For this FIR filter it is not necessary to assign a 
%                 desired spectral resolution. It will be detirmined 
%                 automatically from L and ATT. Similar to CALIBFIR but 
%                 used for probe tube calibrations. In step two, you will
%                 need to run CALIBFIRPROBE2
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
%       f1      : Lower frequency (Hz)
%       f2      : Maximum frequency (Hz)
%       L       : Number of filter coefficients
%       ATT     : Sidelobe error for kaiser window (dB)
%       NFFT    : FFT Size for spectral estimates (Default, NFFT=1024*4)
%       Disp    : Display output - 'y' or 'n' (Default, 'n')
%
%RETURNED DATA
%
%       CalibData1  : Data structure containng the calibration resulst for
%                     step 1     
%                     .h1inv    - Impulse response of inverse calibration
%                                 filter at tube end
%                     .Gain1    - Gain applied to h1inv so that amplitude
%                                 does not exceed 8 Vpp
%                     .h2inv    - Impulse response of inverse calibration
%                                 filter at probe end
%                     .Gain2    - Gain applied to h2inv so that amplitude
%                                 does not exceed 8 Vpp
%                     .hprobeinv- Inverse impulse response of the probe
%                     .H1       - Transfer function at point 1
%                     .H2       - Transfer function at point 2
%                     .H1inv    - Inverse transfer function at point 1
%                     .H2inv    - Inverse transfer function at point 2
%                     .Hprobe   - Probe tube forward transfer function ("probe loss function")
%                     .P1yy     - Spectrum at point 1
%                     .P1xx     - Input spectrum
%                     .P1yx     - Cross spectrum between input and point 1
%                     .P2yy     - Spectrum at point 2
%                     .P2xx     - Input spectrum
%                     .P2yx     - Cross spectrum between input and point 2
%                     .F        - Frequency axis (Hz)
%                     .NFFT     - FFT Size
%
%(C) Monty A. Escabi, Aug 2010
%
function [CalibData1] = calibfirprobe1(ProbeData1,ProbeData2,f1,f2,L,ATT,NFFT,Disp)

%Input Arguments
if nargin<6 | isempty(ATT)
    ATT=100;
end
if nargin<7 | isempty(NFFT)
    NFFT=1024*4;
end
if nargin<8 | isempty(Disp)
    Disp='n';
end

%Converting Signals to Pascals, note X is in Volts and does not need
%to be converted to Pascals. Only Y is converted.
X1=ProbeData1.X;
X1=X1-mean(X1);
X2=ProbeData2.X;
X2=X2-mean(X2);
Y1=ProbeData1.Y.*1000./10^(ProbeData1.MicGain/20)/ProbeData1.MicSensitivity;
Y1=Y1-mean(Y1);
Y2=ProbeData2.Y.*1000./10^(ProbeData2.MicGain/20)/ProbeData2.MicSensitivity;
Y2=Y2-mean(Y2);
try
    Y1noise=ProbeData1.YRoomNoise.*1000./10^(ProbeData1.MicGain/20)/ProbeData1.MicSensitivity;
    Y1noise=Y1noise-mean(Y1noise);
    Y2noise=ProbeData2.YRoomNoise.*1000./10^(ProbeData2.MicGain/20)/ProbeData2.MicSensitivity;
    Y2noise=Y2noise-mean(Y2noise);
catch
end

%Generating Kaiser Window for Spectrum Calculations
[Beta,N,wc] = fdesignk(ATT,0.1*pi,pi/2);
W=kaiser(NFFT,Beta);

%Generating Speaker Transfer Functions
Fs=ProbeData1.Fs;
[P1,F]= spectrum(Y1,X1,NFFT,NFFT*7/8,W,ProbeData1.Fs);
P1yy=P1(:,1);
P1xx=P1(:,2);
P1yx=P1(:,3);
H1=P1yx./P1xx;
[P2,F]= spectrum(Y2,X2,NFFT,NFFT*7/8,W,ProbeData2.Fs);
P2yy=P2(:,1);
P2xx=P2(:,2);
P2yx=P2(:,3);
H2=P2yx./P2xx;
try
    [P1noise,F]= spectrum(Y1noise,NFFT,NFFT*7/8,W,ProbeData1.Fs);
    [P2noise,F]= spectrum(Y2noise,NFFT,NFFT*7/8,W,ProbeData2.Fs);
catch
end

%Generates the Inverse Filter Impulse Response
Hprobe=H2./H1;
W=(0:NFFT/2)/(NFFT/2)*pi;
% [B,A] = invfreqz(H2,W,0,L-length(Hband));
% CalibData1.h2inv=conv(A,Hband);                               %Inverse filter at probe end, used to "whiten" spectrum while animal is in place
% CalibData1.Gain2=8/max(abs(conv(CalibData1.h2inv,X1)));
% CalibData1.h2inv=CalibData1.Gain2*CalibData1.h2inv;           %Assures that output amplitude does not exceed +/- 8 Volts
% [B,A] = invfreqz(H1,W,0,L-length(Hband));
% CalibData1.h1inv=conv(A,Hband);                               %Inverse filter at tube end, used to "whiten" spectrum while animal is in place
% CalibData1.Gain1=8/max(abs(conv(CalibData1.h2inv,X1)));
% CalibData1.h1inv=CalibData1.Gain1*CalibData1.h1inv;           %Assures that output amplitude does not exceed +/- 8 Volts
[Hband] = bandpass(f1,f2,2500,Fs,25,'n');
[B,A] = invfreqz(H2,W,0,L-length(Hband));
CalibData1.h2inv=conv(A,Hband);                                 %Inverse filter at probe end, used to "whiten" spectrum while animal is in place
CalibData1.Gain2=8/max(abs(conv(CalibData1.h2inv,X1)));
CalibData1.h2inv=CalibData1.Gain2*CalibData1.h2inv;             %Assures that output amplitude does not exceed +/- 8 Volts
[B,A] = invfreqz(H1,W,0,L-length(Hband));
CalibData1.h1inv=conv(A,Hband);                                 %Inverse filter at tube end, used to "whiten" spectrum while animal is in place
CalibData1.Gain1=8/max(abs(conv(CalibData1.h1inv,X1)));
CalibData1.h1inv=CalibData1.Gain1*CalibData1.h1inv;             %Assures that output amplitude does not exceed +/- 8 Volts
%[B,A] = invfreqz(Hprobe,W,0,NFFT);                             %Feb 2016, MAE
%CalibData1.hprobeinv=fftshift(A);                              %Feb 2016, MAE; Inverse probe impulse response
Hp=[Hprobe ; conj(flipud(Hprobe(2:NFFT/2)))];                   %Feb 2016, above matrix inversion is ill conditioned
hp=fftshift(ifft(1./Hp));
WW=kaiser(floor(L/2)*2,5);
CalibData1.hprobeinv=hp(NFFT/2-floor(L/2):NFFT/2+floor(L/2)-1).*WW;     %Feb 2016, inverse FFT approach works much better

%Storing Transfer Function Results
CalibData1.H1=H1;
CalibData1.H2=H2;
CalibData1.H2inv=1./H2;
CalibData1.H1inv=1./H1;
CalibData1.Hprobe=Hprobe;
CalibData1.F=F;
CalibData.P1yy=P1yy;
CalibData.P1xx=P1xx;
CalibData.P1yx=P1yx;
CalibData.P2yy=P2yy;
CalibData.P2xx=P2xx;
CalibData.P2yx=P2yx;
try
    CalibData.P1noise=P1noise;
    CalibData.P2noise=P2noise;
end
CalibData1.NFFT=NFFT;

%Plotting Summary Data
Po=2.2E-5;          %Threshold of hearing in Pascals
if strcmp(Disp,'y')
    figure
    F=F/1000;
    subplot(221)
    plot(F,20*log10(abs(H1./Po)),'k')
    hold on
    plot(F,20*log10(abs(H2./Po)),'b')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('H1=BLACK, H2=BLUE')
    
    subplot(222)
    plot(F,20*log10(abs(H2./Po)),'k')
    hold on
    plot((0:NFFT-1)/NFFT*Fs/1000,20*log10(abs(fft(CalibData1.h2inv./Po,NFFT))),'r')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('Transfer function at point 2=BLACK, Inverse filter at point 2=RED')

    subplot(223)
    Offset=10*log10((872161/Fs).^2);
    %Offset=20;                                  %NEED TO CHECK
    plot(F,10*log10(P1yy/NFFT*2./Po.^2)+Offset,'k')
    hold on
    plot(F,10*log10(P2yy/NFFT*2./Po.^2)+Offset,'b')
    try 
        plot(F,10*log10(P2noise(:,1)/NFFT*2./Po.^2)+Offset,'b-.')
        plot(F,10*log10(P1noise(:,1)/NFFT*2./Po.^2)+Offset,'k-.')
    end
    hold off
    
    subplot(224)
    plot(F,20*log10(Hprobe))
    title('Probe Transfer Function')
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