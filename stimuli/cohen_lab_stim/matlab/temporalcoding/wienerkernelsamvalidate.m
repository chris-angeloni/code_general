%
%[SAMValData]=wienerkernelsamvalidate(MTFb,SAMPreb,Wkernelb)
%
%       FILE NAME       : WIENER KERNEL SAM VALIDATE
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994
%
%       MTFb            : Bootstrapped modulation transfer function data
%                         structure (see MTFGENERATEBOOT)
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
function [SAMValData]=wienerkernelsamvalidate(MTFb,SAMPreb,Wkernelb)

%Modulation Freq. Axis
FMAxis=SAMPreb(1).MTF.FMAxis;

%Correlation coefficients for 1st order Linear-Nonliner model
CC=corrcoef(MTFb.Rate,[SAMPreb(1).MTF.Rate1nl]);
SAMValData.CorrModel1.CC_rate=CC(1,2);
CC=corrcoef(MTFb.VS,[SAMPreb(1).MTF.VS1nl]);
SAMValData.CorrModel1.CC_vs=CC(1,2);
CC=corrcoef(MTFb.VS.*MTFb.Rate,[SAMPreb(1).MTF.VS1nl].*[SAMPreb(1).MTF.Rate1nl]);
SAMValData.CorrModel1.CC_sr=CC(1,2);
CC=corrcoef(MTFb.CycleHist,[SAMPreb(1).CycleHist.Y1nl]);
SAMValData.CorrModel1.CC_cyclehist=CC(1,2);
for k=1:size(MTFb.CycleHist,2);
    CC=corrcoef(MTFb.CycleHist(:,k),[SAMPreb(1).CycleHist.Y1nl(:,k)]);
    SAMValData.CorrModel1.CC_cyclehistFm(k)=CC(1,2);
end

%Correlation coefficients for 2nd order Linear-Nonliner model
CC=corrcoef(MTFb.Rate,[SAMPreb(1).MTF.Ratetot]);
SAMValData.CorrModel2.CC_rate=CC(1,2);
CC=corrcoef(MTFb.VS,[SAMPreb(1).MTF.VStot]);
SAMValData.CorrModel2.CC_vs=CC(1,2);
CC=corrcoef(MTFb.VS.*MTFb.Rate,[SAMPreb(1).MTF.VStot].*[SAMPreb(1).MTF.Ratetot]);
SAMValData.CorrModel2.CC_sr=CC(1,2);
CC=corrcoef(MTFb.CycleHist,[SAMPreb(1).CycleHist.Ytot]);
SAMValData.CorrModel2.CC_cyclehist=CC(1,2);
for k=1:size(MTFb.CycleHist,2);
    CC=corrcoef(MTFb.CycleHist(:,k),[SAMPreb(1).CycleHist.Ytot(:,k)]);
    SAMValData.CorrModel2.CC_cyclehistFm(k)=CC(1,2);
end

%Corrected Correlation Coefficient for 1st order Linear-Nonlinear model
VarXn=mean(var(MTFb.Rateb,[],2));
for k=1:length(SAMPreb)-1, Rate(:,k)=SAMPreb(k+1).MTF.Rate1nl';, end
VarYn=mean(var(Rate,[],2));
X=MTFb.Rate;
Y=[SAMPreb(1).MTF.Rate1nl];
N=length(X);
SAMValData.CorrModel1.CC_rate_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

VarXn=mean(var(MTFb.VSb,[],2));
for k=1:length(SAMPreb)-1, VS(:,k)=SAMPreb(k+1).MTF.VS1nl';, end
VarYn=mean(var(VS,[],2));
X=MTFb.VS;
Y=[SAMPreb(1).MTF.VS1nl];
N=length(X);
SAMValData.CorrModel1.CC_vs_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

