%
%function [Err,SignalVar,ErrorVar,CellNoiseVar,ModelNoiseVar]=predictionerror2(RASTERm,RASTERc,Fs,dt)
%
%       FILE NAME       : PREDICTION ERROR2
%       DESCRIPTION     : Computes the normalized prediction error from
%                         by removing the model and cell noise from the
%                         error estimate. PSTHs are smooted at a resolution
%                         of dt.
%
%       RASTERm         : Model Rastergram
%       RASTERc         : Cell Rastergram
%       Fs              : Sampling rate
%       dt              : Smoothing resolution, standard deviation of
%                         Gaussian smoothing window
%
%OUTPUT
%       Err             : Normalized Percent Error
%       SignalVar       : Signal Variance, var(PSTHc1) 
%       ErrorVar        : Variance of Error signal, var(PSTHc-PSTHm)
%       CellNoiseVar    : Cell Noise Variance, var(PSTHc1-PSTHc2)/2;
%       ModelNoiseVar   : Model Noise Variance, var(PSTHm1-PSTHm2)/2;
%       (C) Monty A. Escabi, March 2006
%
function [Err,SignalVar,ErrorVar,CellNoiseVar,ModelNoiseVar]=predictionerror2(RASTERm,RASTERc,Fs,dt)

%Extracting Odd and Even Trials
N=floor(size(RASTERm,1)/2)*2;
RASTERm1=RASTERm(1:2:N,:);
RASTERm2=RASTERm(2:2:N,:);
RASTERc1=RASTERc(1:2:N,:);
RASTERc2=RASTERc(2:2:N,:);

%Smoothed RASTERS
dt=dt/1000;
M=ceil(5*dt*Fs);
t=(-M:M)/Fs;
w=exp(-t.^2/2/dt.^2);
for k=1:N/2
    RASTERm1s(k,:)=conv(RASTERm1(k,:)*Fs,w);
    RASTERm2s(k,:)=conv(RASTERm2(k,:)*Fs,w);
    RASTERc1s(k,:)=conv(RASTERc1(k,:)*Fs,w);
    RASTERc2s(k,:)=conv(RASTERc2(k,:)*Fs,w);
end

%Computing Signal, Error and Noise Variances
for k=1:N/2
    for l=1:N/2
        CellNoiseVar(k,l)=var(RASTERc1s(k,:)-RASTERc2s(l,:))/2;
        ModelNoiseVar(k,l)=var(RASTERm1s(k,:)-RASTERm2s(l,:))/2;
        ErrorVar=var(RASTERc1s(k,:)-RASTERm1s(l,:))/4+...
            var(RASTERc2s(k,:)-RASTERm2s(l,:))/4+...
            var(RASTERc1s(k,:)-RASTERm2s(l,:))/4+...
            var(RASTERc2s(k,:)-RASTERm1s(l,:))/4;
    end
    SignalVar=var(RASTERc1s(k,:))/2+var(RASTERc2s(k,:))/2;
end
CellNoiseVar=mean(mean(CellNoiseVar));
ModelNoiseVar=mean(mean(ModelNoiseVar));
ErrorVar=mean(mean(ErrorVar));
SignalVar=mean(mean(SignalVar));

%Percent Error
Err=(ErrorVar-CellNoiseVar-ModelNoiseVar)/(SignalVar-CellNoiseVar)*100;