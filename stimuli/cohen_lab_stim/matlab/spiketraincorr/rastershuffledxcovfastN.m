%
%function [CovDataN]=rastershuffledxcovfastN(RASDataN,Fsd,MaxTau,Mean,Diag,NJ)
%
%   FILE NAME       : RASTER SHUFFLED XCOV FAST N
%   DESCRIPTION     : N-Channel shuffled crosscorrelogram using 
%                     rastergram. Performs shuffled correlograms between 
%                     the rasters from N recording channels. For each 
%                     correlation, the program determines the trial 
%                     standard deviation and p<0.01 and p<0.05 
%                     confidence intervals of Ravg with a Bootstrap 
%                     procedure.
%
%	RASDataN       : Data structure containing dot-rasters for 16 channel 
%                     recording (compressed spet format)
%   Fsd             : sampling rate of raster to compute raster-corr.
%   MaxTau          : Max delay (msec)
%   Mean            : Remove mean - 'y' or 'n' (Default=='y')
%   Diag            : Remove diagonal correlations - 'y' or 'n'
%                     (Default=='y'). This option is used if one wants to
%                     compute the correlation between trials (within trials
%                     are removed).
%	NJ              : Number of Jackknives for Cross Correlation Estimate
%                     (Default = 0). This is used to compute the standard
%                     errror on all statistics.
%
%RETURNED VALUES
%
%   CovData16(k,l)  : Data structure containing the following elements
%
%                     .R12     - Average shuffled crosscovariance -
%                                normalized using the shuffled
%                                autocorrelation
%
%                                   R12/sqrt(max(R11)*max(R22))
%
%                     .R12b     - Average shuffled crosscovariance -
%                                 normalized by assuming Poisson assumption
%                                 and using the firing rates
%                               
%                                   R12/sqrt(lambda1*lambda2)
%
%                     .Tau     - Correlation Delay Axis (msec)
%                     .lambda1 - Spike rate for RASTER1
%                     .lambda2 - Spike rate for RASTER2
%                     .NJ      - Number of jackknives performed for
%                                significance limits
%
% (C) Monty A. Escabi, Nov 2016
%
function [CovDataN]=rastershuffledxcovfastN(RASDataN,Fsd,MaxTau,Mean,Diag,NJ)

%Input Arguments
if nargin<4 | isempty(Mean)
    Mean='y';
end
if nargin<5 | isempty(Diag)
    Diag='y';
end
if nargin<6 | isemptry(NJ)
    NJ=0;
end

%Computing Across Channel Covariance
for k=1:length(RASDataN)
    for l=1:length(RASDataN)
        [CovData(k,l)]=rastershuffledxcovfast(RASDataN(k).RASTER,RASDataN(l).RASTER,Fsd,MaxTau,Mean,Diag,NJ);
        CovMatrixMax(k,l)=max(CovData(k,l).R12);
        N=(length(CovData(k,l).R12)-1)/2;
        CovMatrix0(k,l)=CovData(k,l).R12(N+1);
    end
end

%Adding Covariance Matrix to Data Structure
CovDataN.CovData=CovData;
CovDataN.CovMatrixMax=CovMatrixMax;
CovDataN.CovMatrix0=CovMatrix0;

