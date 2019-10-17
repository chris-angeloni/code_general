%
%function [CalibData] = calibfirprobe(ProbeData1,ProbeData2,ProbeData3,f1,f2,L,ATT,NFFT,Disp)
%
%   FILE NAME   : CALIB FIR PROBE
%   DESCRIPTION : Generates a linear phase FIR inverse filter impulse
%                 response for given input / output calibration data.
%                 For this FIR filter it is not necessary to assign a 
%                 desired spectral resolution. It will be detirmined 
%                 automatically from L and ATT. Similar to CALIBFIR but 
%                 used for probe tube calibrations.
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
%                     .H1       - Transfer function at point 1
%                     .H2       - Transfer function at point 2
%                     .H3       - Trasfer function at point 2 with animial
%                                 in place
%                     .H        - Forward transfer function with animal in
%                                 place
%                     .Hinv     - Inverse filter transfer function (1/H)
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
function [CalibData] = calibfirprobe(ProbeData1,ProbeData2,ProbeData3,f1,f2,L,ATT,NFFT,Disp)

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
X1=ProbeData1.X;
X1=X1-mean(X1);
X2=ProbeData2.X;
X2=X2-mean(X2);
X3=ProbeData3.X;
X3=X3-mean(X3);
Y1=ProbeData1.Y.*1000./10^(ProbeData1.MicGain/20)/ProbeData1.MicSensitivity;
Y1=Y1-mean(Y1);
Y2=ProbeData2.Y.*1000./10^(ProbeData2.MicGain/20)/ProbeData2.MicSensitivity;
Y2=Y2-mean(Y2);
Y3=ProbeData3.Y.*1000./10^(ProbeData3.MicGain/20)/ProbeData3.MicSensitivity;
Y3=Y3-mean(Y3);
try 
    Y1noise=ProbeData1.YRoomNoise.*1000./10^(ProbeData1.MicGain/20)/ProbeData1.MicSensitivity;
    Y1noise=Y1noise-mean(Y1noise);
    Y2noise=ProbeData2.YRoomNoise.*1000./10^(ProbeData2.MicGain/20)/ProbeData2.MicSensitivity;
    Y2noise=Y2noise-mean(Y2noise);
    Y3noise=ProbeData3.YRoomNoise.*1000./10^(ProbeData3.MicGain/20)/ProbeData3.MicSensitivity;
    Y3noise=Y3noise-mean(Y3noise);
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
[P3,F]= spectrum(Y3,X3,NFFT,NFFT*7/8,W,ProbeData3.Fs);
P3yy=P3(:,1);
P3xx=P3(:,2);
P3yx=P3(:,3);
H3=P3yx./P3xx;
try 
    [P1noise,F]= spectrum(Y1noise,NFFT,NFFT*7/8,W,ProbeData1.Fs);
    [P2noise,F]= spectrum(Y2noise,NFFT,NFFT*7/8,W,ProbeData2.Fs);
    [P3noise,F]= spectrum(Y3noise,NFFT,NFFT*7/8,W,ProbeData3.Fs);
end

%Generates the Inverse Filter Impulse Response
Hprobe=H2./H1;
H=H3./Hprobe;   %Forward transfer function, NOT the inverse, FREQZ inverts!
W=(0:NFFT/2)/(NFFT/2)*pi;
[Hband] = bandpass(f1,f2,1500,Fs,40,'n');
[B,A] = invfreqz(H,W,0,L-length(Hband));
CalibData.hinv=conv(A,Hband);
CalibData.Gain=8/max(abs(conv(CalibData.hinv,X1)));
CalibData.hinv=CalibData.Gain*CalibData.hinv;     %Assures that output amplitude does not exceed +/- 8 Volts

%Storing Transfer Function Results
CalibData.H1=H1;
CalibData.H2=H2;
CalibData.H3=H3;
CalibData.H=H;
CalibData.Hinv=1./H;
CalibData.Hprobe=Hprobe;
CalibData.P1yy=P1yy;
CalibData.P1xx=P1xx;
CalibData.P1yx=P1yx;
CalibData.P2yy=P2yy;
CalibData.P2xx=P2xx;
CalibData.P2yx=P2yx;
CalibData.P3yy=P3yy;
CalibData.P3xx=P3xx;
CalibData.P3yx=P3yx;
try
    CalibData.P1noise=P1noise;
    CalibData.P2noise=P2noise;
    CalibData.P3noise=P3noise;
end
CalibData.F=F;
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
    plot(F,20*log10(abs(H3./Po)),'r')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('H1=black, H2=blue, H3=red')
    
    subplot(222)
    plot(F,20*log10(abs(H./Po)),'k')
    hold on
    plot((0:NFFT-1)/NFFT*Fs/1000,20*log10(abs(fft(CalibData.hinv./Po,NFFT))),'r')
    xlim([0 max(F)])
    xlabel('Freq. (kHz)')
    title('Transfer function=BLACK, Inverse filter=RED')

    subplot(223)
    Offset=10*log10((872161/Fs).^2);
    %Offset=20;                                  %NEED TO CHECK
    plot(F,10*log10(P1yy/NFFT*2./Po.^2)+Offset,'k')
    hold on
    plot(F,10*log10(P2yy/NFFT*2./Po.^2)+Offset,'b')
    plot(F,10*log10(P3yy/NFFT*2./Po.^2)+Offset,'r')
    try
        plot(F,10*log10(P1noise(:,1)/NFFT*2./Po.^2)+Offset,'k-.')
        plot(F,10*log10(P2noise(:,1)/NFFT*2./Po.^2)+Offset,'b-.')
        plot(F,10*log10(P3noise(:,1)/NFFT*2./Po.^2)+Offset,'r-.')
        hold off
    end
    
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