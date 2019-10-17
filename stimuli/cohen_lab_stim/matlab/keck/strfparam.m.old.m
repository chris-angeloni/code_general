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
%                     below alpha are not considered (Default==0.25). See 
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
%.HalfEnvDuration   : Envelope Duration obained by measuring
%                     the 1/2 power boundaties of Pt 
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
%                     averaging RTF quandrants ala Milller 2001)
%       .cSMF       : Spectral Modulation Frequency Centroid (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%       .cTMF2      : Same as cTMF except that signals below alpha % of max are
%                     not used in the estimate
%       .cSMF2      : Same as cSMF except that signals below alpha % of max are
%                     not used in the estimate
%       .bwSMF      : Spectral MTF bandwidth, Measured using standard deviation
%                     of sMTF
%       .bwTMF      : Tpectral MTF bandwidth, Measured using standard deviation
%                     of tMTF
%       .bwSMF2     : Same as bwSMF except that signals below alpha% of max are
%                     not used in the estimate
%       .bwTMF2     : Same as bwTMF except that signals below alpha% of max are
%                     not used in the estimate
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
%
% (C) Monty A. Escabi, December 2005 (Edit Sept 2008)
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
    alpha2=0.25;
end
if nargin<12
    Disp='n';
end

%Finding Ripple Transfer Function & Parameters
%taxis=taxis;
[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRF,MaxFm,MaxRD,'n');
[TFParam]=rtfparam(Fm,RD,RTF,Thresh,alpha2,'n');
RFParam=TFParam;

%Normalizing Time and Frequency Axis
taxis=1000*(taxis-min(taxis));
X=log2(faxis/faxis(1));

%Finding BF and Peak Delay
dX=log2(faxis(2))-log2(faxis(1));
dt=taxis(2)-taxis(1);
[i,j]=find(max(max(abs(STRF)))==abs(STRF));
RFParam.PeakDelay=taxis(j);
RFParam.PeakBF=X(i);

%Finding Half Width and Peak Envelope Delay
Nt=size(STRF,2);
Ht=hilbert(STRF',1000)';
Ht=Ht(:,1:Nt);
%Pt=mean(abs(Ht));
%Pt=Pt.^2/sum(Pt.^2);        %Assumes Power Distribution, e.g. see Cohen
Pt=mean(abs(Ht).^2);        %Changed to Mean-square, mathematically correct, Nov. 13, 2007
Pt=Pt/sum(Pt);
i=find(Pt==max(Pt));
RFParam.PeakEnvDelay=taxis(i);
i1=max([1 min([find(taxis<=RFParam.PeakEnvDelay & Pt>0.5*max(Pt))])-1]);
i2=min([length(taxis) max(find(taxis>RFParam.PeakEnvDelay & Pt>0.5*max(Pt)))+1]);
t1=interp1([Pt(i1+1) Pt(i1)]/max(Pt),taxis([i1+1 i1]),0.5);                 %0.5 Amplitude crossing
t2=interp1([Pt(i2) Pt(i2-1)]/max(Pt),taxis([i2 i2-1]),0.5);                 %0.5 Amplitude crosssing
RFParam.HalfEnvDuration=t2-t1;                                              %Half Duration
RFParam.Pt=Pt;

%Finding Temporal Duration and group delay - Values below alpha1 are not
%used - this removes long noise tail wich biases duration and delay
%estimates
i=1:min(find(taxis>RFParam.PeakEnvDelay & Pt<alpha1*max(Pt)));
Ptn=Pt(i)/sum(Pt(i));                                                       %Normalized and truncated temporal distribution
RFParam.Delay=sum(taxis(i).*Ptn);
RFParam.Duration=2*sqrt(sum((taxis(i)-RFParam.Delay).^2.*Ptn));

%Finding Spectral Envelope Half BW and Peak Envelope BF 
Nf=size(STRF,1);
Hf=hilbert(STRF,1000);
Hf=Hf(1:Nf,:);
%Pf=mean(abs(Hf'));
%Pf=Pf.^2/sum(Pf.^2);        %Assumes Power Distribution, e.g. see Cohen
Pf=mean(abs(Hf').^2);        %Changed to Mean-square, mathematically correct, Nov. 13, 2007
Pf=Pf/sum(Pf);
i=find(Pf==max(Pf));
RFParam.PeakEnvBF=X(i);
i1=max([1 min([find(X<=RFParam.PeakEnvBF & Pf>0.5*max(Pf))])-1]);           %Lower 3 dB cutoff
i2=min([length(X) max(find(X>RFParam.PeakEnvBF & Pf>0.5*max(Pf)))+1]);      %Upper 3 dB cutoff
X1=interp1([Pf(i1+1) Pf(i1)]/max(Pf),X([i1+1 i1]),0.5);                     %Lower 3 dB cutoff
X2=interp1([Pf(i2) Pf(i2-1)]/max(Pf),X([i2 i2-1]),0.5);                     %Upper 3 dB cutoff
RFParam.HalfEnvBW=X2-X1;
RFParam.X1=X1;
RFParam.X2=X2;
RFParam.Pf=Pf;

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

%Displaying Output
if Disp=='y'
    subplot(1.2,1.2,1.2)
    taxis=taxis;
    imagesc(taxis,X,STRF), set(gca,'YDir','normal')
    hold on
    plot(RFParam.PeakDelay,RFParam.PeakBF,'gx','linewidth',2)
    hold off
    
    subplot(1.2,5,1)
    plot(Pf/max(Pf),X,'k')
    hold on
    plot(0.5,X1,'r+')
    plot(0.5,X2,'r+')
    plot(1,RFParam.PeakEnvBF,'ro')
    axis([0 1.1 0 max(X)])
    set(gca,'XDir','reverse')
    set(gca,'Visible','off')
    hold off
    
    subplot(5,1.2,6)
    plot(taxis,Pt/max(Pt),'k')
    hold on
    plot(t1,0.5,'r+')
    plot(t2,0.5,'r+')
    plot(RFParam.PeakEnvDelay,1,'ro')
    axis([0 max(taxis) 0 1.1])
    set(gca,'YDir','reverse')
    set(gca,'Visible','off')
    hold off
end