%
%function [SAMValData2]=wienerkernelsamvalidate2(MTFb1,MTFb2,SAMPreb1,SAMPreb2,Wkernelb)
%
%       FILE NAME       : WIENER KERNEL SAM VALIDATE 2
%       DESCRIPTION     : Used to validata responses for SAM data using a
%                         generalized second order nonlinearmodel. See
%                         WIENERKERNELENVBOOT2. 
%
%                         Assumes that the data was bootstrapped for each
%                         half of the data.
%
%       MTFb            : Bootstrapped modulation transfer function data
%                         structure (see MTFGENERATEBOOT2)
%       SAMPreb         : Bootstrapped model Prediction data structure
%                         (see WIENERKERNELSAMPREBOOT)
%       Wkernelb        : Bootstrapped winer kernel (Optional)
%                         (see WIENERKERNELENVBOOT)
%
%RETURNED VARIABLES
%
%       SAMValData      : Structure containing validation results
%
%       .CorrModel1     - Correlation coefficient results for model 1
%       .CorrModel2     - Correlation coefficient results for model 2
%       .Model1Param    - Parameters for model 1
%       .Model2Param    - Parameters for model 2
%       .ResponseParam  - Response Prameters
%           .rBMF       - Rate BMF
%           .rCMF       - Rate CMF
%           .rCMF2      - Rate CMF, minimum removed
%           .vsBMF      - Vector strneght BMF
%           .vsCMF      - Vector strength CMF
%           .vsCMF2     - Vector strnehgt CMF, minimum removed
%           .srBMF      - Sync rate BMF
%           .srCMF      - Sync rate CMF
%           .srCMF2     - Sync rate CMF, minimum removed
%           .PLI        - Phase locking index (Only if Wkernelb provided)
%                                   
%   (C) Monty A. Escabi, Feb 2012
%
function [SAMValData2]=wienerkernelsamvalidate2(MTFb1,MTFb2,SAMPreb1,SAMPreb2,Wkernelb)

%Modulation Freq. Axis
FMAxis=SAMPreb1(1).MTF.FMAxis;

%Correlation coefficients for 1st order Linear-Nonliner model
CC=corrcoef(MTFb1.Rate,[SAMPreb1(1).MTF.Rate1nl]);
SAMValData2.CorrModel1.CC_rate=CC(1,2);
CC=corrcoef(MTFb1.VS,[SAMPreb1(1).MTF.VS1nl]);
SAMValData2.CorrModel1.CC_vs=CC(1,2);
CC=corrcoef(MTFb1.VS.*MTFb1.Rate,[SAMPreb1(1).MTF.VS1nl].*[SAMPreb1(1).MTF.Rate1nl]);
SAMValData2.CorrModel1.CC_sr=CC(1,2);
CC=corrcoef(MTFb1.CycleHist,[SAMPreb1(1).CycleHist.Y1nl]);
SAMValData2.CorrModel1.CC_cyclehist=CC(1,2);
for k=1:size(MTFb1.CycleHist,2);
    CC=corrcoef(MTFb1.CycleHist(:,k),[SAMPreb1(1).CycleHist.Y1nl(:,k)]);
    SAMValData2.CorrModel1.CC_cyclehistFm(k)=CC(1,2);
end

%Correlation coefficients for 2nd order Linear-Nonliner model
CC=corrcoef(MTFb1.Rate,[SAMPreb1(1).MTF.Ratetot]);
SAMValData2.CorrModel2.CC_rate=CC(1,2);
CC=corrcoef(MTFb1.VS,[SAMPreb1(1).MTF.VStot]);
SAMValData2.CorrModel2.CC_vs=CC(1,2);
CC=corrcoef(MTFb1.VS.*MTFb1.Rate,[SAMPreb1(1).MTF.VStot].*[SAMPreb1(1).MTF.Ratetot]);
SAMValData2.CorrModel2.CC_sr=CC(1,2);
CC=corrcoef(MTFb1.CycleHist,[SAMPreb1(1).CycleHist.Ytot]);
SAMValData2.CorrModel2.CC_cyclehist=CC(1,2);
for k=1:size(MTFb1.CycleHist,2);
    CC=corrcoef(MTFb1.CycleHist(:,k),[SAMPreb1(1).CycleHist.Ytot(:,k)]);
    SAMValData2.CorrModel2.CC_cyclehistFm(k)=CC(1,2);
