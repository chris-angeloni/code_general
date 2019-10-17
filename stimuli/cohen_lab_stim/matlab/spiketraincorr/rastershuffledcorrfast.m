%
%function [CorrData]=rastershuffledcorrfast(RASTER,Fsd,MaxTau,Mean,NB)
%
%   FILE NAME       : RASTER SHUFFLED CORR FAST
%   DESCRIPTION     : Shuffled Autocorrelogram usingn rastergram. Determines 
%                     the trial standard deviation and p<0.01 and p<0.05 
%                     confidence intervals of Ravg with a Bootstrap 
%                     procedure.
%
%	RASTER          : Rastergram in compressed format
%   Fsd             : Sampling rate for correlation measurement
%   MaxTau          : Maximum Correlation Delay (msec)
%   Mean            : Remove mean (i.e., for covariance) - 'y' or 'n'
%                     (Default=='n')
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
% (C) Monty A. Escabi, Jan 2010
%
function [CorrData]=rastershuffledcorrfast(RASTER,Fsd,MaxTau,Mean,NB)

%Input Arguments
if nargin<4
    Mean='n';
end
if nargin<5
	NB=500;
end

%AutoCorrelogram
Ra=[];
L=length(RASTER);
Fs=RASTER(1).Fs;
for k=1:L
	clc
	disp(['Computing correlogram for channel: ' num2str(k)])
    [Raa]=xcorrspikefast(RASTER(k).spet,RASTER(k).spet,Fs,Fsd,MaxTau,RASTER(k).T,'n','n','n');
    Ra=[Ra;Raa]; 
end

%Shuffled Autocorrelogram
MaxLag=ceil(MaxTau/1000*Fsd);
RAS=rasterexpand(RASTER,Fsd,RASTER(1).T);
PSTH=mean(RAS,1);
Rs=xcorr(PSTH,PSTH,MaxLag);
M=length(PSTH);
D=-MaxLag:MaxLag;
Rs=Rs./(M-abs(D));    %Unbiased estimator - see documentation for XCORR normalization
Rs=1/L/(L-1)*(L^2*Rs-sum(Ra));   %Fast implementation Eqn., Zheng & Escabi 2010
if strcmp(Mean,'y')
    lambda=mean(mean(RAS))
    Rs=Rs-lambda^2;
end

%Shuffled Autocorrelogram - Jackknife estimate
RsJ=[];
L=length(RASTER);
for k=1:L
    clc
	disp(['Computing correlogram jackknife for channel: ' num2str(k)])
    RASTERj=[RASTER(1:L-1); RASTER(L+1:end)];
    RASj=rasterexpand(RASTERj,Fsd,RASTERj(1).T);
    PSTHj=mean(RASj,1);
    Rsj=xcorr(PSTHj,PSTHj,MaxLag);
    M=length(PSTHj);
    D=-MaxLag:MaxLag;
    Rsj=Rsj./(M-abs(D));    %Unbiased estimator - see documentation for XCORR normalization
    RsJ=[RsJ ;  1/(L-1)/(L-2)*((L-1)^2*Rsj-sum(Ra*(L-1)/L))];          %Adding Mth Jackknife
    if strcmp(Mean,'y')
        lambdaJ=mean(mean(RASj))
        RsJ=RsJ-lambdaJ^2;
    end
end

%Finding Average Correlation and Confidence Intervals using Bootstrap
if NB>1
	Rab=Rs;
    Raa=mean(Ra);
else
	Rab=Rs;
    Raa=Ra;
end
if NB~=0
    E=[];
    for k=1:L
        E=[E; RsJ(k,:)-Rs];
    end
    Rabstd=(L-1)*sum(E.^2/L);
    [Raastd,Raa05,Raa01]=rastercorrbootstrap(Ra,NB);
else
	Rab05=-9999;
	Rab01=-9999;
    Raa05=-9999;
    Raa01=-9999;
end

%Storingn in Data Structure
N=(length(Rab)-1)/2;
Raa(N+1)=0;         %Need to remove zeroth bin
RaaB(N+1)=0;        %Need to remove zeroth bin
CorrData.Rab=Rab;
CorrData.RabB=Rs;
CorrData.Rabstd=Rabstd;
%CorrData.Rab05=Rab05;
%CorrData.Rab01=Rab01;
CorrData.Raa=Raa;
CorrData.RaaB=Ra;
CorrData.Raastd=Raastd;
CorrData.Raa05=Raa05;
CorrData.Raa01=Raa01;
CorrData.Tau=(-N:N)/Fsd;
CorrData.NB=NB;