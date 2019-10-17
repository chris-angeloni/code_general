%
%function [BR]=brir2stbrir(hl,hr,Fs,f1,f2,dX,MaxFm,OF,Norm,Disp,ATT)
% 	
%   FILE NAME   : BRIR 2 RTF
% 	DESCRIPTION : Converts a binaural room impulse response to a ripple
%                 transfer function.
%
%   hl, hr      : Left and right BRIR
%   Fs          : Sampling Rate (Hz)
%   f1,f2       : Lower and upper audiogram frequency
%   dX          : Spectral resolution (in octaves) for auditory filter bank
%   MaxFm       : Maximum modulation frequency (Hz)
%   OF          : Temporal oversampling factor (>1)
%   Norm        : Amplitude normalization (Optional)
%                 En:  Equal Energy (Default)
%                 Amp: Equal Amplitude
%	dis         : display (optional): 'log' or 'lin' or 'n'
%                 Default == 'n'
%	ATT         : Attenution / Sidelobe error in dB (Optional)
%                 Default == 60 dB
%
%RETURNED VARIABLES
%
%   BR          : Binaural Room Ripple Transfer Function Data Structure.
%                 Contains the following:
%
%                 .stIRl    - Spectrotemporal BRIR (left)
%                 .stIRr    - Spectrotemporal BRIR (right)
%                 .Sfl      - Spectral BRIR envelope (left)
%                 .Sfr      - Spectral BRIR envelope (right)
%                 .RTFl     - Binaural room RTF (left)
%                 .RTFr     - Binaural room RTF (left)
%                 .sMTFl    - Spectral Binaural room MTF (left)
%                 .sMTFr    - Spectral Binuaral room MTF (right)
%                 .MTFl     - Binaural room MTF (left). Note that unlike
%                             sMTFl, spectral modulations are now removed
%                 .MTFr     - Binuaral room MTF (right). Note that unlike
%                             sMTFr, spectral modulations are now removed
%                 .FmAxis   - Modulation Freq. Axis
%                 .RDAxis   - Ripple Density Axis
%                 .taxis    - Time Axis
%                 .faxis    - Frequency Axis
%
% (C) Monty A. Escabi, January 2008 (Edit Nov 2009)
%
function [BR]=brir2stbrir(hl,hr,Fs,f1,f2,dX,MaxFm,OF,Norm,Disp,ATT)

%Input Parameters
if nargin<9
    Norm='En';
end
if nargin<10
	Disp='n';
end
if nargin<11
	ATT=60;
end

%Generating Spectrotemporal BRIR 
ATT=40;
x=randn(1,Fs*10);
%[x]=chirpwindowed(20,f2,Fs*2,Fs/2,3,5,'log');

yl=conv(x,hl);
yr=conv(x,hr);
[AudDataX]=audiogram(x,Fs,dX,f1,f2,MaxFm,OF,'log','n',ATT);
[AudDataYr]=audiogram(yr,Fs,dX,f1,f2,MaxFm,OF,'log','n',ATT);
[AudDataYl]=audiogram(yl,Fs,dX,f1,f2,MaxFm,OF,'log','n',ATT);

%Extracting Spectrotemporal Signals
X=AudDataX.S;
Yr=AudDataYr.S;
Yl=AudDataYl.S;
Sfr=AudDataYr.Sf;
Sfl=AudDataYl.Sf;
taxis=AudDataX.taxis;
faxis=AudDataX.faxis;
dt=taxis(2)-taxis(1);
dX=log2(faxis(2))-log2(faxis(1));
N=size(X,1);

%Computing BR Spectrotemporal Impulse Responses
L=2^nextpow2(length(hl)/Fs/taxis(2))
for k=1:N
    clc
    disp([num2str(k/N*100,2) ' % Done'])
    %[stBRIRr(k,:)] = wiener(X(k,:)/std(X(k,:)),Yr(k,:)/std(Yr(k,:)),5,L);
    %[stBRIRl(k,:)] = wiener(X(k,:)/std(X(k,:)),Yl(k,:)/std(Yl(k,:)),5,L);
    [stBRIRr(k,:)] = wienerfft(X(k,:)/std(X(k,:)),Yr(k,:)/std(X(k,:)),5,L);
    [stBRIRl(k,:)] = wienerfft(X(k,:)/std(X(k,:)),Yl(k,:)/std(X(k,:)),5,L);
end

%FFT Size for estimating BRRTF
NFFTt=2^(1+nextpow2(size(stBRIRl,2)));
NFFTf=2^(1+nextpow2(size(stBRIRl,1)));

%Generating BRRTF
BRRTFl=abs(fftshift(fft2(stBRIRl,NFFTf,NFFTt)));
BRRTFr=abs(fftshift(fft2(stBRIRr,NFFTf,NFFTt)));
Max=max(max(abs([BRRTFr BRRTFl])));
BR.RTFl=BRRTFl/Max;      %Normalizing for maximum Gain of 0 dB
BR.RTFr=BRRTFr/Max;      %Normalizing for maximum Gain of 0 dB

%Band Normalized BR MTF
for k=1:size(stBRIRl,1)
    %Sl(k,:)=stBRIRl(k,:)/sum(stBRIRl(k,:));
    %Sr(k,:)=stBRIRr(k,:)/sum(stBRIRr(k,:));
    Sl(k,:)=stBRIRl(k,:)/Sfl(k);
    Sr(k,:)=stBRIRr(k,:)/Sfr(k);
end
BR.MTFl=abs(fftshift(fft(Sl',NFFTt)',2));
BR.MTFr=abs(fftshift(fft(Sr',NFFTt)',2));

%Generating sBRMTF
sBRMTFl=abs(fftshift(fft(stBRIRl',NFFTt)',2));
sBRMTFr=abs(fftshift(fft(stBRIRr',NFFTt)',2));
Max=max(max(abs([sBRMTFr sBRMTFl])));
BR.sMTFl=sBRMTFl/Max;    %Normalizing for maximum Gain of 0 dB
BR.sMTFr=sBRMTFr/Max;    %Normalizing for maximum Gain of 0 dB

%Ripple Density and Mod Frequency Axis
BR.FmAxis=(-NFFTt/2-.5:NFFTt/2-1)/NFFTt/dt;
BR.RDAxis=(-NFFTf/2-.5:NFFTf/2-1)/NFFTf/dX;

%Data Structure
BR.taxis=(0:L-1)*dt;
BR.faxis=AudDataX.faxis;
BR.stBRIRr=stBRIRr;
BR.stBRIRl=stBRIRl;
BR.Sfl=Sfl;
BR.Sfr=Sfr;