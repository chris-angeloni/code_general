%
%function [RFParamb]=strfparamboot(taxis,faxis,STRFb,Threshs,NB,MaxFm,MaxRD,Thresh,alpha1,alpha2,Disp)
%
%   FILE NAME       : STRF PARAM BOOT
%   DESCRIPTION     : Computes temporal and spectral STRF parameters from 
%                     the statistically significant STRF. Bootstraps the
%                     data across multiple recording segments
%	
%       taxis       : Time Axis (sec)
%       faxis       : Frequency Axis (Hz)
%       STRFb        : Spectrotemporal receptive field - broken up into data
%                     segments for bootstrapping
%       Threshs      : Threshold value for significant STRF estimate
%       NB          : Number of bootstraps
%       MaxFM       : Maximum Modulation Rate (Default = 500 Hz)
%       MaxRD       : Maximum Ripple Density (Default = 4 cyc/oct)
%       Thresh      : Fraction of Maximum for second response peak
%                     Two Best RD and FM are choosen if the second
%                     maximum achieves the value Thresh*max(max(RTF))
%                     where Thresh E [0 1] (Optional, Default=0.5)
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
%	RFParamb (Data structure containing bootstrapped STRF parameters)
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
%.FmLowerCutoff     : Temporal Modulation Frequency Lower Cutoff (Optained
%by
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
%
% (C) Monty A. Escabi, December 2005 (Edit January 2008)
%
function [RFParamb]=strfparamboot(taxis,faxis,STRFb,Threshs,NB,MaxFm,MaxRD,Thresh,alpha1,alpha2,Disp)

%Input Arguments
if nargin<5
    NB=100;
end
if nargin<6
    MaxFm=500;
end
if nargin<7
    MaxRD=4;
end
if nargin<8
    Thresh=0.5;   %Half Power Threshold 
end
if nargin<9
    alpha1=0.05;
end
if nargin<10
    alpha2=0.25;
end
if nargin<11
    Disp='n';
end


%Number of boostrap data blocks
LB=size(STRFb,3);

%Bootstrapping STRFPARAM
for k=1:NB
    
    %Display
    clc, disp(['Bootstrapping STRF Param: ' num2str(k/NB*100,3) ' %' ])
   
   %Bootstrap resampling the STRF
   i=randsample(LB,LB,'true');
   STRF=mean(STRFb(:,:,i),3);
    
   %Finding significant bootstrap samples
   i=find(abs(STRF)<=Threshs);
   STRF(i)=zeros(size(i));
   
   %Bootstrapping STRFPARAM
   [RFParamb(k)]=strfparam(taxis,faxis,STRF,MaxFm,MaxRD,Thresh,alpha1,alpha2,Disp);
    
end