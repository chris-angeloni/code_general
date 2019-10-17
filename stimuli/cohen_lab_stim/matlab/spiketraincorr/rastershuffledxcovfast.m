%
%function [CovData]=rastershuffledxcovfast(RASTER1,RASTER2,Fsd,MaxTau,Mean,Diag,NJ)
%
%   FILE NAME       : RASTER SHUFFLED XCOV FAST
%   DESCRIPTION     : Shuffled Crosscorrelogram usingn rastergram. Determines 
%                     the trial standard deviation and p<0.01 and p<0.05 
%                     confidence intervals of Ravg with a Bootstrap 
%                     procedure.
%
%	RASTER1         : Rastergram 1 (compressed spet format)
%   RASTER2         : Rastergram 2 (compressed spet format)
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
%   CovData   : Data structure containing the following elements
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
% (C) Monty A. Escabi, October 2012
%
function [CovData]=rastershuffledxcovfast(RASTER1,RASTER2,Fsd,MaxTau,Mean,Diag,NJ)

if nargin<5 | isempty(Mean)
   Mean='y'; 
end
if nargin<6 | isempty(Diag)
    Diag='y'
end
if nargin<7 | isempty(NJ)
    NJ=0;
end

%Computing shuffled cross and autocovariance
[CorrData12]=rastershuffledxcorrfast(RASTER1,RASTER2,Fsd,MaxTau,Mean,Diag);
[CorrData1]=rastershuffledxcorrfast(RASTER1,RASTER1,Fsd,MaxTau,Mean,Diag);
[CorrData2]=rastershuffledxcorrfast(RASTER2,RASTER2,Fsd,MaxTau,Mean,Diag);
%[CorrData1]=rastershuffledcorrfast(RASTER1,Fsd,MaxTau,'n',100);
%[CorrData2]=rastershuffledcorrfast(RASTER2,Fsd,MaxTau,'n',100);

%Sorting data in structure
CovData.R12=CorrData12.R12/sqrt(max(abs(CorrData2.R12))*max(abs(CorrData1.R12)));
CovData.R12b=CorrData12.R12/sqrt(CorrData12.lambda1*CorrData12.lambda2.*Fsd^2);
CovData.Tau=CorrData12.Tau;
CovData.lambda1=CorrData12.lambda1;
CovData.lambda2=CorrData12.lambda2;