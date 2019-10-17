%
%function [SAMPreData]=wienerkernelsamvalidate(Wkernel,SoundParam,Fm,Beta,Ncyc,Disp)
%
%       FILE NAME       : WIENER KERNEL SAM VALIDATE
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994
%
%       Wkernel         : Structure containing kernels for 2 input channels
%                         along with estimated spiking nonlinearities. See
%                         WIENERKERNELENV2INPUT for details.
%       SoundParam      : Data structure containing sound parameters
%       Fm              : Modulation frequency vector (e.g, [2 4 8 16 ...])
%       Beta            : Modualtion index (1)
%       Ncyc            : Number of cycles for simulation  (2 or 4)
%       Disp            : Display output ('y' or 'n'; Defaul=='n')
%
%RETURNED VARIABLES
%
%       PreData         : Structure containing prediction results
%
%                         .Y1       - Predicted 1st-order output for channel 1
%                         .Y2       - Predicted 1st-order output for channel 2
%                         .Y1nl     - Predicted nonlinear output for channel 1
%                         .Y2nl     - Predicted nonlinear output for channel 2
%                         .Ytot     - Total combined output for channel 1 
%                                     and 2. Linear and nonlinear output
%                                     including the output nonlinearity (F).
%          
%   (C) Monty A. Escabi, Nov 2011
%
function [SAMValData]=wienerkernelsamvalidate(Wkernel,SoundParam,SAMRAS,FMAxis,Beta,Ncyc,Mcyc,Disp)


Fsd=4800
OnsetT=0
[SAMPreData]=wienerkernelsampre(Wkernel,SoundParam,FMAxis,Beta,Ncyc,Mcyc,'n');

[MTF] = mtfgenerate(SAMRAS,Fsd,FMAxis,OnsetT);
%[MTF2] = mtfgenerate(SAMRAS(2:2:end),Fsd,FMAxis,OnsetT);

figure
semilogx(MTF.FMAxis,MTF.VS.*MTF.Rate)
hold on
%semilogx(MTF2.FMAxis,MTF2.VS.*MTF2.Rate,'r')
semilogx(MTF.FMAxis,[SAMPreData.Rate].*[SAMPreData.VS],'r')

%Correaltion coefficient comparing rate, sync-rate, and sync
CC_rate=corrcoef(MTF.Rate,[SAMPreData.Rate]);
CC_vs=corrcoef(MTF.VS,[SAMPreData.VS]);
CC_sr=corrcoef(MTF.VS.*MTF.Rate,[SAMPreData.VS].*[SAMPreData.Rate]);
SAMValData.CC_rate=CC_rate(1,2);
SAMValData.CC_vs=CC_vs(1,2);
SAMValData.CC_sr=CC_sr(1,2);

%Rate BMF and CMF
i=find(max(MTF.Rate)==MTF.Rate);
SAMValData.Response.rBMF=FMAxis(i);
i=find(max([SAMPreData.Rate])==[SAMPreData.Rate]);
SAMValData.Model.rBMF=FMAxis(i);
SAMValData.Response.rCMF=sum(FMAxis.*MTF.Rate/sum(MTF.Rate));
SAMValData.Model.rCMF=sum(FMAxis.*[SAMPreData.Rate]/sum([SAMPreData.Rate]));

%Sync BMF and CMF
i=find(max(MTF.VS)==max(MTF.VS));
SAMValData.Response.vsBMF=FMAxis(i);
i=find(max([SAMPreData.VS])==[SAMPreData.VS]);
SAMValData.Model.vsBMF=FMAxis(i);
SAMValData.Response.vsCMF=sum(FMAxis.*MTF.VS/sum(MTF.VS));
SAMValData.Model.vsCMF=sum(FMAxis.*[SAMPreData.VS]/sum([SAMPreData.VS]));

%Sync-Rate BMF and CMF
SR=MTF.Rate.*MTF.VS;
SRm=[SAMPreData.Rate].*[SAMPreData.VS];
i=find(SR==max(SR));
SAMValData.Response.srBMF=FMAxis(i);
i=find(max(SRm)==SRm);
SAMValData.Model.srBMF=FMAxis(i);
SAMValData.Response.srCMF=sum(FMAxis.*SR/sum(SR));
SAMValData.Model.srCMF=sum(FMAxis.*SR/sum(SR));





%.62*sqrt(1238)/sqrt(1238-291)
Var_n=var(reshape(CycleHist1-CycleHist2,1,numel(CycleHist1)))/2;
Var_sn=var(reshape(CycleHist,1,numel(CycleHist)));
%CC_cychist_c=CC_cychist*sqrt(Var_sn1)/sqrt(Var_sn-Var_n)