end

%Correlation coefficient between model1 and model1
Rate1=[];
Rate2=[];
VS1=[];
VS2=[];
CycleHist1=[];
CycleHist2=[];
CycleHistb1=[];
CycleHistb2=[];
for k=2:length(SAMPreb1)
   Rate1=[Rate1 SAMPreb1(k).MTF.Rate1nl];
   Rate2=[Rate2 SAMPreb2(k).MTF.Rate1nl];
   VS1=[VS1 SAMPreb1(k).MTF.VS1nl];
   VS2=[VS2 SAMPreb2(k).MTF.VS1nl];
   CycleHist1=[CycleHist1 reshape(SAMPreb1(k).CycleHist.Y1nl,1,numel(SAMPreb1(k).CycleHist.Y1nl))]; 
   CycleHist2=[CycleHist2 reshape(SAMPreb2(k).CycleHist.Y1nl,1,numel(SAMPreb2(k).CycleHist.Y1nl))];
   CycleHistb1(:,:,k)=SAMPreb1(k).CycleHist.Y1nl; 
   CycleHistb2(:,:,k)=SAMPreb2(k).CycleHist.Y1nl;
end
CC=corrcoef(Rate1,Rate2);
SAMValData2.CorrModel11.CC_rate=CC(1,2);
CC=corrcoef(VS1,VS2);
SAMValData2.CorrModel11.CC_vs=CC(1,2);
CC=corrcoef(Rate1.*VS1,Rate2.*VS2);
SAMValData2.CorrModel11.CC_sr=CC(1,2);
CC=corrcoef(CycleHist1,CycleHist2);
SAMValData2.CorrModel11.CC_cyclehist=CC(1,2);
for k=2:size(CycleHistb1,2);
    CC=corrcoef(CycleHistb1(:,k,:),CycleHistb2(:,k,:));
    SAMValData2.CorrModel11.CC_cyclehistFm(k)=CC(1,2);
end

%Correlation coefficient between model2 and model2
Rate1=[];
Rate2=[];
VS1=[];
VS2=[];
CycleHist1=[];
CycleHist2=[];
CycleHistb1=[];
CycleHistb2=[];
for k=2:length(SAMPreb1)
   Rate1=[Rate1 SAMPreb1(k).MTF.Ratetot];
   Rate2=[Rate2 SAMPreb2(k).MTF.Ratetot];
   VS1=[VS1 SAMPreb1(k).MTF.VStot];
   VS2=[VS2 SAMPreb2(k).MTF.VStot];
   CycleHist1=[CycleHist1 reshape(SAMPreb1(k).CycleHist.Ytot,1,numel(SAMPreb1(k).CycleHist.Ytot))]; 
   CycleHist2=[CycleHist2 reshape(SAMPreb2(k).CycleHist.Ytot,1,numel(SAMPreb2(k).CycleHist.Ytot))];
   CycleHistb1(:,:,k)=SAMPreb1(k).CycleHist.Ytot; 
   CycleHistb2(:,:,k)=SAMPreb2(k).CycleHist.Ytot;
end
CC=corrcoef(Rate1,Rate2);
SAMValData2.CorrModel22.CC_rate=CC(1,2);
CC=corrcoef(VS1,VS2);
SAMValData2.CorrModel22.CC_vs=CC(1,2);
CC=corrcoef(Rate1.*VS1,Rate2.*VS2);
SAMValData2.CorrModel22.CC_sr=CC(1,2);
CC=corrcoef(CycleHist1,CycleHist2);
SAMValData2.CorrModel22.CC_cyclehist=CC(1,2);
for k=2:size(CycleHistb1,2);
    CC=corrcoef(CycleHistb1(:,k,:),CycleHistb2(:,k,:));
    SAMValData2.CorrModel22.CC_cyclehistFm(k)=CC(1,2);
