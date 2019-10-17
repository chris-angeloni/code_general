%
%function [CalibData2] = calibfirprobe2(CalibData1,ProbeData3,L,f1,f2,ATT,NFFT,Disp)
%
%   FILE NAME   : CALIB FIR PROBE 2
%   DESCRIPTION : Second step of probe calibration procedure used to 
%                 generates a linear phase FIR inverse filter impulse
%                 response for given input / output calibration data.
%                 For this FIR filter it is not necessary to assign a 
%                 desired spectral resolution. It will be detirmined 
%                 automatically from L and ATT. Similar to CALIBFIR but 
%                 used for probe tube calibrations. 
%
%   CalibData1   : Structure containing results from CALIBFIRPROBE1
%                     .h2inv    - Impulse response of inverse calibration
%                                 filter at probe end
%                     .H1       - Transfer function at point 1
%                     .H2       - Transfer function at point 2
%                     .H2inv    - Inverse transfer function at point 2
%                     .Hprobe   - Probe tube forward transfer function ("probe loss function")
%                     .F        - Frequency axis (Hz)
%
%   ProbeData3   : Data structures containing calibration data. Obtained at
%                  probe end with animal in place.
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
%       CalibData2  : Data structure containng the calibration resulst for     
%                     .hinv     - Impulse response of inverse calibration
%                     .h1inv    - Impulse response of inverse calibration
%                                 filter at tube end
%                     .h2inv    - Impulse response of inverse calibration
%                                 filter at probe end
%                     .Gain     - Gain applied to hinv so that amplitude
%                                 does not exceed 8 Vpp
%                     .Gain1    - Gain applied to h1inv so that amplitude
%                                 does not exceed 8 Vpp
%                     .Gain2    - Gain applied to h2inv so that amplitude
%                                 does not exceed 8 Vpp
%                     .hprobeinv- Inverse impulse response of the probe
%                     .H        - Transfer function at point 1 with animal
%                                 in place
%                     .H1       - Transfer function at point 1
%                     .H2       - Transfer function at point 2
%                     .Hinv     - Transfer function of inverse calibration
%                                 filter with animal in place
%                     .H2inv    - Inverse transfer function at point 1
%                     .H2inv    - Inverse transfer function at point 2
%                     .Hprobe   - Probe tube forward transfer function ("probe loss function")
%                     .P1yy     - Spectrum at point 1
%                     .P1xx     - Input spectrum
%                     .P1yx     - Cross spectrum between input and point 1
%                     .P2yy     - Spectrum at point 2
%                     .P2xx     - Input spectrum
%                     .P2yx     - Cross spectrum between input and point 2
%                     .P3yy     - Spectrum at point 3
%                     .P3xx     - Input spectrum
%                     .P3yx     - Cross spectrum between input and point 3
%                     .F        - Frequency axis (Hz)
%                     .NFFT     - FFT Size
%
%(C) Monty A. Escabi, Aug 2010
%
function [CalibData2] = calibfirprobe2(CalibData1,ProbeData3,f1,f2,L,ATT,NFFT,Disp)

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

%Assigning Data to CalibData2
CalibData2=CalibData1;

%Converting Signals to Pascals, note X is in Volts and does not need
%to be converted to Pascals. Only Y is converted.
X3=ProbeData3.X;
X3=X3-mean(X3);
X3=conv(X3,CalibData1.h1inv);       %True input provided by TDT!!!
X3=X3(1:length(ProbeData3.X));
Y3=ProbeData3.Y.*1000./10^(ProbeData3.MicGain/20)/ProbeData3.MicSensitivity;
Y3=Y3-mean(Y3);
try
    Y3noise=ProbeData3.YRoomNoise.*1000./10^(ProbeData3.MicGain/20)/ProbeData3.MicSensitivity;
    Y3noise=Y3noise-mean(Y3noise);
catch
end

%Generating Kaiser Window for Spectrum Calculations
[Beta,N,wc] = fdesignk(ATT,0.1*pi,pi/2);
W=kaiser(NFFT,Beta);

%Generating Speaker Transfer Functions
Fs=ProbeData3.Fs;
[P3,F]= spectrum(Y3,X3,NFFT,NFFT*7/8,W,ProbeData3.Fs);
P3yy=P3(:,1);
P3xx=P3(:,2);
P3yx=P3(:,3);
try
    [P3noise,F]= spectrum(Y3noise,NFFT,NFFT*7/8,W,ProbeData3.Fs);
end

%Generates the Inverse Filter Impulse Response
Hprobe=CalibData1.Hprobe;
H1=CalibData1.H1;
H2=CalibData1.H2;
%%H3=P3yx./P3xx.*H2;    %Corerct for "whitening" of the spectrum by H2
H3=P3yx./P3xx;          %Corerct for "whitening" of the spectrum by H2 is done above using: X3=conv(X3,CalibData1.h2inv);
H=H3./Hprobe;           %Forward filter tranfer function at animals ear, corrected for probe. Inverse is taken by invfreqz!
W=(0:NFFT/2)/(NFFT/2)*pi;
[Hband] = bandpass(f1,f2,2500,Fs,30,'n');
[B,A] = invfreqz(H,W,0,L-length(Hband));
CalibData2.hinv=conv(A,Hband);
CalibData2.Gain=8/max(abs(conv(CalibData2.hinv,ProbeData3.X)));
CalibData2.hinv=CalibData2.Gain*CalibData2.hinv;  %Assures that output amplitude does not exceed +/- 8 Volts

%Storing Transfer Function Results
CalibData2.H3=H3;
CalibData2.H=H;         %Transfer function
CalibData2.Hinv=1./H;   %Inverse Transfer function

%Plotting Summary Data
Po=2.2E-5;          %Threshold of hearing in Pascals
if strcmp(Disp,'y')
    figure
    F=F/1000;
    subplot(221)
    plot(F,20*log10(abs(H1./Po)),'k')
    hold on
    plot(F,20*log10(abs(H2./Po)),'b')
    plot(F,20*log10(abs(H3./Po)),'r')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('H1=BLACK, H2=BLUE, H3=RED')
    
    subplot(222)
    plot(F,20*log10(abs(H./Po)),'k')
    hold on
    plot((0:NFFT-1)/NFFT*Fs/1000,20*log10(abs(fft(CalibData2.hinv./Po,NFFT))),'r')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('Transfer function=BLACK, Inverse filter=RED')
        
    subplot(223)
    Offset=10*log10((872161/Fs).^2);
    %Offset=20;                                  %NEED TO CHECK
    plot(F,10*log10(P3yy/NFFT*2./Po.^2)+Offset,'k')
    hold on
    try plot(F,10*log10(P3noise(:,1)/NFFT*2./Po.^2)+Offset,'k-.'); end
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