VarXn=mean(var(MTFb.VSb.*MTFb.Rateb,[],2));
for k=1:length(SAMPreb)-1, SR(:,k)=SAMPreb(k+1).MTF.VS1nl'.*SAMPreb(k+1).MTF.Rate1nl';, end
VarYn=mean(var(SR,[],2));
X=MTFb.VS.*MTFb.Rate;
Y=[SAMPreb(1).MTF.VS1nl].*[SAMPreb(1).MTF.Rate1nl];
N=length(X);
SAMValData.CorrModel1.CC_sr_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

VarXn=mean(reshape(var(MTFb.CycleHistb,[],3),1,numel(MTFb.CycleHist)));
for k=1:length(SAMPreb)-1, CH(:,:,k)=SAMPreb(k+1).CycleHist.Y1nl;, end
VarYn=mean(reshape(var(CH,[],3),1,numel(squeeze(CH(:,:,1)))));
X=reshape(MTFb.CycleHist,1,numel(MTFb.CycleHist));
Y=reshape([SAMPreb(1).CycleHist.Y1nl],1,numel([SAMPreb(1).CycleHist.Y1nl]));
N=length(X);
SAMValData.CorrModel1.CC_cyclehist_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

for k=1:size(MTFb.CycleHistb,2);
    VarXn=mean(var(MTFb.CycleHistb(:,k,:),[],3));
    for l=1:length(SAMPreb)-1, CH(:,:,l)=SAMPreb(l+1).CycleHist.Y1nl;, end
    VarYn=mean(var(CH(:,k,:),[],3));
    X=MTFb.CycleHist(:,k)';
    Y=[SAMPreb(1).CycleHist.Y1nl(:,k)'];
    N=length(X);
    SAMValData.CorrModel1.CC_cyclehistFm_corrected(k)=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt(abs((var(X)-VarXn) * (var(Y)-VarYn)));
end

%Corrected Correlation Coefficient for 2nd order Linear-Nonlinear model
VarXn=mean(var(MTFb.Rateb,[],2));
for k=1:length(SAMPreb)-1, Rate(:,k)=SAMPreb(k+1).MTF.Ratetot';, end
VarYn=mean(var(Rate,[],2));
X=MTFb.Rate;
Y=[SAMPreb(1).MTF.Ratetot];
N=length(X);
SAMValData.CorrModel2.CC_rate_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

VarXn=mean(var(MTFb.VSb,[],2));
for k=1:length(SAMPreb)-1, VS(:,k)=SAMPreb(k+1).MTF.VStot';, end
VarYn=mean(var(VS,[],2));
X=MTFb.VS;
Y=[SAMPreb(1).MTF.VStot];
N=length(X);
SAMValData.CorrModel2.CC_vs_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

VarXn=mean(var(MTFb.VSb.*MTFb.Rateb,[],2));
for k=1:length(SAMPreb)-1, SR(:,k)=SAMPreb(k+1).MTF.VStot'.*SAMPreb(k+1).MTF.Ratetot';, end
VarYn=mean(var(SR,[],2));
X=MTFb.VS.*MTFb.Rate;
Y=[SAMPreb(1).MTF.VStot].*[SAMPreb(1).MTF.Ratetot];
N=length(X);
SAMValData.CorrModel2.CC_sr_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

VarXn=mean(reshape(var(MTFb.CycleHistb,[],3),1,numel(MTFb.CycleHist)));
for k=1:length(SAMPreb)-1, CH(:,:,k)=SAMPreb(k+1).CycleHist.Ytot;, end
VarYn=mean(reshape(var(CH,[],3),1,numel(squeeze(CH(:,:,1)))));
X=reshape(MTFb.CycleHist,1,numel(MTFb.CycleHist));
Y=reshape([SAMPreb(1).CycleHist.Ytot],1,numel([SAMPreb(1).CycleHist.Ytot]));
N=length(X);
SAMValData.CorrModel2.CC_cyclehist_corrected=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt((var(X)-VarXn) * (var(Y)-VarYn));

for k=1:size(MTFb.CycleHistb,2);
    VarXn=mean(var(MTFb.CycleHistb(:,k,:),[],3));
    for l=1:length(SAMPreb)-1, CH(:,:,l)=SAMPreb(l+1).CycleHist.Ytot;, end
    VarYn=mean(var(CH(:,k,:),[],3));
    X=MTFb.CycleHist(:,k)';
    Y=[SAMPreb(1).CycleHist.Ytot(:,k)'];
    N=length(X);
    SAMValData.CorrModel2.CC_cyclehistFm_corrected(k)=N/(N-1)*mean((X-mean(X)).*(Y-mean(Y)))/sqrt(abs((var(X)-VarXn) * (var(Y)-VarYn)));
end

% %Rate BMF and CMF
% i=find(max([SAMPreb(1).MTF.Rate1nl])==[SAMPreb(1).MTF.Rate1nl]);
% SAMValData.Model1Param.rBMF=FMAxis(i);
% i=find(max([SAMPreb(1).MTF.Ratetot])==[SAMPreb(1).MTF.Ratetot]);
% SAMValData.Model2Param.rBMF=FMAxis(i);
% i=find(max(MTFb.Rate)==MTFb.Rate);
% SAMValData.ResponseParam.rBMF=FMAxis(i);
% SAMValData.Model1Param.rCMF=sum(FMAxis.*[SAMPreb(1).MTF.Rate1nl]/sum([SAMPreb(1).MTF.Rate1nl]));
% SAMValData.Model2Param.rCMF=sum(FMAxis.*[SAMPreb(1).MTF.Ratetot]/sum([SAMPreb(1).MTF.Ratetot]));
% SAMValData.ResponseParam.rCMF=sum(FMAxis.*MTFb.Rate/sum(MTFb.Rate));
% 
% %Sync BMF and CMF
% i=find(max([SAMPreb(1).MTF.VS1nl])==[SAMPreb(1).MTF.VS1nl]);
% SAMValData.Model1Param.vsBMF=FMAxis(i);
% i=find(max([SAMPreb(1).MTF.VStot])==[SAMPreb(1).MTF.VStot]);
% SAMValData.Model2Param.vsBMF=FMAxis(i);
% i=find(max(MTFb.VS)==max(MTFb.VS));
% SAMValData.ResponseParam.vsBMF=FMAxis(i);
% SAMValData.Model1Param.vsCMF=sum(FMAxis.*[SAMPreb(1).MTF.VS1nl]/sum([SAMPreb(1).MTF.VS1nl]));
% SAMValData.Model2Param.vsCMF=sum(FMAxis.*[SAMPreb(1).MTF.VStot]/sum([SAMPreb(1).MTF.VStot]));
% SAMValData.ResponseParam.vsCMF=sum(FMAxis.*MTFb.VS/sum(MTFb.VS));
% 
% %Sync-Rate BMF and CMF
% SR=MTFb.Rate.*MTFb.VS;
% SRm1=[SAMPreb(1).MTF.Rate1nl].*[SAMPreb(1).MTF.VS1nl];
% SRm2=[SAMPreb(1).MTF.Ratetot].*[SAMPreb(1).MTF.VStot];
% i=find(max(SRm1)==SRm1);
% SAMValData.Model1Param.srBMF=FMAxis(i);
% i=find(max(SRm2)==SRm2);
% SAMValData.Model2Param.srBMF=FMAxis(i);
% i=find(SR==max(SR));
% SAMValData.ResponseParam.srBMF=FMAxis(i);
% SAMValData.Model1Param.srCMF=sum(FMAxis.*SRm1/sum(SRm1));
% SAMValData.Model2Param.srCMF=sum(FMAxis.*SRm2/sum(SRm2));
% SAMValData.ResponseParam.srCMF=sum(FMAxis.*SR/sum(SR));

%Rate BMF and CMF
R=MTFb.Rate;
Rm1=[SAMPreb(1).MTF.Rate1nl];
Rm2=[SAMPreb(1).MTF.Ratetot];
i=find(max(Rm1)==Rm1);
SAMValData.Model1Param.rBMF=FMAxis(i);
i=find(max(Rm2)==Rm2);
SAMValData.Model2Param.rBMF=FMAxis(i);
i=find(max(R)==R);
SAMValData.ResponseParam.rBMF=FMAxis(i);
SAMValData.Model1Param.rCMF=sum(FMAxis.*Rm1/sum(Rm1));
SAMValData.Model2Param.rCMF=sum(FMAxis.*Rm2/sum(Rm2));
SAMValData.ResponseParam.rCMF=sum(FMAxis.*R/sum(R));
R=R-min(R);
Rm1=Rm1-min(Rm1);
Rm2=Rm2-min(Rm2);
SAMValData.Model1Param.rCMF2=sum(FMAxis.*(Rm1/sum(Rm1)));
SAMValData.Model2Param.rCMF2=sum(FMAxis.*Rm2/sum(Rm2));
SAMValData.ResponseParam.rCMF2=sum(FMAxis.*R/sum(R));

%Sync BMF and CMF
VS=MTFb.VS;
VSm1=[SAMPreb(1).MTF.VS1nl];
VSm2=[SAMPreb(1).MTF.VStot];
i=find(max(VSm1)==VSm1);
SAMValData.Model1Param.vsBMF=FMAxis(i);
i=find(max(VSm2)==VSm2);
SAMValData.Model2Param.vsBMF=FMAxis(i);
i=find(max(VS)==VS);
SAMValData.ResponseParam.vsBMF=FMAxis(i);
SAMValData.Model1Param.vsCMF=sum(FMAxis.*VSm1/sum(VSm1));
SAMValData.Model2Param.vsCMF=sum(FMAxis.*VSm2/sum(VSm2));
SAMValData.ResponseParam.vsCMF=sum(FMAxis.*VS/sum(VS));
VS=VS-min(VS);
VSm1=VSm1-min(VSm1);
VSm2=VSm2-min(VSm2);
SAMValData.Model1Param.vsCMF2=sum(FMAxis.*(VSm1/sum(VSm1)));
SAMValData.Model2Param.vsCMF2=sum(FMAxis.*VSm2/sum(VSm2));
SAMValData.ResponseParam.vsCMF2=sum(FMAxis.*VS/sum(VS));

%Sync-Rate BMF and CMF
SR=MTFb.Rate.*MTFb.VS;
SRm1=[SAMPreb(1).MTF.Rate1nl].*[SAMPreb(1).MTF.VS1nl];
SRm2=[SAMPreb(1).MTF.Ratetot].*[SAMPreb(1).MTF.VStot];
i=find(max(SRm1)==SRm1);
SAMValData.Model1Param.srBMF=FMAxis(i);
i=find(max(SRm2)==SRm2);
SAMValData.Model2Param.srBMF=FMAxis(i);
i=find(SR==max(SR));
SAMValData.ResponseParam.srBMF=FMAxis(i);
SAMValData.Model1Param.srCMF=sum(FMAxis.*SRm1/sum(SRm1));
SAMValData.Model2Param.srCMF=sum(FMAxis.*SRm2/sum(SRm2));
SAMValData.ResponseParam.srCMF=sum(FMAxis.*SR/sum(SR));
SR=SR-min(SR);
SRm1=SRm1-min(SRm1);
SRm2=SRm2-min(SRm2);
SAMValData.Model1Param.srCMF2=sum(FMAxis.*(SRm1/sum(SRm1)));
SAMValData.Model2Param.srCMF2=sum(FMAxis.*SRm2/sum(SRm2));
SAMValData.ResponseParam.srCMF2=sum(FMAxis.*SR/sum(SR));

%Phase locking index
if exist('Wkernelb')
   SAMValData.ResponseParam.PLI=(max(Wkernelb(1).k1)-min(Wkernelb(1).k1)).*sqrt(Wkernelb(1).Varxx)/Wkernelb(1).k0/sqrt(12); 
end