end

%Correlation Coefficient between response and response
CC=corrcoef(MTFb1.Rateb,MTFb2.Rateb);
SAMValData2.CorrResponse12.CC_rate=CC(1,2);
X=reshape(MTFb1.Rateb,1,numel(MTFb1.Rateb));
Y=reshape(MTFb2.Rateb,1,numel(MTFb2.Rateb));
X=X-mean(X);
Y=Y-mean(Y);
SAMValData2.CorrResponse12.CC_rate_corrected=sqrt(abs(sum(X.*Y))/(length(X)-1))/sqrt((var(X)+var(Y))/2);
CC=corrcoef(MTFb1.VSb,MTFb2.VSb);
SAMValData2.CorrResponse12.CC_vs=CC(1,2);
X=reshape(MTFb1.VSb,1,numel(MTFb1.VSb));
Y=reshape(MTFb2.VSb,1,numel(MTFb2.VSb));
X=X-mean(X);
Y=Y-mean(Y);
SAMValData2.CorrResponse12.CC_vs_corrected=sqrt(abs(sum(X.*Y))/(length(X)-1))/sqrt((var(X)+var(Y))/2);
CC=corrcoef(MTFb1.Rateb.*MTFb1.VSb,MTFb2.Rateb.*MTFb2.VSb);
SAMValData2.CorrResponse12.CC_sr=CC(1,2);
X=reshape(MTFb1.VSb.*MTFb1.Rateb,1,numel(MTFb1.VSb));
Y=reshape(MTFb2.VSb.*MTFb2.Rateb,1,numel(MTFb2.VSb));
X=X-mean(X);
Y=Y-mean(Y);
SAMValData2.CorrResponse12.CC_sr_corrected=sqrt(abs(sum(X.*Y))/(length(X)-1))/sqrt((var(X)+var(Y))/2);
N=numel(MTFb1.CycleHistb);
CC=corrcoef(reshape(MTFb1.CycleHistb,1,N),reshape(MTFb2.CycleHistb,1,N));
SAMValData2.CorrResponse12.CC_cyclehist=CC(1,2);
X=reshape(MTFb1.CycleHistb,1,N);
Y=reshape(MTFb2.CycleHistb,1,N);
X=X-mean(X);
Y=Y-mean(Y);
SAMValData2.CorrResponse12.CC_cyclehist_corrected=sqrt(abs(sum(X.*Y))/(length(X)-1))/sqrt((var(X)+var(Y))/2);
for l=1:size(MTFb1.CycleHist,2);
    N=numel(MTFb1.CycleHistb(:,1,:));
    CC=corrcoef(reshape([MTFb1.CycleHistb(:,l,:)],1,N),reshape([MTFb2.CycleHistb(:,l,:)],1,N));
    SAMValData2.CorrResponse12.CC_cyclehistFm(l)=CC(1,2);
    X=reshape([MTFb1.CycleHistb(:,l,:)],1,N);
    Y=reshape([MTFb2.CycleHistb(:,l,:)],1,N);
    X=X-mean(X);
    Y=Y-mean(Y);
    SAMValData2.CorrResponse12.CC_cyclehistFm_corrected(l)=sqrt(abs(sum(X.*Y))/(length(X)-1))/sqrt((var(X)+var(Y))/2);
end

