%
%function [CorrData]=rastershuffledcorr(RASTER,Fsd,MaxTau,NB)
%
%   FILE NAME       : RASTER SHUFFLED CORR
%   DESCRIPTION     : Shuffled Autocorrelogram usingn rastergram. Determines 
%                     the trial standard deviation and p<0.01 and p<0.05 
%                     confidence intervals of Ravg with a Bootstrap 
%                     procedure.
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
%                     .Rab    - Average shuffled autocorrelogram
%                     .RabB   - Bootstrap trials of Rab
%                     .Rabstd - Shuffled autocorrelogram standard deviation
%                     .Rab05  - 2xlength(Rab) matrix containg the possitive
%                               and negative p<0.05 confidence intervals
%                     .Rab01  - 2xlength(Raa) matrix containg the possitive
%                               and negative p<0.01 confidence intervals
%                     .Raa    - Average autocorrelogram
%                     .RaaB   - Bootstrap trials of Raa
%                     .Raastd - Shuffled autocorrelogram standard deviation
%                     .Raa05  - 2xlength(Ravg) matrix containg the possitive and 
%                               negative p<0.05 confidence intervals
%                     .Raa01  - 2xlength(Ravg) matrix containg the possitive and 
%                               negative p<0.01 confidence intervals
%
%                     .Tau    - Correlation Delay Axis
%                     .NB     - Number of bootstraps performed for
%                               significance limits
%
% (C) Monty A. Escabi, Modified July 2006 (Edit, June 2010 ME)
%
function [CorrData]=rastershuffledcorr(RASTER,Fsd,MaxTau,NB)

%Input Arguments
if nargin<4
	NB=500;
end

%Shuffled Autocorrelogram
M=length(RASTER);
Fs=RASTER(1).Fs;
Rs=[];
for k=1:M
	clc
	disp(['Computing shuffled correlogram for channel: ' num2str(k)])
	for l=1:k-1
        [Rab]=xcorrspikefast(RASTER(k).spet,RASTER(l).spet,Fs,Fsd,MaxTau,RASTER(k).T,'n','n','n');
        Rs=[Rs;Rab]; 
    end
end
Rs=[Rs; fliplr(Rs)];    %Now uses N*(N-1) correlograms as opposed to lower diagonal, N*(N-1)/2. Thus Rs is now symetric.

%AutoCorrelogram
Ra=[];
for k=1:M
	clc
	disp(['Computing correlogram for channel: ' num2str(k)])
    [Raa]=xcorrspikefast(RASTER(k).spet,RASTER(k).spet,Fs,Fsd,MaxTau,RASTER(k).T,'y','n','n');
    Ra=[Ra;Raa]; 
end

%Finding Average Correlation and Confidence Intervals using Bootstrap
if size(Rs,1)>1
	Rab=mean(Rs);
    Raa=mean(Ra);
else
	Rab=Rs;
    Raa=Ra;
end
if NB~=0
	[Rabstd,Rab05,Rab01]=rastercorrbootstrap(Rs,NB);
    [Raastd,Raa05,Raa01]=rastercorrbootstrap(Ra,NB);
else
	Rab05=-9999;
	Rab01=-9999;
    Raa05=-9999;
    Raa01=-9999;
end

%Storingn in Data Structure
N=(length(Rab)-1)/2;
CorrData.Rab=Rab;
CorrData.RabB=Rs;
CorrData.Rabstd=Rabstd;
CorrData.Rab05=Rab05;
CorrData.Rab01=Rab01;
CorrData.Raa=Raa;
CorrData.RaaB=Ra;
CorrData.Raastd=Raastd;
CorrData.Raa05=Raa05;
CorrData.Raa01=Raa01;
CorrData.Tau=(-N:N)/Fsd;
CorrData.NB=NB;