%
%function [F]=gaussfunmodel(Beta,X)
%
%   FILE NAME       : GAUSS FUN MODEL
%   DESCRIPTION     : Sums of gaussian model used to fit circular shuffled
%                     correlogram. Edited version of GAUSSFUN2 originally
%                     written by Yi.
%
%   beta            : Model Parameters
%
%                     beta(1) = sigma (msec)
%                     beta(2) = x_hat, number of reliable spikes per cycle
%   X               : Data structure containing input information
%
%     .lambda       : Measured firing rate (spikes/sec)
%     .Tau          : Correlation delay axis (msec)
%     .Fm           : Modulation Frequency (Hz)
%
%RETURNED VALUES
%
%   F               : Fitted model
%
% (C) Monty A. Escabi, May 2011
%
function [F]=gaussfunmodel(Beta,X)
  
  %Model Parameters
  sigma=Beta(1)/1000;   %Standard deviation in sec
  p=Beta(2);            %Reliable spikes per cycle
  
  %Model Input
  lambdaTot=X.lambda;
  lambdaI=X.Fm;
  Tau=X.Tau/1000;   %Convert to seconds
  T=1/X.Fm;
  Fsd=1/(X.Tau(2)-X.Tau(1))*1000;
  
  %Constraints
  lambdaN=lambdaTot-p*lambdaI;
  if lambdaN<0
      lambdaN=0;
  end
  
  %Fitting Model
  DC=lambdaN^2+2*p*lambdaI*lambdaN;
  peak=p^2*lambdaI;
  a=1/sqrt(4*pi*sigma.^2);
  %F=DC+peak*a*(exp(-Tau.^2/(4*sigma^2))+exp(-(Tau-T).^2/(4*sigma^2))+exp(-(Tau+T).^2/(4*sigma^2))+exp(-(Tau-2*T).^2/(4*sigma^2))+exp(-(Tau+2*T).^2/(4*sigma^2)));
  
  F=DC;
  N=max(ceil(Tau./T));
  for k=-N:N
        F=F+peak*a*exp(-(Tau+k*T).^2/(4*sigma^2));
  end
  