%Rate BMF and CMF
R=MTFb1.Rate;
Rm1=[SAMPreb1(1).MTF.Rate1nl];
Rm2=[SAMPreb1(1).MTF.Ratetot];
i=min(find(max(Rm1)==Rm1));
SAMValData2.Model1Param.rBMF=FMAxis(i);
i=min(find(max(Rm2)==Rm2));
SAMValData2.Model2Param.rBMF=FMAxis(i);
i=min(find(max(R)==R));
SAMValData2.ResponseParam.rBMF=FMAxis(i);
SAMValData2.Model1Param.rCMF=sum(FMAxis.*Rm1/sum(Rm1));
SAMValData2.Model2Param.rCMF=sum(FMAxis.*Rm2/sum(Rm2));
SAMValData2.ResponseParam.rCMF=sum(FMAxis.*R/sum(R));
R=R-min(R);
Rm1=Rm1-min(Rm1);
Rm2=Rm2-min(Rm2);
SAMValData2.Model1Param.rCMF2=sum(FMAxis.*(Rm1/sum(Rm1)));
SAMValData2.Model2Param.rCMF2=sum(FMAxis.*Rm2/sum(Rm2));
SAMValData2.ResponseParam.rCMF2=sum(FMAxis.*R/sum(R));

%Sync BMF and CMF
VS=MTFb1.VS;
VSm1=[SAMPreb1(1).MTF.VS1nl];
VSm2=[SAMPreb1(1).MTF.VStot];
i=min(find(max(VSm1)==VSm1));
SAMValData2.Model1Param.vsBMF=FMAxis(i);
i=min(find(max(VSm2)==VSm2));
SAMValData2.Model2Param.vsBMF=FMAxis(i);
i=min(find(max(VS)==VS));
SAMValData2.ResponseParam.vsBMF=FMAxis(i);
SAMValData2.Model1Param.vsCMF=sum(FMAxis.*VSm1/sum(VSm1));
SAMValData2.Model2Param.vsCMF=sum(FMAxis.*VSm2/sum(VSm2));
SAMValData2.ResponseParam.vsCMF=sum(FMAxis.*VS/sum(VS));
VS=VS-min(VS);
VSm1=VSm1-min(VSm1);
VSm2=VSm2-min(VSm2);
SAMValData2.Model1Param.vsCMF2=sum(FMAxis.*(VSm1/sum(VSm1)));
SAMValData2.Model2Param.vsCMF2=sum(FMAxis.*VSm2/sum(VSm2));
SAMValData2.ResponseParam.vsCMF2=sum(FMAxis.*VS/sum(VS));

%Sync-Rate BMF and CMF
SR=MTFb1.Rate.*MTFb1.VS;
SRm1=[SAMPreb1(1).MTF.Rate1nl].*[SAMPreb1(1).MTF.VS1nl];
SRm2=[SAMPreb1(1).MTF.Ratetot].*[SAMPreb1(1).MTF.VStot];
i=min(find(max(SRm1)==SRm1));
SAMValData2.Model1Param.srBMF=FMAxis(i);
i=min(find(max(SRm2)==SRm2));
SAMValData2.Model2Param.srBMF=FMAxis(i);
i=min(find(SR==max(SR)));
SAMValData2.ResponseParam.srBMF=FMAxis(i);
SAMValData2.Model1Param.srCMF=sum(FMAxis.*SRm1/sum(SRm1));
SAMValData2.Model2Param.srCMF=sum(FMAxis.*SRm2/sum(SRm2));
SAMValData2.ResponseParam.srCMF=sum(FMAxis.*SR/sum(SR));
SR=SR-min(SR);
SRm1=SRm1-min(SRm1);
SRm2=SRm2-min(SRm2);
SAMValData2.Model1Param.srCMF2=sum(FMAxis.*(SRm1/sum(SRm1)));
SAMValData2.Model2Param.srCMF2=sum(FMAxis.*SRm2/sum(SRm2));
SAMValData2.ResponseParam.srCMF2=sum(FMAxis.*SR/sum(SR));

%Phase locking index
if exist('Wkernelb')
   SAMValData2.ResponseParam.PLI=(max(Wkernelb(1).k1)-min(Wkernelb(1).k1)).*sqrt(Wkernelb(1).Varxx)/Wkernelb(1).k0/sqrt(12); 
end