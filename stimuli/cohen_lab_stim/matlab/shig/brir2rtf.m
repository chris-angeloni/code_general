%
%function [BR]=brir2rtf(hl,hr,Fs,f1,f2,dX,MaxFm,OF,Disp)
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
%   Disp        : Display output (Default=='y')
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
% (C) Monty A. Escabi, January 2008
%
function [BR]=brir2rtf(hl,hr,Fs,f1,f2,dX,MaxFm,OF,Disp)

%Generating Spectrotemporal BRIR 
ATT=40;
[taxis,faxis,stBRIRl,Sfl]=audiogram(hl,Fs,dX,f1,f2,MaxFm,OF,'log',ATT);
[taxis,faxis,stBRIRr,Sfr]=audiogram(hr,Fs,dX,f1,f2,MaxFm,OF,'log',ATT);
Max=max(max([stBRIRl stBRIRr]));
BR.stIRl=stBRIRl/Max;
BR.stIRr=stBRIRr/Max;
BR.Sfl=Sfl;
BR.Sfr=Sfr;

%Spectral and Temporal Resoultion
dt=taxis(2)-taxis(1);
dX=log2(faxis(2)/faxis(1));

%FFT Size for estimating BRRTF
NFFTt=2^(1+nextpow2(size(BR.stIRl,2)));
NFFTf=2^(1+nextpow2(size(BR.stIRl,1)));

%Generating BRRTF
%BRRTFl=abs(fftshift(fft2(stBRIRl-mean(mean(stBRIRl)),NFFTf,NFFTt)));
%BRRTFr=abs(fftshift(fft2(stBRIRr-mean(mean(stBRIRr)),NFFTf,NFFTt)));
BRRTFl=abs(fftshift(fft2(stBRIRl,NFFTf,NFFTt)));
BRRTFr=abs(fftshift(fft2(stBRIRr,NFFTf,NFFTt)));
Max=max(max(abs([BRRTFr BRRTFl])));
BR.RTFl=BRRTFl/Max;      %Normalizing for maximum Gain of 0 dB
BR.RTFr=BRRTFr/Max;      %Normalizing for maximum Gain of 0 dB

%Band Normalized BR MTF
for k=1:size(stBRIRl,1)
    %Sl(k,:)=stBRIRl(k,:)/sum(stBRIRl(k,:));
    %Sr(k,:)=stBRIRr(k,:)/sum(stBRIRr(k,:));
    Sl(k,:)=stBRIRl(k,:)/BR.Sfl(k);
    Sr(k,:)=stBRIRr(k,:)/BR.Sfr(k);
end
BR.MTFl=abs(fftshift(fft(Sl',NFFTt)',2));
BR.MTFr=abs(fftshift(fft(Sr',NFFTt)',2));

%Generating sBRMTF
%sBRMTFl=abs(fftshift(fft(stBRIRl'-mean(mean(stBRIRl)),NFFTt)',2));
%sBRMTFr=abs(fftshift(fft(stBRIRr'-mean(mean(stBRIRr)),NFFTt)',2));
sBRMTFl=abs(fftshift(fft(stBRIRl',NFFTt)',2));
sBRMTFr=abs(fftshift(fft(stBRIRr',NFFTt)',2));
Max=max(max(abs([sBRMTFr sBRMTFl])));
BR.sMTFl=sBRMTFl/Max;    %Normalizing for maximum Gain of 0 dB
BR.sMTFr=sBRMTFr/Max;    %Normalizing for maximum Gain of 0 dB

%Ripple Density and Mod Frequency Axis
BR.FmAxis=(-NFFTt/2-.5:NFFTt/2-1)/NFFTt/dt;
BR.RDAxis=(-NFFTf/2-.5:NFFTf/2-1)/NFFTf/dX;

%Time and Frequency Axis
BR.taxis=taxis;
BR.faxis=faxis;

%Displaying Output if Desired
if Disp=='y'

    figure
    subplot(231)
    imagesc(BR.taxis,log2(BR.faxis/faxis(1)),20*log10(BR.stIRl)),set(gca,'YDir','normal')
    caxis([-50 0])
    axis([0 .05 0 log2(max(faxis)/faxis(1))])
    title('Left BR-Spectrotemporal IR')
    xlabel('Time (sec)')
    ylabel('Octave Frequency')
    colorbar
    hold on
    plot((0:length(hl)-1)/Fs,(hl-min(hl))/(max(hl)-min(hl)),'k')

    subplot(232)
    imagesc(BR.FmAxis,log2(BR.faxis/BR.faxis(1)),20*log10(abs(BR.sMTFl))),set(gca,'YDir','normal'),hold on
    contour(BR.FmAxis,log2(BR.faxis/BR.faxis(1)),20*log10(abs(BR.sMTFl)),-20*[1 1],'k')
    caxis([-50 0])
    axis([-MaxFm MaxFm 0 log2(max(faxis)/faxis(1))])
    xlabel('Modulation Freq. (Hz)')
    ylabel('Octave Freq.')
    title('Left BR-Spectal MTF')
    colorbar
    
    subplot(233)
    imagesc(BR.FmAxis,BR.RDAxis,20*log10(abs(BR.RTFl))),set(gca,'YDir','normal'),hold on
    contour(BR.FmAxis,BR.RDAxis,20*log10(abs(BR.RTFl)),-20*[1 1],'k')
    caxis([-50 0])
    axis([-MaxFm MaxFm -2 2])
    xlabel('Modulation Freq. (Hz)')
    ylabel('Ripple Density (cyc/oct)')
    title('Left BR-RTF')
    colorbar
     
    subplot(234)
    imagesc(BR.taxis,log2(BR.faxis/faxis(1)),20*log10(BR.stIRr)),set(gca,'YDir','normal')
    caxis([-50 0])
    axis([0 .05 0 log2(max(faxis)/faxis(1))])
    title('Right BR-Spectrotemporal IR')
    xlabel('Time (sec)')
    ylabel('Octave Frequency')
    colorbar
    hold on
    plot((0:length(hr)-1)/Fs,(hr-min(hr))/(max(hr)-min(hr)),'k')

    subplot(235)
    imagesc(BR.FmAxis,log2(BR.faxis/BR.faxis(1)),20*log10(abs(BR.sMTFr))),set(gca,'YDir','normal'),hold on
    contour(BR.FmAxis,log2(BR.faxis/BR.faxis(1)),20*log10(abs(BR.sMTFr)),-20*[1 1],'k')
    caxis([-50 0])
    axis([-MaxFm MaxFm 0 log2(max(faxis)/faxis(1))])
    xlabel('Modulation Freq. (Hz)')
    ylabel('Octave Freq.')
    title('Right BR-Spectral MTF')
    colorbar
    
    subplot(236)
    imagesc(BR.FmAxis,BR.RDAxis,20*log10(abs(BR.RTFr))),set(gca,'YDir','normal'),hold on
    contour(BR.FmAxis,BR.RDAxis,20*log10(abs(BR.RTFr)),-20*[1 1],'k')
    caxis([-50 0])
    axis([-MaxFm MaxFm -2 2])
    xlabel('Modulation Freq. (Hz)')
    ylabel('Ripple Density (cyc/oct)')
    title('Right BR-RTF')
    colorbar

end