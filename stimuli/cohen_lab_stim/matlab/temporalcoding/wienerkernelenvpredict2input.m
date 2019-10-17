%
%function [PreData]=wienerkernelenvpredict2input(Wkernel,SoundPreEnv,SoundParam)
%
%       FILE NAME       : WIENER KERNEL ENV PREDICT 2 INPUT
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994
%
%       Wkernel         : Structure containing 1st and 2nd order kernels
%                         along with estimated spiking nonlinearities. See
%                         WIENERKERNELENV2INPUT for details.
%       SoundPreEnv     : Data structure containing the prediction
%                         envelopes for channel 1 and 2
%
%                         .Env1 - Channel 1 envelope (in dB)
%                         .Env2 - Channel 2 envelope (in dB)
%       SoundParam      : Data structure containing sound parameters
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
function [PreData]=wienerkernelenvpredict2input(Wkernel,SoundPreEnv,SoundParam)

%Sound Prediction Envelope in dB
X1=SoundPreEnv.Env1;
X2=SoundPreEnv.Env2;

%Linear Prediction Input 1
dt=1/(SoundParam.Fs/Wkernel.DF/SoundParam.DS);
Fs=1/dt;
Y1=conv(Wkernel.k1_1,X1);

%Linear Prediction Input 2
dt=1/(SoundParam.Fs/Wkernel.DF/SoundParam.DS);
Fs=1/dt;
Y2=conv(Wkernel.k1_2,X2);

%Applying Output 2-Input Nonlinearity - check out paper by Atencio,
%Sharpe et al.
N1=size(Wkernel.F,1);
N2=size(Wkernel.F,2);
Y1index=ceil((Y1-min(Wkernel.Y1prior) )/mean(diff(Wkernel.y1)));
Y1index=max(1,Y1index);
Y1index=min(N2,Y1index);
Y2index=ceil((Y2-min(Wkernel.Y2prior) )/mean(diff(Wkernel.y2)));
Y2index=max(1,Y2index);
Y2index=min(N1,Y2index);
for k=1:length(Y1index)
        Ytot(k)=Wkernel.F(Y2index(k),Y1index(k));
        Y1nl(k)=Wkernel.F1(Y1index(k));
        Y2nl(k)=Wkernel.F2(Y2index(k));
end
i=find(isnan(Ytot));

for k=1:length(i)       %Median filter on output with NaN; removes artifacts from NaN
    YY=Ytot(max(i(k)-3,1):min(i(k)+3,end));
    index=find(~isnan(YY));
    Ytot(i(k))=median(YY(index));
end


% %Generating PSTH and RASTERS
% RASPre=rasterexpand(RASData.Pre,Fs);
% N=floor(size(RASPre,1)/2);
% Wkernel.PSTH=mean(RASPre);
% Wkernel.PSTH1=mean(RASPre(1:2:end,:));  %Odd trials
% Wkernel.PSTH2=mean(RASPre(2:2:end,:));  %Even trials
% 

%Adding predictions to data structure
% Wkernel.Y1=Y1(1:length(Wkernel.PSTH));
% Wkernel.Y2=Y2(1:length(Wkernel.PSTH));
% Wkernel.Ytot=Ytot(1:length(Wkernel.PSTH));
PreData.Y1=Y1;
PreData.Y2=Y2;
PreData.Ytot=Ytot;
PreData.Y1nl=Y1nl;
PreData.Y2nl=Y2nl;
PreData.T=(1:length(Y1))/(Wkernel.Fs/Wkernel.DF/Wkernel.DS);
% 
% %Corrected correlation Coefficient
% L=100;
% Ymodel=Wkernel.Ytot-mean(Wkernel.Ytot);
% Ylin=Wkernel.Y1-mean(Wkernel.Y1);
% PSTH1=Wkernel.PSTH1;
% PSTH1=PSTH1-mean(PSTH1);
% PSTH2=Wkernel.PSTH2;
% PSTH2=PSTH2-mean(PSTH2);
% N=length(Ymodel);
% Rm2=xcorr(Ymodel,PSTH2,L)/(N-1);
% Rl2=xcorr(Ylin,PSTH2,L)/(N-1);
% R12=xcorr(PSTH1,PSTH2,L)/(N-1);
% Var1=var(PSTH1)-var(PSTH1-PSTH2)/2;
% Var2=var(PSTH2)-var(PSTH1-PSTH2)/2;
% Var=(Var1+Var2)/2;                      %Response variance
% Varm=var(Ymodel);                       %Full model variance
% Varl=var(Ylin);                         %Linear model variance
% Wkernel.Rm2=Rm2/sqrt(Varm*Var);         %Corrected correlation full model vers PSTH2
% Wkernel.Rl2=Rl2/sqrt(Varl*Var);         %Corrected correlation linear model vers PSTH2
% Wkernel.R12=R12/sqrt(Var1*Var2);        %Corrected correlation PSTH1 versus PSTH2
% Wkernel.CCm2=Wkernel.Rm2(L+1);          %Corrected correlation coef full model versus PSTH2
% Wkernel.CCl2=Wkernel.Rl2(L+1);          %Corrected correlation coef linear model versus PSTH2
% Wkernel.CC12=Wkernel.R12(L+1);          %Corrected correlation coef PSTH1 versus PSTH2