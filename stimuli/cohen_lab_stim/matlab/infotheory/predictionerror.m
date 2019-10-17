%
%function
%[Err,SignalVar,ErrorVar,CellNoiseVar,ModelNoiseVar]=predictionerror(RASTERm,RASTERc,Fs,dt)
%
%       FILE NAME       : PREDICTION ERROR
%       DESCRIPTION     : Computes the normalized prediction error from the
%                         response and model PSTH (PSTHc and PSTHm)
%                         by removing the model and cell noise from the
%                         error estimate. PSTHs are smooted with a Gaussian
%                         window at a resolution of dt.
%
%       RASTERm         : Model Rastergram
%       RASTERc         : Cell Rastergram
%       Fs              : Sampling rate
%       dt              : Smoothing resolution, standard deviation of
%                         Gaussian smoothing window
%
%OUTPUT
%       Err              : Normalized Percent Error, the cell noise and
%                          model noise variance are removed to obtain a
%                          true measure of prediction ERROR
%                          Err=(ErrorVar-CellNoiseVar-ModelNoiseVar)/(Sign
%                          alVar-CellNoiseVar)
%       SignalVar        : Signal Variance, var(PSTHc1) 
%       ErrorVar         : Variance of Error signal, var(PSTHc-PSTHm)
%       CellNoiseVar     : Cell Noise Variance, var(PSTHc1-PSTHc2)/2;
%       ModelNoiseVar    : Model Noise Variance, var(PSTHm1-PSTHm2)/2;
%
%       (C) Monty A. Escabi, March 2006
%
function [Err,SignalVar,ErrorVar,CellNoiseVar,ModelNoiseVar]=predictionerror(RASTERm,RASTERc,Fs,dt)

%Extracting Odd and Even Trials
N=floor(size(RASTERm,1)/2)*2;
RASTERm1=RASTERm(1:2:N,:);
RASTERm2=RASTERm(2:2:N,:);
RASTERc1=RASTERc(1:2:N,:);
RASTERc2=RASTERc(2:2:N,:);

%Smoothed PSTH
dt=dt/1000;
M=ceil(5*dt*Fs);
t=(-M:M)/Fs;
w=1/sqrt(2*pi*dt.^2)*exp(-t.^2/2/dt.^2)/Fs;
PSTHm1=conv(mean(RASTERm1,1)*Fs,w);
PSTHm2=conv(mean(RASTERm2,1)*Fs,w);
PSTHc1=conv(mean(RASTERc1,1)*Fs,w);
PSTHc2=conv(mean(RASTERc2,1)*Fs,w);

%Computing Signal, Error and Noise Variances
CellNoiseVar=var(PSTHc1-PSTHc2)/2;
ModelNoiseVar=var(PSTHm1-PSTHm2)/2;
SignalVar=var(PSTHc1)/2+var(PSTHc2)/2;
ErrorVar=var(PSTHc1-PSTHm1)/4+var(PSTHc2-PSTHm2)/4+var(PSTHc1-PSTHm2)/4+var(PSTHc2-PSTHm1)/4;

%Percent Error
Err=(ErrorVar-CellNoiseVar-ModelNoiseVar)/(SignalVar-CellNoiseVar)*100;