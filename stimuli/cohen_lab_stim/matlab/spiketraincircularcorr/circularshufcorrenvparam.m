%
%function [REnvParam]=circularshufcorrenvparam(REnv)
%
%   FILE NAME       : CIRCULAR SHUF CORR ENV PARAM
%   DESCRIPTION     : Computes response parameters from the circular
%                     shuffled envelope correlation.
%
%   REnv            : Data structure containing:
%
%                     .Renv         - Envelope correlogram
%                     .R            - Correlogram between all cycles
%                     .Rdiag        - Correlogram for cycles with fixed
%                                     fine structure and envelope
%                     .lambda       - Mean firing rate (spikes/sec)
%                     .Fm           - Sound modualtion frequency (Hz)
%                     .Tau          - Delay vector (msec)
%
%RETURNED VALUES
%
%   REnvParam       : Data structure containg the response paramters
%   
%
% (C) Monty A. Escabi, Feb 2011
%
function [REnvParam]=circularshufcorrenvparam(REnv)

%Measuring Response parameters
i=find(REnv.Tau==0);
Renv=REnv.Renv;
Renvnorm=sqrt(REnv.Renv);
REnvParam.MI1=(Renv(i)-min(Renv))/Renv(i);              %Modulation Index 1 - based on power
REnvParam.MI2=(Renvnorm(i)-min(Renvnorm))/Renvnorm(i);  %Modulation Index 2 - based on rate, same as Yi's 2008 paper

%Fitting Jitter / Reliability Model & Adding Model Results to structure
[beta,R0,J0]=gaussfunmodeloptim(REnv,REnv.Renv);
REnvParam.sigma=beta(1);
REnvParam.xhat=beta(2);                                                         %Number of reliable spikes/cycle
REnvParam.Rmodel=gaussfunmodel(beta,REnv);                                      %Sum of Gaussian model fit
REnvParam.lambda=REnv.lambda;                                                   %Firing rate
REnvParam.lambdaAC=REnv.Fm*REnvParam.xhat;                                      %AC rate
REnvParam.lambdaDC=REnvParam.lambda-REnvParam.lambdaAC;                         %DC rate
REnvParam.F=REnvParam.lambdaAC.^2/(REnvParam.lambdaAC+REnvParam.lambdaDC).^2;   %Temporal coding fraction




%        Lambda(k,l)=REnv(k,l).lambda;
%         LambdaAC(k,l)=REnv(k,l).Fm*REnv(k,l).xhat;
%         LambdaDC(k,l)=REnv(k,l).lambda-LambdaAC(k,l);
%         LambdaN(k,l)=Lambda(k,l)-LambdaAC(k,l);
%         Sigma(k,l)=REnv(k,l).sigma;
%         Xhat(k,l)=REnv(k,l).xhat;
%         F(k,l)=LambdaAC(k,l)^2/((LambdaAC(k,l)+LambdaDC(k,l))^2);
%         FM(k,l)=REnv(k,l).Fm;
%         FC(k,l)=RASSpline(k,l).FC;