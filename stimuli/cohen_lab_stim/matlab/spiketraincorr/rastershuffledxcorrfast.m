%
%function [CorrData]=rastershuffledxcorrfast(RASTER1,RASTER2,Fsd,MaxTau,Mean,Diag,NJ)
%
%   FILE NAME       : RASTER SHUFFLED XCORR FAST
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
%   CorrData   : Data structure containing the following elements
%
%                     .R12     - Average shuffled crosscorrelogram
%                     .Tau     - Correlation Delay Axis (msec)
%                     .lambda1 - Spike rate for RASTER1
%                     .lambda2 - Spike rate for RASTER2
%                     .NJ      - Number of jackknives performed for
%                                significance limits
%
% (C) Monty A. Escabi, October 2012
%
function [CorrData]=rastershuffledxcorrfast(RASTER1,RASTER2,Fsd,MaxTau,Mean,Diag,NJ)

%Input Args
if nargin<5 | isempty(Mean)
    Mean='n';
end
if nargin<6 | isempty(Diag)
    Diag='n';
end
if nargin<7 | isempty(NJ)
    NJ=0;
end

%Expand rastergram into matrix format
T=RASTER1(1).T;
Fs=RASTER1(1).Fs;
[RAS1,Fs]=rasterexpand(RASTER1,Fsd,T);
[RAS2,Fs]=rasterexpand(RASTER2,Fsd,T);

%Rastergram Length
M=size(RAS1,1); %Number of trials
L=size(RAS2,2); %Nimber of samples

%Computing Shuffled Cross Correlation using the following algorithm:
%
%   Rshuffle = Rpsth1,psth2
%
%This approach is a very efficient way of computing the shuffled
%correlation function. It requires 1 correlations compared to M^2.
%Essentially we can compute the PSTH for each raster and then perform the
%correlation between the PSTHs.
%
MaxLag=ceil(MaxTau/1000*Fsd);
PSTH1=sum(RAS1,1);
PSTH2=sum(RAS2,1);
R12=xcorr(PSTH1,PSTH2,MaxLag,'unbiased');   %Unbiased normalizes by 1/(M-abs(Lag)))

%Removing diagonal terms if desired - this is done when one does not want
%to use the same trials (across trial only)
Rdiag=[];
if strcmp(Diag,'y')
    
    for k=1:M
        %Rdiag=[Rdiag; xcorr(RAS1(k,:),RAS2(k,:),MaxLag,'unbiased')];
        Rdiag=[Rdiag; xcorrspikefast(RASTER1(k).spet,RASTER2(k).spet,Fs,Fsd,MaxTau,T,'n','n','n')];     %Indistinguishable to above
    end
    Rdiag=sum(Rdiag,1);
    R12=R12-Rdiag;                              %Subtracting diagonal terms
    R12=R12/M/(M-1);                            %Normalizing by number of trials - diagonal removed
else
    R12=R12/M^2;                                %Normalzing by number of trials
end

%Removing Mean if desired
if strcmp(Mean,'y')
    lambda1=mean(mean(RAS1));
    lambda2=mean(mean(RAS2));
    R12=R12-lambda1*lambda2;
end

%Converting to data structure
CorrData.R12=R12;
%CorData.R12Jt=R12Jt;
%CorrData.R12set=R12set;
CorrData.lambda1 = lambda1;                 % average firing rate
CorrData.lambda2 = lambda2;                 % average firing rate
CorrData.Tau=(-MaxLag:MaxLag)/Fsd*1000;     %Delay Axis