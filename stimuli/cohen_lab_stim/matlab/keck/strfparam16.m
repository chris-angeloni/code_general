%
%function [RF1Param16,RF2Param16]=strfparam16(STRFData16,MaxFm,MaxRD)
%
%       FILE NAME       : STRF PARAM 16
%       DESCRIPTION     : Computes temporal and spectral STRF 
%                         parameters from statistically significant 
%                         STRF across 16 channel probe
%	
%	STRFData16          : Frequency Axis (Hz)
%   MaxFM               : Maximum Modulation Rate (Default = 500 Hz)
%   MaxRD               : Maximum Ripple Density (Default = 4 cyc/oct)
%
%RETURNED PARAMETERS
%
%	RF1Param16  : Data structure array containing STRF parameters (chan 1)
%   RF2Param16    Data structure array containing STRF parameters (chan 2)
%                 Delay         - Group delay (msec). Obtained by computing
%                                 average hibert transform on STRF and 
%                                 using it as a distribution function, Pt.
%                                 The delay is computed as the mean of Pt.
%                 Duration      - Temporal duration (msec). Obtained by
%                                 computing 2 * std of Pt.
%                 BF            - Best frequency (Octaves). Obtained by
%                                 computing the average hilbert transform
%                                 on the STRF and using it as spectral
%                                 distribution function, Pf. The BF is
%                                 obtained as the mean of Pf. 
%                 BW            - Spectral Bandwidth (Octaves). Obtained by
%                                 computing 2*std of Pf.
%                 PeakDelay     - Temporal delay at STRF Peak(msec) 
%                 PeakBF        - Best frequency at STRF Peak (Octaves)
%                 PeakEnvDelay  - Delay measurement obtained by taking the
%                                 peak of the temporal Envelope, Pt.
%                 PeakEnvBF     - BF measuremenet obtained by taking the
%                                 peak of the spectral envelope, Pf.
%              HalfEnvDuration  - Envelope Duration obained by measuring
%                                 the 1/2 power boundaties of Pt 
%                 HalfEnvBW     - Envelope BW obtained by measuring the 1/2
%                                 power boundaries of Pf
%                 BestFm        - Best Modulation Rate - Returns 2 values if second 
%                                 quadrant exceeds desired threshold value
%                 BestRD        - Best Ripple Density - Returns 2 values if second 
%                                 quadrant exceeds desired threshold value
%                 bTMF          - Best Temporal Modulation Frequency (Optained by averaging
%                                 RTF quandrants ala Milller 2001)
%                 bSMF          - Best Spectral Modulation Frequency (Optained by averaging
%                                 RTF quandrants ala Milller 2001)
%                 cTMF          - Temporal Modulation Frequency Centroid (Optained by
%                                 averaging RTF quandrants ala Milller 2001)
%                 cSMF          - Spectral Modulation Frequency Centroid (Optained by
%                                 averaging RTF quandrants ala Milller 2001)
%                 FmUpperCutoff - Temporal Modulation Frequency Upper Cutoff (Optained by
%                                 averaging RTF quandrants ala Milller 2001)
%                 FmLowerCutoff - Temporal Modulation Frequency Lower Cutoff (Optained by
%                                 averaging RTF quandrants ala Milller 2001)
%                 RDUpperCutoff - Spectral Modulation Frequency Upper Cutoff (Optained by
%                                 averaging RTF quandrants ala Milller 2001)
%                 RDLowerCutoff - Spectral Modulation Frequency Lower Cutoff (Optained by
%                                 averaging RTF quandrants ala Milller 2001)
%                 DSI           - Direction selectivity index, DSI=(P1-P2)/(P1+P2) where P1 and
%                                 P2 are the powers in the 1st and 2nd ripple transfer function
%                                 quadrants, respectively.
%                 Max           - Peak Response values from Ripple density plot
%
% (C) Monty A. Escabi, December 2005 (Edit July 2007)
%
function [RF1Param16,RF2Param16]=strfparam16(STRFData16,MaxFm,MaxRD)

%Input Arguments
if nargin<2
    MaxFm=500;
end
if nargin<3
    MaxRD=4;
end

%Computing STRF Parameters
taxis=STRFData16(1).taxis;
faxis=STRFData16(1).faxis;
for k=1:16

    [RF1Param16(k)]=strfparam(taxis,faxis,STRFData16(k).STRF1,MaxFm,MaxRD);
    [RF2Param16(k)]=strfparam(taxis,faxis,STRFData16(k).STRF2,MaxFm,MaxRD);
    
end