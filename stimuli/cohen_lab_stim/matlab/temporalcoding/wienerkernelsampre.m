%
%function [SAMPre]=wienerkernelsampre(Wkernel,SoundParam,FMAxis,Beta,Ncyc,Disp)
%
%       FILE NAME       : WIENER KERNEL SAM PRE
%       DESCRIPTION     : Prediction routine for SAM using the generalized 
%                         Wkernel nonlinear model. For details see
%                         WIENERKERNELENV.
%
%       Wkernel         : Structure containing kernels for 1 or 2 input channels
%                         along with estimated spiking nonlinearities. See
%                         WIENERKERNELENV2INPUT or WIENERKERNELENV 
%                         for details.
%       SoundParam      : Data structure containing sound parameters
%       FMAxis          : Modulation frequency vector (e.g, [2 4 8 16 ...])
%       Beta            : Modualtion index (1)
%       Ncyc            : Number of cycles for simulation  (2 or 4)
%       Mcyc            : Number of bins per cycle to generate cycle
%                         histogram
%       Disp            : Display output ('y' or 'n'; Defaul=='n')
%
%RETURNED VARIABLES
%
%       SAMPre          : Structure containing prediction results
%
%                         .Data
%                           .Y1     - Predicted 1st-order output for channel 1
%                           .Y2     - Predicted 1st-order output for channel 2
%                           .Y1nl   - Predicted nonlinear output for channel 1
%                           .Y2nl   - Predicted nonlinear output for channel 2
%                           .Ytot   - Total combined output for channel 1 
%                                     and 2. Linear and nonlinear output
%                                     including the output nonlinearity (F).
%
%                         .MTF
%                           .Rate1nl        - Predicted rate MTF using 1st
%                                             order kernel + output
%                                             nonlinearity
%                           .VS1nl          - Predicted VS MTF using 1st
%                                             order kernel + output
%                                             nonlinearity
%                           .Ratetot        - Predicted rate MTF using 1st 
%                                             + 2nd order kernel + output
%                                             nonlinearity
%                           .VStot          - Predicted VS MTF using 1st
%                                             + 2nd order kernel + output
%                                             nonlinearity
%                           .FMAxis         - Modulation frequency vector (Hz)
%
%                         .CycleHist
%                           .Y1    -        - Linear model
%                           .Y1nl  -        - Linear + nonlinear model (1st
%                                             order kernel + output
%                                             nonlinearity)
%                           .Ytot  -        - Full nonlinear model (1st +
%                                             2nd order kernel + output 
%                                             nonlinearity)
%          
%   (C) Monty A. Escabi, Nov 2011
%
function [SAMPre]=wienerkernelsampre(Wkernel,SoundParam,FMAxis,Beta,Ncyc,Mcyc,Disp)

%Input Args
if nargin<7
    Disp='n';
end

%Computing Predicted Ouputs for All Fm Conditions
for k=1:length(FMAxis)
    
    %Predicting output for k-th Fm 
    DF=Wkernel.DF;
    Fs=Wkernel.Fs;
    Fsd=Wkernel.Fs/Wkernel.DS/Wkernel.DF;
    M=ceil( (1/FMAxis(k)*(Ncyc+2)+max(Wkernel.T/1000)*2) * Fsd);
    Env=20*log10(1+Beta*sin(2*pi*FMAxis(k)*(1:M)/Fsd-pi/2));
   
    %Checking for 1 or 2 audio channel model
    if isfield(Wkernel,'k1_1')
        %Two channel audio model
        SoundPreEnv.Env1=Env;
        SoundPreEnv.Env2=Env;
        SAMPre.Data(k)=wienerkernelenvpredict2input(Wkernel,SoundPreEnv,SoundParam);
        
        %Selecting Ncyc cycles
        %M1=ceil(max(Wkernel.T/1000)*Fsd);
        %M2=M1+ceil(1/FMAxis(k)*Ncyc*Fsd);
        M1=ceil(1/FMAxis(k)*Ncyc*Fsd)+1;
        M2=2*ceil(1/FMAxis(k)*Ncyc*Fsd);
        SAMPre.Data(k).Y1=SAMPre.Data(k).Y1(M1:M2);
        SAMPre.Data(k).Y2=SAMPre.Data(k).Y2(M1:M2);
        SAMPre.Data(k).Y2nl=SAMPre.Data(k).Y2nl(M1:M2);
        SAMPre.Data(k).Y1nl=SAMPre.Data(k).Y1nl(M1:M2);
        SAMPre.Data(k).Ytot=SAMPre.Data(k).Ytot(M1:M2);
        SAMPre.Data(k).T=(1:length(SAMPre.Data(k).Y1))/Fsd;
    else
        %Single channel audio model
        SoundPreEnv.Env=Env;
        SAMPre.Data(k)=wienerkernelenvpredict1input(Wkernel,SoundPreEnv,SoundParam);
        
        %Selecting Ncyc cycles
        %M1=ceil(max(Wkernel.T/1000)*Fsd);
        %M2=M1+ceil(1/FMAxis(k)*Ncyc*Fsd);
        M1=ceil(1/FMAxis(k)*Ncyc*Fsd)+1;
        M2=2*round(1/FMAxis(k)*Ncyc*Fsd);
        SAMPre.Data(k).Y1=SAMPre.Data(k).Y1(M1:M2);
        SAMPre.Data(k).Y2=SAMPre.Data(k).Y2(M1:M2);
        SAMPre.Data(k).Y2_1=SAMPre.Data(k).Y2_1(M1:M2);
        SAMPre.Data(k).Y2_2=SAMPre.Data(k).Y2_2(M1:M2);
        SAMPre.Data(k).Ytot=SAMPre.Data(k).Ytot(M1:M2);
        SAMPre.Data(k).Y1nl=SAMPre.Data(k).Y1nl(M1:M2);
        SAMPre.Data(k).T=(0:length(SAMPre.Data(k).Y1)-1)/Fsd;
    end
