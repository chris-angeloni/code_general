%
%function [H,p]=rastercircularshufcorrsigtest(RDataA,RDataB,alpha,flag)
%
%   FILE NAME       : RASTER CIRCULAR SHUF CORR SIG TEST
%   DESCRIPTION     : Performs a significance test on the shuffled
%                     correaltion using jackknife samples
%
%   RDataA          : Data structure containing Jackknife shuf correlation
%                     for data 
%   RDataB          : Data structure containing Jackknife shuf correlation
%                     for the reference spike train (typically a Poisson of
%                     equal firing rate)
%   alpha           : Significance level
%   flag            : 'MI' or 'REL', Default == 'REL'
%
%RETURNED VALUES
%
%   H               : 0 or 1, null hypothesis MI or REL are equal is
%                     rejected if H=0
%   p               : Significance probability
%
% (C) Monty A. Escabi, Oct 2013
%
function [H,p]=rastercircularshufcorrsigtest(RDataA,RDataB,alpha,flag)

%Input Args
if nargin < 4
    flag='REL';
end

%Significance Testing
if strcmp(flag,'MI')
    
    %Jackknifing MI for A and B
    Max=max(squeeze(RDataA.RshufJ(:,:,:)),[],2);
    Min=min(squeeze(RDataA.RshufJ(:,:,:)),[],2);
    MIA=(Max-Min)./Max;
    Max=max(squeeze(RDataB.RshufJ(:,:,:)),[],2);
    Min=min(squeeze(RDataB.RshufJ(:,:,:)),[],2);
    MIB=(Max-Min)./Max;
    
    %Finding Mean And SD
    N=length(MIA);
    SigmaA=(N-1)/sqrt(N)*std(MIA);
    SigmaB=(N-1)/sqrt(N)*std(MIB);
    MeanA=mean(MIA);
    MeanB=mean(MIB);
    
    %Performing significance test
    [H,p]=sigztest(MeanA,SigmaA,MeanB,SigmaB,alpha);

else
    
    %Input Model Parmeters
    X.lambda=RDataA.lambda;
    X.Tau=RDataA.Tau;
    X.Fm=RDataA.Fm;

    %Obtaining Mean Model Fit
    YdataA=squeeze(mean(RDataA.RshufJ(:,:,:),2))';
    [betaA0]=gaussfunmodeloptim(X,YdataA);
    YdataB=squeeze(mean(RDataB.RshufJ(:,:,:),2))';
    [betaB0]=gaussfunmodeloptim(X,YdataB);
    
    %Jackknifing Model Fit
    for n=1:size(RDataA.RshufJ,2)
        YdataA=squeeze(RDataA.RshufJ(:,n,:))';
        YdataB=squeeze(RDataB.RshufJ(:,n,:))';
        [betaA(n,:)]=lsqcurvefit('gaussfunmodel',betaA0,X,YdataA);
        [betaB(n,:)]=lsqcurvefit('gaussfunmodel',betaB0,X,YdataB);
    end
   
    %Extracting Reliability
    XhatA=betaA(:,2);
    XhatB=betaB(:,2);
    N=length(XhatA);
    MeanA=mean(XhatA);
    MeanB=mean(XhatB);
    SigmaA=(N-1)/sqrt(N)*std(XhatA);
    SigmaB=(N-1)/sqrt(N)*std(XhatB);
     
    %Performing significance test
    [H,p]=sigztest(MeanA,SigmaA,MeanB,SigmaB,alpha);
        
end