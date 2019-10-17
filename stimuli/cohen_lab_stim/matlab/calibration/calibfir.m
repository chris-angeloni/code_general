%
%function [h] = calibfir(Data,f1,f2,L,ATT,Disp)
%
%   FILE NAME   : CALIB FIR
%   DESCRIPTION : Generates a linear phase FIR inverse filter impulse
%                 response for given input / output calibration data
%                 For this FIR filter it is not necessary to assign a 
%                 desired spectral resolution. It will be detirmined 
%                 automatically from L and ATT
%
%   	Data    : Data structure containing:
%                 .X - input white noise signal
%                 .Y - recorder speaker output signal
%       f1      : Lower frequency (Hz)
%       f2      : Maximum frequency (Hz)
%       L       : Number of filter coefficients
%       ATT     : Filter sidelobe error, (Default 100 dB)
%       Disp    : Display output - 'y' or 'n' (Default, 'n')
%
%RETURNED DATA
%
%       h       : Filter impulse response data structure
%                 .hk   - digital impulse response
%                 .stdx - Standard deviation of input
%                 .stdy - Standard deviation of output
%
function [h] = calibfir(Data,f1,f2,L,ATT,Disp)

%Input Arguments
if nargin<5
    ATT=100;
end
if nargin<6
    Disp='n';
end

%Input / output data
X=Data.X;
Y=Data.Y;
Fs=Data.Fs;

%Generating Speaker Transfer Function
NFFT=1024*16;
[H] = calibcsd(Data,NFFT,ATT);

%Generates the Inverse Filter Impulse Response
Hz=H.Hz(1:NFFT/2+1);
W=(0:NFFT/2)/(NFFT/2)*pi;
[Hband] = bandpass(f1,f2,2500,Fs,40,'n');
[B,A] = invfreqz(Hz,W,0,L-length(Hband));
h.hk=conv(A,Hband);

%Resimulating System and Plotting Expected Results
Yp=conv(h.hk,Y);       %Predicted Calibrated Output
Yp=Yp(1:length(X));

%Designing Window
[Beta,N,wc] = fdesignk(ATT,0.1*pi,pi/2);
W=kaiser(NFFT,Beta);

%Plotting Summary Data
if strcmp(Disp,'y')

    %Computing Cross Spectral Density and Fitting With Straight Line
    [P,F]= spectrum(Y,X,NFFT,NFFT*7/8,W,Fs);
    Pyx=P(:,3);
    Pxx=P(:,2);
    Cyx=P(:,5);

    figure
    subplot(221)
    plot(F,Cyx)
    title('Coherence - Input vs. Output')
    
    subplot(222)
    %[Pyx,F]=csd(X,Y,NFFT,Fs/1000,W);
    %[Pxx,F]=psd(X,NFFT,Fs/1000,W);
    plot(F,20*log10(Pyx./Pxx))
    title('Cross Spectral Density - Input vs. Output')

     %Computing Cross Spectral Density and Fitting With Straight Line
    [P,F]= spectrum(Yp,X,NFFT,NFFT*7/8,W,Fs);
    Pyx=P(:,3);
    Pxx=P(:,2);
    Cyx=P(:,5);
    
    subplot(223)
    %cohere(X,Yp,1024*8,Fs/1000)
    plot(F,Cyx)
    title('Predicted Calibrated Coherence')

    subplot(224)
    %[Pyx,F]=csd(X,Yp,NFFT,Fs/1000,W);
    %[Pxx,F]=psd(X,NFFT,Fs/1000,W);
    plot(F,20*log10(Pyx./Pxx))
    title('Predicted Calibrated Transfer Function')
    
end