%
%function [Y]=integratefirepsth(beta,X)
%
%       FILE NAME       : INTEGRATE FIRE PSTH
%       DESCRIPTION     : Integrate and fire model neuron PSTH generator.
%                         Used for optimizing extracellular prediction
%                         with INTEGRATEFIREOPTIM
%
%	X           : Input Membrane Current Signal
%                 The sampling rate and number of trials are embeded in X
%                 ande removed as follows:
%                   Fs = X(1)
%                   L  = X(2)
%   beta        : Model parameter vector, [Tau Tref Nsig SNR]
%                 Tau  - Integration time constant (msec)
%                 Tref - Refractory Period (msec)
%                 Nsig - Number of standard deviations of t
%                        intracellular voltage to set the spike
%                        threshold
%                 SNR  - Signal to Noise Ratio (dB)
%
%OUTPUT SIGNAL
%
%	Y           : Predicted output PSTH
%
% (C) Monty A. Escabi, Dec 2005
%
function [Y]=integratefirepsth(beta,X)

%Model Parameters
Tau=beta(1);
Tref=beta(2);
Nsig=beta(3);
SNR=beta(4);

%Initializing signal parameters
Fs=X(1);
L=X(2);
Im=X(3:length(X));
In=randn(1,length(Im)*6);
Vtresh=-55;
Vrest=-65;
flag=3;
detrendim='y';
detrendin='n';

%Generating PSTH for L trials
[taxis,RASTER]=rasterifsim(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L,In,detrendim,detrendin);
Y=mean(RASTER,1);