end

%Adding Phase, Modulation Frequency, Rate and VS
for k=1:length(FMAxis)
     SAMPre.MTF.FMAxis(k)=FMAxis(k);
     P=SAMPre.Data(k).T/(1/FMAxis(k));
     SAMPre.MTF.Rate1nl(k)=mean(SAMPre.Data(k).Y1nl);
     SAMPre.MTF.VS1nl(k)=abs(sum(exp(i*P*2*pi).*SAMPre.Data(k).Y1nl/(sum(SAMPre.Data(k).Y1nl))));
     SAMPre.MTF.Ratetot(k)=mean(SAMPre.Data(k).Ytot);
     SAMPre.MTF.VStot(k)=abs(sum(exp(i*P*2*pi).*SAMPre.Data(k).Ytot/(sum(SAMPre.Data(k).Ytot))));
end

%Generating Cycle Histograms for linear and nonlinear inputs
for k=1:length(FMAxis)
    
    %P=SAMPre.Data(k).T/(1/FMAxis(k));
    P=SAMPre.Data(k).T/max(SAMPre.Data(k).T);
    Pint=(0:Mcyc*Ncyc-1)/(Mcyc*Ncyc-1);
    CycleHistY1(:,k) = interp1(P,SAMPre.Data(k).Y1,Pint)';
    CycleHistY2(:,k) = interp1(P,SAMPre.Data(k).Y2_1,Pint)';

end
SAMPre.CycleHist.Y1=CycleHistY1;

%Applying Output Second order Nonlinearity - check out paper by Atencio,
%Sharpe et al.
N1=size(Wkernel.Fr,1);
N2=size(Wkernel.Fr,2);
Y1index=ceil((CycleHistY1-Wkernel.MinY1prior )/mean(diff(Wkernel.y1)));
Y1index=max(1,Y1index);
Y1index=min(N2,Y1index);
Y2index=ceil((CycleHistY2-Wkernel.MinY2prior )/mean(diff(Wkernel.y2)));
Y2index=max(1,Y2index);
Y2index=min(N1,Y2index);
for k=1:size(Y1index,1)
    for m=1:size(Y1index,2)
        CycleHistYtot(k,m)=Wkernel.Fr(Y2index(k,m),Y1index(k,m));   %Use regularized nonlinearity - NaN removed
        CycleHistY1nl(k,m)=Wkernel.F1(Y1index(k,m));
    end
end
SAMPre.CycleHist.Y1nl=CycleHistY1nl;
SAMPre.CycleHist.Ytot=CycleHistYtot;
SAMPre.CycleHist.P=(0:Mcyc*Ncyc-1)/(Mcyc-1);

%Displaying Output
if strcmp(Disp,'y')

    subplot(221)
    imagesc(log2(SAMPre.MTF.FMAxis/4),SAMPre.CycleHist.P,SAMPre.CycleHist.Y1)
    set(gca,'XTick',[0 1 2 3 4 5 6 7])
    set(gca,'XTickLabel',[4 8 16 32 64 128 256 512])
    set(gca,'YDir','normal')
    title('Linear')

    subplot(222)
    imagesc(log2(SAMPre.MTF.FMAxis/4),SAMPre.CycleHist.P,SAMPre.CycleHist.Y1nl)
    set(gca,'XTick',[0 1 2 3 4 5 6 7])
    set(gca,'XTickLabel',[4 8 16 32 64 128 256 512])
    set(gca,'YDir','normal')
    title('Linear+NL')

    subplot(223)
    imagesc(log2(SAMPre.MTF.FMAxis/4),SAMPre.CycleHist.P,SAMPre.CycleHist.Ytot)
    set(gca,'XTick',[0 1 2 3 4 5 6 7])
    set(gca,'XTickLabel',[4 8 16 32 64 128 256 512])
    set(gca,'YDir','normal')
    title('Full Nonlinear')

end