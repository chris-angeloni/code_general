%
%function [RFParam]=strfparam(taxis,faxis,STRF,Wo,PP,Sound,MaxFm,MaxRD,Thresh,alpha1,alpha2,Disp)
%
%   FILE NAME       : STRF PARAM
%   DESCRIPTION     : Computes temporal and spectral STRF parameters from 
%                     the statistically significant STRF
%	
%       taxis       : Time Axis (sec)
%       faxis       : Frequency Axis (Hz)
%       STRF        : Spectrotemporal receptive field (thresholded 
%                     statistically significant, see wstrfstat)
%       Wo          : Zeroth Order Kernel ( Number of Spikes / Sec )
%       PP          : Sound Modulation Power Level (dB^2)
%       Sound       : Sound Type 
%                     Moving Ripple : 'MR' ( Default )
%                     Ripple Noise  : 'RN'
%       MaxFM       : Maximum Modulation Rate (Default = 500 Hz)
%       MaxRD       : Maximum Ripple Density (Default = 4 cyc/oct)
%       Thresh      : Fraction of Maximum for second response peak
%                     Two Best RD and FM are choosen if the second
%                     maximum achieves the value Tresh*max(max(RTF))
%                     where Tresh E [0 1] (Optional, Default=0.5)
%                     Look at RTFPARAM for details.
%       alpha1      : Threshold value for computing Duration, BW, BF 
%                     parameters from Pf and Pt (Default==0.05)
%       alpha2      : Threshold value for computing cSMF and cTMF. Values 
%                     below alpha are not considered (Default==0.1). See 
%                     RTFPARAM for details.
%       Disp        : Display Output Results (Optional, 'y' or 'n', 
%                     Default=='n')
%
%RETURNED PARAMETERS
%
%	RFParam (Data structure containing STRF parameters)
%       .Delay      : Group delay (msec). Obtained by computing
%                     average hibert transform on STRF and 
%                     using it as a distribution function, Pt.
%                     The delay is computed as the mean of Pt.
%       .Duration   : Temporal duration (msec). Obtained by
%                     computing 2 * std of Pt.
%       .BF         : Best frequency (Octaves). Obtained by
%                     computing the average hilbert transform
%                     on the STRF and using it as spectral
%                     distribution function, Pf. The BF is
%                     obtained as the mean of Pf.
%       .BFHz       : Best frequency (in Hz). Obtained by
%                     computing the average hilbert transform
%                     on the STRF and using it as spectral
%                     distribution function, Pf. The BF is
%                     obtained as the mean of Pf.
%       .BW         : Spectral Bandwidth (Octaves). Obtained by
%                     computing 2*std of Pf.
%       .BWHz       : Spectral Bandwidth (in Hz). Obtained by
%                     computing 2*std of Pf.
%       .PeakDelay  : Temporal delay at STRF Peak(msec) 
%       .PeakBF     : Best frequency at STRF Peak (Octaves)
%   .PeakEnvDelay   : Delay measurement obtained by taking the
%                     peak of the temporal Envelope, Pt.
%       .PeakEnvBF  : BF measuremenet obtained by taking the
%                     peak of the spectral envelope, Pf.
%  .HalfEnvDuration : Envelope Duration measured at 50% of the max Pt
%       .t1_50      : Temporal envelope lower 50% crossover point
%       .t2_50      : Temporal envelope upper 50% crossover point
%       .Duration10 : Envelope duration measured at 10% from peak
%       .t1_10      : Temporal envelope lower 10% crossover point
%       .t2_10      : Temporal envelope upper 10% crossover point
%       .EnvBW10    : Envelope BW obtained at 10% relative to peak
%       .XL10       : Lower cutoff at 10% amplitude relative to peak
%       .XU10       : Upper cutoff at 10% amplitude relative to peak
%       .HalfEnvBW  : Envelope BW obtained by measuring the 1/2
%                     power boundaries of Pf - Note that HalfEnveBW = X2-X1
%       .X1         : 3dB Lower Cutoff (octaves) 
%       .X2         : 3dB Upper Cutoff (octaves)
%       .BestFm     : Best Modulation Rate - Returns 2 values if second 
%                     quadrant exceeds desired threshold value
%       .BestRD     : Best Ripple Density - Returns 2 values if second 
%                     quadrant exceeds desired threshold value
%       .bTMF       : Best Temporal Modulation Frequency (Optained by averaging
%                     RTF quandrants ala Milller 2001)
%       .bSMF       : Best Spectral Modulation Frequency (Optained by averaging
%                     RTF quandrants ala Milller 2001)
%       .cTMF       : Temporal Modulation Frequency Centroid (Optained by
%                     averaging RTF quandrants ala Milller 2001). Signals 
%                     below alpha2 % of max are not used in the estimate.
%       .cSMF       : Spectral Modulation Frequency Centroid (Optained by
%                     averaging RTF quandrants ala Milller 2001). Signals 
%                     below alpha2 % of max are not used in the estimate.
%       .bwSMF      : Spectral MTF bandwidth, Measured using standard deviation
%                     of sMTF. Signals below alpha2 % of max are not used in 
%                     the estimate.
%       .bwTMF      : Tpectral MTF bandwidth, Measured using standard deviation
%                     of tMTF. Signals below alpha2 % of max are not used in 
%                     the estimate.
%.FmUpperCutoff     : Temporal Modulation Frequency Upper Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%.FmLowerCutoff     : Temporal Modulation Frequency Lower Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%.RDUpperCutoff     : Spectral Modulation Frequency Upper Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%.RDLowerCutoff     : Spectral Modulation Frequency Lower Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%       .DSI        : Direction selectivity index, DSI=(P1-P2)/(P1+P2) where P1 and
%                     P2 are the powers in the 1st and 2nd ripple transfer function
%                     quadrants, respectively.
%       .Max        : Peak Response values from Ripple density plot
%
%       .Pt         : Temporal envelope, derived from hilbert
%                     transform on STRF 
%       .Pf         : Spectral envelope, derived from hilbert
%                     transform on STRF
%       .PLI        : Phase Locking index used in Escabi & Schreiner 2002
%       .PLI2       : Phase locking index defined as:
%
%                        PLI2=STRF Output Energy / Spike Rate
%       .STRFStd    : STRF Energy (spikes/sec)
%       .tMTF       : Temporal modualtion transfer function (normalized power density) 
%       .sMTF       : Spectral modualtion transfer function (normalized power density) 
%       .Fm         : Tmeporal Modulation Frequency Axis (Hz)
%       .RD         : Spectral Modualtion Frequency Axis (cycles/oct)
%
% (C) Monty A. Escabi, December 2005 (Edit May 2014; errors identified by Areck; Added IER)
%                                    (Edit March 2015: added tMTF and sMTF, see rtfparam
%                                       Also added periodic extension for Pf and Pt 
%                                     Oct 2015 - fixed taxis normalization when taxis<0 )
%
function [RFParam]=strfparam(taxis,faxis,STRF,Wo,PP,Sound,MaxFm,MaxRD,Thresh,alpha1,alpha2,Disp)

