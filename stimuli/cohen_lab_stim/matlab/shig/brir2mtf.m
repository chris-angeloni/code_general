%
%function [BR]=brir2mtf(hl,hr,Fs,f1,f2,MaxFm,OF,Disp,ATT)
% 	
%   FILE NAME   : BRIR 2 MTF
% 	DESCRIPTION : Estimates the modulation transfer function from the BRIR.
%                 Estimate is obtrained for a frequency band between f1 and
%                 f2. 
%
%   hl, hr      : Left and right BRIR
%   Fs          : Sampling Rate (Hz)
%   f1,f2       : Lower and upper frequency for computing MTF (Hz)
%   OF          : Temporal oversampling factor (>1)
%	dis         : display (optional): 'log' or 'lin' or 'n'
%                 Default == 'n'
%	ATT         : Attenution / Sidelobe error in dB (Optional)
%                 Default == 60 dB
%
%RETURNED VARIABLES
%
%   BR          : Binaural Room Modulation Transfer Function Data Structure.
%                 Contains the following:
%
%                 .hel      - Envelope impulse respose (left)
%                 .her      - Envelope impulse response (right)
%                 .MTFl     - Binaural room MTF (left). 
%                 .MTFr     - Binuaral room MTF (right). 
%                 .FmAxis   - Modulation Freq. Axis
%
% (C) Monty A. Escabi, October 2011
%
function [BR]=brir2mtf(hl,hr,Fs,f1,f2,MaxFm,OF,Disp,ATT)

%Input Parameters
if nargin<10
	Disp='n';
end
if nargin<11
	ATT=60;
end

%Generating Spectrotemporal BRIR 
ATT=40;
x=randn(1,Fs*25);

%Filtering the signal by the BRIR and subsequent bandpass filtering
TW=.1*(f2-f1)/2;
hb=bandpass(f1,f2,TW,Fs,40,'n');
yl=conv(convfft(x,hl,0),hb);
yr=conv(convfft(x,hr,0),hb);
yl=yl(1:length(x)+length(hb)+length(hl)-1);
yr=yr(1:length(x)+length(hb)+length(hr)-1);
yb=conv(x,hb);

%Computing Envelopes, Bandlimit and Downsample
DF=ceil(Fs/MaxFm/2/OF);
El=resample(abs(hilbert(yl)),1,DF);
Er=resample(abs(hilbert(yr)),1,DF);
Eb=resample(abs(hilbert(yb)),1,DF);

%Estimating Modulation Impulse Response
dt=inv(Fs/DF);
L=2^nextpow2((length(hb)+length(hl))/Fs/dt);
[BR.hel] = wienerfft(Eb/std(Eb),El/std(El),5,100);
[BR.her] = wienerfft(Eb/std(Eb),Er/std(Er),5,100);

%Generating MTF
NFFTt=max(2^(1+nextpow2(length(BR.hel))),1024);;
BR.MTFl=abs(fftshift(fft(BR.hel,NFFTt)));
BR.MTFr=abs(fftshift(fft(BR.her,NFFTt)));
Max=max(abs([BR.MTFr BR.MTFl]));
BR.MTFl=BR.MTFl/Max;      %Normalizing for maximum Gain of 0 dB
BR.MTFr=BR.MTFr/Max;      %Normalizing for maximum Gain of 0 dB
BR.El=El;
BR.Er=Er;
BR.Eb=Eb;

%Mod Frequency Axis and time axis
BR.FmAxis=(-NFFTt/2-.5:NFFTt/2-1)/NFFTt/dt;
BR.taxis=(0:L-1)*dt;
BR.Fs=Fs/DF;