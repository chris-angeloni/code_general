%
%function [Wkernel]=wienerkernelenvpredict(RASData,SoundEstEnv,SoundPredictionEnv,SoundParam,T1,T2,DF,Disp)
%
%       FILE NAME       : WIENER KERNEL ENV
%       DESCRIPTION     : Computes the first and second order temporal wiener
%                         kernels for a sound with random temporal
%                         envelope using an estimation dataset. A second
%                         dataset will subsequently be used for predcition.
%                         Details for computing 1st and 2nd order kernels
%                         can be dound in the Van Dijk 1994
%
%       RASData         : Data structure containing the estimation and
%                         prediciton responses. Organized as follows:
%
%           .Est        : Estimation Rastergram
%           .spet       : Spike event times for each trial. Different sound
%                         segments are repeated L times (in sample number).
%           .T          : Trial duration
%           .Fs         : Samping rate (Hz)
%
%           .Pre        : Prediction Rastergram
%           .spet       : Spike event times (sample number).
%           .T          : Trial duration.
%           .Fs         : Sampling rate (Hz)
%       SoundEstEnv     : Sound envelopes for estimating wiener kernels.
%                         Each envelope is repeated L times.
%       SoundParam      : Data structure containing sound parameters
%       T1              : Minimum negative delay used for estimating 
%                         kernels (msec). T1>0 but negative sign is added
%                         in program.
%       T2              : Maximum delay used for estimating kernels (msec)
%       DF              : Downsampling factor for envelope
%       Disp            : Displaying output ('y' or 'n', Default=='n')
%
%RETURNED VARIABLES
%
%       Wkernel         : Structure containing 1st and 2nd order kernels
%
%                         .N        - number of spikes
%                         .k0       - zeroth order kernel (spike rate)
%                         .Varxx    - input variance
%                         .k1       - first order kernel
%                         .k1ste    - standard error on k1
%                         .k2       - second order kernel
%                         .PEE      - Pre event envelope
%                         .k2_1     - First singular vector on k2
%                         .k2_2     - Second singular vector on k2
%                         .lambda2_1- First singular value on k2
%                         .lambda2_2- Second singular value on k2
%                         .k2U      - U vector from SVD decomposition on k2
%                         .k2V      - V vector from SVD decomposition on k2
%                         .k2S      - S vector from SVD decomposition on k2
%                         .T1       - Time delay vecotr
%                         .T2       - Time delay vecotr
%                         .Y1spike  - Spike triggered first order output. 
%                                     Used to construct output
%                                     nonlinearity. 
%                         .Y2spike  - Spike triggered second order output. Used to
%                                     construct output nonlinearity.
%                         .Y1prior  - Prior first order output. Used to
%                                     construct output nonlinearity (F). 
%                         .Y2prior  - Prior second order output. Used to
%                                     construct output nonlinearity (F).
%                         .F        - 2-D nonlinearity
%                         .y1       - Y1 axis for F
%                         .y2       - Y2 axis for F
%                         .PSTH     - PSTH for all of the validation data
%                         .PSTH1    - PSTH for 1st half of validation data
%                         .PSTH2    - PSTH for 2nd half of validation data
%                         .Y1       - Predicted first order output (linear)
%                         .Y2       - Predicted second order output
%                         .Y2_1     - Predicted output from the first
%                                     second order filter
%                         .Y2_2     - Predicted output from second, second
%                                     order filter
%                         .Ytot     - Total combined output. Linear and
%                                     nonlinear including the output
%                                     nonlinearity (F).
%          
%   (C) Monty A. Escabi, March 2011
%
function [Wkernel]=wienerkernelenvpredict(RASData,SoundEstEnv,SoundPredictionEnv,SoundParam,T1,T2,DF,Disp)

%Generating Wiener Kernel Data
[Wkernel]=wienerkernelenv(RASData,SoundEstEnv,SoundParam,T1,T2,DF,Disp);

%Sound Envelope in dB
X=(20*log10(SoundPredictionEnv)+15);
i=find(X<-15);
X(i)=zeros(size(i));
X=X(1:DF:end);

%Linear Prediction
dt=1/(SoundParam.Fs/DF/SoundParam.DS);
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
Y1index=ceil((Y1-min(Wkernel.Y1prior) )/mean(diff(Wkernel.y1)));
Y1index=max(1,Y1index);
Y1index=min(N2,Y1index);
Y2index=ceil((Y2-min(Wkernel.Y2prior) )/mean(diff(Wkernel.y2)));
Y2index=max(1,Y2index);
Y2index=min(N1,Y2index);
for k=1:length(Y1index)
        Ytot(k)=Wkernel.F(Y2index(k),Y1index(k));
end
i=find(isnan(Ytot));
for k=1:length(i)       %Median filter on output with NaN; removes artifacts from NaN
    YY=Ytot(max(i(k)-3,1):min(i(k)+3,end));
    index=find(~isnan(YY));
    Ytot(i(k))=median(YY(index));
end

%Generating PSTH and RASTERS
RASPre=rasterexpand(RASData.Pre,Fs);
N=floor(size(RASPre,1)/2);
Wkernel.PSTH=mean(RASPre);
Wkernel.PSTH1=mean(RASPre(1:2:end,:));  %Odd trials
Wkernel.PSTH2=mean(RASPre(2:2:end,:));  %Even trials

%Adding predictions to data structure
Wkernel.Y1=Y1(1:length(Wkernel.PSTH));
Wkernel.Y2=Y2(1:length(Wkernel.PSTH));
Wkernel.Y2_1=Y2_1(1:length(Wkernel.PSTH));
Wkernel.Y2_2=Y2_2(1:length(Wkernel.PSTH));
Wkernel.Ytot=Ytot(1:length(Wkernel.PSTH));

%Corrected correlation Coefficient
L=100;
Ymodel=Wkernel.Ytot-mean(Wkernel.Ytot);
Ylin=Wkernel.Y1-mean(Wkernel.Y1);
PSTH1=Wkernel.PSTH1;
PSTH1=PSTH1-mean(PSTH1);
PSTH2=Wkernel.PSTH2;
PSTH2=PSTH2-mean(PSTH2);
N=length(Ymodel);
Rm2=xcorr(Ymodel,PSTH2,L)/(N-1);
Rl2=xcorr(Ylin,PSTH2,L)/(N-1);
R12=xcorr(PSTH1,PSTH2,L)/(N-1);
Var1=var(PSTH1)-var(PSTH1-PSTH2)/2;
Var2=var(PSTH2)-var(PSTH1-PSTH2)/2;
Var=(Var1+Var2)/2;                      %Response variance
Varm=var(Ymodel);                       %Full model variance
Varl=var(Ylin);                         %Linear model variance
Wkernel.Rm2=Rm2/sqrt(Varm*Var);         %Corrected correlation full model vers PSTH2
Wkernel.Rl2=Rl2/sqrt(Varl*Var);         %Corrected correlation linear model vers PSTH2
Wkernel.R12=R12/sqrt(Var1*Var2);        %Corrected correlation PSTH1 versus PSTH2
Wkernel.CCm2=Wkernel.Rm2(L+1);          %Corrected correlation coef full model versus PSTH2
Wkernel.CCl2=Wkernel.Rl2(L+1);          %Corrected correlation coef linear model versus PSTH2
Wkernel.CC12=Wkernel.R12(L+1);          %Corrected correlation coef PSTH1 versus PSTH2