%Input Arguments
if nargin<6
    Sound='MR';
end
if nargin<7
    MaxFm=500;
end
if nargin<8
    MaxRD=4;
end
if nargin<9
    Thresh=0.5;   %Half Power Threshold 
end
if nargin<10
    alpha1=0.05;
end
if nargin<11
    alpha2=0.1;
end
if nargin<12
    Disp='n';
end

%Finding Ripple Transfer Function & Parameters
[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,'n');
[TFParam]=rtfparam(Fm,RD,RTF,Thresh,alpha2,Disp);
RFParam=TFParam;
RFParam.RTF=RTF;

%Normalizing Time and Frequency Axis
%taxis=1000*(taxis-min(taxis));
taxis=1000*taxis;                   %MAE, Oct 2015
X=log2(faxis/faxis(1));

%Finding BF and Peak Delay
dX=log2(faxis(2))-log2(faxis(1));
dt=taxis(2)-taxis(1);
[i,j]=find(max(max(abs(STRF)))==abs(STRF));
RFParam.PeakDelay=taxis(j);
RFParam.PeakBF=X(i);

%Finding Half Width and Peak Envelope Delay
Nt=size(STRF,2);
Ht=hilbert([fliplr(STRF) STRF fliplr(STRF)]')';                              %Periodic extension, avoids edge artifacts (3/15, MAE)
Ht=Ht(:,Nt+1:2*Nt);
%Pt=mean(abs(Ht));
%Pt=Pt.^2/sum(Pt.^2);        %Assumes Power Distribution, e.g. see Cohen
Pt=mean(abs(Ht).^2);        %Changed to Mean-square, mathematically correct, Nov. 13, 2007
Pt=Pt/sum(Pt);
i=min(find(Pt==max(Pt)));
RFParam.PeakEnvDelay=taxis(i);
i1=max([1 max([find(taxis<=RFParam.PeakEnvDelay & Pt<0.5*max(Pt))])]);
i2=min([length(taxis) min(find(taxis>RFParam.PeakEnvDelay & Pt<0.5*max(Pt)))]);
t1_50=interp1([Pt(i1+1) Pt(i1)]/max(Pt),taxis([i1+1 i1]),0.5);                 %0.5 Amplitude crossing
t2_50=interp1([Pt(i2) Pt(i2-1)]/max(Pt),taxis([i2 i2-1]),0.5);                 %0.5 Amplitude crosssing
RFParam.HalfEnvDuration=t2_50-t1_50;                                           %Half Duration
RFParam.t1_50=t1_50;
RFParam.t2_50=t2_50;
RFParam.Pt=Pt;

%Finding Duration at 10% of Max Envelope
i1=max([1 max([find(taxis<=RFParam.PeakEnvDelay & Pt<0.1*max(Pt))])]);
i2=min([length(taxis) min(find(taxis>RFParam.PeakEnvDelay & Pt<0.1*max(Pt)))]);
t1_10=interp1([Pt(i1+1) Pt(i1)]/max(Pt),taxis([i1+1 i1]),0.1);                 %0.1 Amplitude crossing
t2_10=interp1([Pt(i2) Pt(i2-1)]/max(Pt),taxis([i2 i2-1]),0.1);                 %0.1 Amplitude crosssing
RFParam.Duration10=t2_10-t1_10;                                                %Duration at 10 of peak
RFParam.t1_10=t1_10;
RFParam.t2_10=t2_10;

%Finding Temporal Duration and group delay - Values below alpha1 are not
%used - this removes long noise tail wich biases duration and delay
%estimates
i=1:min([find(taxis>RFParam.PeakEnvDelay & Pt<alpha1*max(Pt)) length(Pt)]);
Ptn=Pt(i)/sum(Pt(i));                                                       %Normalized and truncated temporal distribution
RFParam.Delay=sum(taxis(i).*Ptn);
RFParam.Duration=2*sqrt(sum((taxis(i)-RFParam.Delay).^2.*Ptn));

%Finding Spectral Envelope Half BW and Peak Envelope BF 
Nf=size(STRF,1);
Hf=hilbert([flipud(STRF); STRF; flipud(STRF)]);                             %Periodic extension, avoids edge artifacts (3/15, MAE)
Hf=Hf(Nf+1:2*Nf,:);
%Pf=mean(abs(Hf'));
%Pf=Pf.^2/sum(Pf.^2);        %Assumes Power Distribution, e.g. see Cohen
Pf=mean(abs(Hf').^2);        %Changed to Mean-square, mathematically correct, Nov. 13, 2007
Pf=Pf/sum(Pf);
i=min(find(Pf==max(Pf)));
RFParam.PeakEnvBF=X(i);
i1=max([1 max([find(X<=RFParam.PeakEnvBF & Pf<0.5*max(Pf))])]);             %Lower 3 dB cutoff
i2=min([length(X) min(find(X>RFParam.PeakEnvBF & Pf<0.5*max(Pf)))]);        %Upper 3 dB cutoff
X1=interp1([Pf(i1+1) Pf(i1)]/max(Pf),X([i1+1 i1]),0.5);                     %Lower 3 dB cutoff
X2=interp1([Pf(i2) Pf(i2-1)]/max(Pf),X([i2 i2-1]),0.5);                     %Upper 3 dB cutoff
RFParam.HalfEnvBW=X2-X1;
RFParam.X1=X1;
RFParam.X2=X2;
RFParam.Pf=Pf;

%Finding Envelope Bandwidth at 10% of peak envelope
i1=max([1 max([find(X<=RFParam.PeakEnvBF & Pf<0.1*max(Pf))])]);            %Lower 10% cutoff
i2=min([length(X) min(find(X>RFParam.PeakEnvBF & Pf<0.1*max(Pf)))]);       %Upper 10% cutoff
XL10=interp1([Pf(i1+1) Pf(i1)]/max(Pf),X([i1+1 i1]),0.1);                  %Lower 10% cutoff
XU10=interp1([Pf(i2) Pf(i2-1)]/max(Pf),X([i2 i2-1]),0.1);                  %Upper 10% cutoff
if isnan(XU10) 
   XU10=max(X); 
end
if isnan(XL10)
    XL10=min(X);
end
RFParam.EnvBW10=XU10-XL10;
RFParam.XL10=XL10;
RFParam.XU10=XU10;

%Finding Spectral Bandwidth and centroid - Values below alpha1 are not used-
%this removes long noise tail which biases BW and BF estimates
i1=max([1 find(X<RFParam.PeakEnvBF & Pf<alpha1*max(Pf))]);
i2=min([find(X>RFParam.PeakEnvBF & Pf<alpha1*max(Pf)) length(X)]);
Pfn=Pf(i1:i2)/sum(Pf(i1:i2));                                               %Normalized and truncated spectral distribution
RFParam.BF=sum(X(i1:i2).*Pfn);
RFParam.BFHz=sum(faxis(i1:i2).*Pfn);
RFParam.BW=2*sqrt(sum((X(i1:i2)-RFParam.BF).^2.*Pfn));
RFParam.BWHz=2*sqrt(sum((faxis(i1:i2)-RFParam.BFHz).^2.*Pfn));

%Computing Phase Locking Index
RFParam.PLI=strfpli(STRF,Wo,PP,Sound);
RFParam.PLI2=strfpli2(taxis,STRF,zeros(size(STRF)),Wo,PP);

%Computing STRF Energy (spikes/sec)
RFParam.STRFStd=strfstd(STRF,zeros(size(STRF)),PP,1/(taxis(2)-taxis(1)));

%Inhibitory to Excitatory Ratio - Rodriguez 2010 - Added Escabi 5/14
i=find(STRF>0);
VarE=sum(STRF(i).^2);
i=find(STRF<0);
VarI=sum(STRF(i).^2);
if VarE>=VarI
    IER=VarI/VarE;
elseif VarI==0 | VarE==0
    IER=0
elseif VarE<VarI
    IER=-VarE/VarI;     %Added Negative Sign - Rodriguez did not use this (-) sign to identify directionality - you can always take abs(IER) and its the same as Rodriguez
end
RFParam.IER=IER;

%Displaying Output
if Disp=='y'
    figure
    subplot(1.2,1.2,1.2)
    imagesc(taxis,X,STRF), set(gca,'YDir','normal')
    hold on
    plot(RFParam.PeakDelay,RFParam.PeakBF,'gx','linewidth',2)
    hold off
    
    figure
    subplot(1.2,5,1)
    plot(Pf/max(Pf),X,'k')
    hold on
    plot(0.5,X1,'r+')
    plot(0.5,X2,'r+')
    plot(0.1,XL10,'r.')
    plot(0.1,XU10,'r.')
    plot(1,RFParam.PeakEnvBF,'ro')
    axis([0 1.1 0 max(X)])
    set(gca,'XDir','reverse')
    set(gca,'Visible','off')
    hold off
    
    figure
    subplot(5,1.2,6)
    plot(taxis,Pt/max(Pt),'k')
    hold on
    plot(t1_50,0.5,'r+')
    plot(t2_50,0.5,'r+')
    plot(t1_10,0.1,'r.')
    plot(t2_10,0.1,'r.')
    plot(RFParam.PeakEnvDelay,1,'ro')
    axis([0 max(taxis) 0 1.1])
    set(gca,'YDir','reverse')
    set(gca,'Visible','off')
    hold off
end