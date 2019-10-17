%
%function [CorrData]=rasterautocorr(RASTER,Fsd,MaxTau,NB)
%
%   FILE NAME       : RASTER AUTO CORR
%   DESCRIPTION     : Autocorrelogram usingn rastergram. Determines 
%                     the trial standard deviation and p<0.01 and p<0.05 
%                     confidence intervals of Ravg with a Bootstrap 
%                     procedure
%
%	RASTER          : Rastergram in compressed format
%   Fsd             : Sampling rate for correlation measurement
%   MaxTau          : Maximum Correlation Delay (msec)
%	NB              : Number of Bootstraps for Cross Correlation Estimate
%                     Default = 500
%
%RETURNED VALUES
%
%   CorrData   : Data structure containing the following elements
%
%                     .Raa    - Average autocorrelogram
%                     .RaaB   - Bootstrap trials of Raa
%                     .Raastd - Shuffled autocorrelogram standard deviation
%                     .Raa05  - 2xlength(Raa) matrix containg the possitive
%                               and negative p<0.05 confidence intervals
%                     .Raa01  - 2xlength(Raa) matrix containg the possitive
%                               and negative p<0.01 confidence intervals
%                     .Tau    - Correlation Delay Axis
%                     .NB     - Number of bootstraps performed for
%                               significance limits
%
% (C) Monty A. Escabi, Modified July 2006 (Edit, June 2010 ME)
%
function [CorrData]=rasterautocorr(RASTER,Fsd,MaxTau,NB)

%Input Arguments
if nargin<5
	NB=500;
end

%AutoCorrelogram
Fs=RASTER(1).Fs;
M=length(RASTER);
Ra=[];
for k=1:M
	clc
	disp(['Computing cross-channel correlation for channel: ' num2str(k)])
    [Raa]=xcorrspikefast(RASTER(k).spet,RASTER(k).spet,Fs,Fsd,MaxTau,RASTER(k).T,'n','n','n');
    Ra=[Ra;Raa]; 
end

%Finding Average Correlation and Confidence Intervals using Bootstrap
if size(Ra,1)>1
    Raa=mean(Ra);
else
    Raa=Ra;
end
if NB~=0
    [Raastd,Raa05,Raa01]=rastercorrbootstrap(Ra,NB);
else
    Raa05=-9999;
    Raa01=-9999;
end

%Storing in Data Structure
N=(length(Raa)-1)/2;
CorrData.Raa=Raa;
CorrData.RaaB=Ra;
CorrData.Raastd=Raastd;
CorrData.Raa05=Raa05;
CorrData.Raa01=Raa01;
CorrData.Tau=(-N:N)/Fsd;
CorrData.NB=NB;