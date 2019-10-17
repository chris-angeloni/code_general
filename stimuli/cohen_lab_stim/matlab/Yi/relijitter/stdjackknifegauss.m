function [SEdc,SEpeak,SEp,SEsigma,SEeff]=stdjackknifegauss(R,Fm,Fsd,beta0,betaL,betaU)

% DESCRIPTION:  jackknife R to get the std of p,sigma,eff
% Yi Zheng, June 2008

% SE.p
% SE.sigma
% SE.eff

NJ=size(R.RshufJt,1);
for k=1:NJ
    Rab = R.RshufJt(k,:);  % jackknife Rab: R.RshufJt
    Nctr = floor(length(Rab)/2)+1;
    Tau = (ceil(-length(Rab)/2):ceil(length(Rab)/2)-1)/Fsd;
    NP = ceil(Fsd/Fm/2);
    Rshufctr4 = Rab(Nctr-4*NP:Nctr+4*NP-1);
    Tauctr4 = Tau(Nctr-4*NP:Nctr+4*NP-1);
    T=1/Fm;
    [beta]=lsqcurvefit(@(beta,Tauctr4) gaussfun(beta,Tauctr4,T),beta0,Tauctr4,Rshufctr4,betaL,betaU);
    Rshufreli = Rshufctr4-beta(1);
    pJ(k,1)= sqrt((sum(Rshufreli))/4/Fsd/Fm);
    sigmaJ(k,1)=abs(beta(3))*1000/sqrt(2);
    effJ(k,1)=sum(Rshufreli)/sum(Rshufctr4);
    dcJ(k,1)=beta(1);
    peakJ(k,1)=beta(2);
end  % end of jackknife

% Jackknife residuals
for k=1:NJ
    pres(k,:)=mean(pJ,1)-pJ(k,1);
    sigmares(k,:)=mean(sigmaJ,1)-sigmaJ(k,1);
    effres(k,:)=mean(effJ,1)-effJ(k,1);
    dcres(k,:)=mean(dcJ,1)-dcJ(k,1);
    peakres(k,:)=mean(peakJ,1)-peakJ(k,1);
end

pset=sqrt((NJ-1)*var(pres));  % standard error across trials
% psec = pset/sqrt(NJ-1); % standard error across correlations
sigmaset=sqrt((NJ-1)*var(sigmares));  
effset=sqrt((NJ-1)*var(effres)); 
dcset=sqrt((NJ-1)*var(dcres)); 
peakset=sqrt((NJ-1)*var(peakres)); 
SEp = pset;
SEsigma = sigmaset;
SEeff = effset;
SEdc = dcset;
SEpeak = peakset;