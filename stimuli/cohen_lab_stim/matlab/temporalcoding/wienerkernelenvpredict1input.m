%
%function [PreData]=wienerkernelenvpredict1input(Wkernel,SoundPreEnv,SoundParam)
%
%       FILE NAME       : WIENER KERNEL ENV PREDICT 1 INPUT
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994
%
%       Wkernel         : Structure containing 1st and 2nd order kernels
%                         along with estimated spiking nonlinearities. See
%                         WIENERKERNELENV for details.
%       SoundPreEnv     : Data structure containing the prediction
%                         envelopes
%
%                         .Env - Channel 1 envelope (in dB)
%       SoundParam      : Data structure containing sound parameters
%
%RETURNED VARIABLES
%
%       PreData         : Structure containing prediction results
%
%                         .Y        - Predicted 1st-order output
%                         .Ynl      - Predicted nonlinear output
%                         .Ytot     - Total combined output. Linear and 
%                                     nonlinear output including the output
%                                     nonlinearity (F).
%          
%   (C) Monty A. Escabi, Nov 2011
%
function [PreData]=wienerkernelenvpredict1input(Wkernel,SoundPreEnv,SoundParam)

%Sound Prediction Envelope in dB
X=SoundPreEnv.Env;

%Linear Prediction
dt=1/(SoundParam.Fs/Wkernel.DF/SoundParam.DS);
Fs=1/dt;
Y1=conv(Wkernel.k1,X);

%Second order prediction
Y2_1=(conv(Wkernel.k2_1,X)).^2;
Y2_2=(conv(Wkernel.k2_2,X)).^2;    
Y2=Wkernel.lambda2_1*Y2_1+Wkernel.lambda2_2*Y2_2;

%Applying Output Second order Nonlinearity - check out paper by Atencio,
%Sharpe et al.
N1=size(Wkernel.F,1);
N2=size(Wkernel.F,2);
Y1index=ceil((Y1-Wkernel.MinY1prior )/mean(diff(Wkernel.y1)));
Y1index=max(1,Y1index);
Y1index=min(N2,Y1index);
Y2index=ceil((Y2-Wkernel.MinY2prior )/mean(diff(Wkernel.y2)));
Y2index=max(1,Y2index);
Y2index=min(N1,Y2index);
for k=1:length(Y1index)
        Ytot(k)=Wkernel.Fr(Y2index(k),Y1index(k));  %Uses regularized nonlinearity
        Y1nl(k)=Wkernel.F1(Y1index(k));
end
% i=find(isnan(Ytot));
% for k=1:length(i)       %Median filter on output with NaN; removes artifacts from NaN
%     YY=Ytot(max(i(k)-3,1):min(i(k)+3,end));
%     index=find(~isnan(YY));
%     Ytot(i(k))=median(YY(index));
%     
%     YY=Y1nl(max(i(k)-3,1):min(i(k)+3,end));
%     index=find(~isnan(YY));
%     Y1nl(i(k))=median(YY(index));
% end

%Adding predictions to data structure
PreData.Y1=Y1;
PreData.Y2=Y2;
PreData.Y2_1=Y2_1;
PreData.Y2_2=Y2_2;
PreData.Y1nl=Y1nl;
PreData.Ytot=Ytot;
PreData.T=(1:length(Y1))/(Wkernel.Fs/Wkernel.DF/Wkernel.DS);