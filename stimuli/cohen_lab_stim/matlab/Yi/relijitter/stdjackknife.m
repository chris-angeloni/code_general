function [SEpeak]=stdjackknife(R,Fm,Fsd)

% DESCRIPTION:  jackknife R to get the std of p,sigma,eff
% Yi Zheng, June 2008

% SE.p
% SE.sigma
% SE.eff

NJ=size(R.RshufJt,1);
for k=1:NJ
    Rab = R.RshufJt(k,:);  % jackknife Rab: R.RshufJt
    peakJ(k,1)=max(Rab)-min(Rab);
end  % end of jackknife

% Jackknife residuals
for k=1:NJ
    peakres(k,:)=mean(peakJ,1)-peakJ(k,1);
end

peakset=sqrt((NJ-1)*var(peakres)); 
SEpeak = peakset;