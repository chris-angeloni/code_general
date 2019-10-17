%
%function [Rate]=integratefirerate(beta,X)
%
%       FILE NAME       : INTEGRATE FIRE RATE
%       DESCRIPTION     : Integrate and fire model neuron PSTH generator.
%                         Used for optimizing extracellular prediction
%                         with INTEGRATEFIREOPTIM
%
%	X           : Input Membrane Current Signal
%                 The sampling rate and number of trials are embeded in X
%                 ande removed as follows:
%                   X.data - Intracellular current
%                   X.Fs   - Samplint rate
%                   X.Tau  - Time constant (msec)
%                   X.Tref - Refractory period (msec)
%                   X.SNR  - Signal to noise ration (dB)
%                   X.L    - Number of trials
%                   X.Nsig - Number of standard deviations to threshold
%
%   beta        : Model parameter vector, [Nsig]
%                   Tau    - Time constant (msec)
%
%OUTPUT SIGNAL
%
%	Rate        : Predicted firing rate
%
% (C) Monty A. Escabi, Dec 2005
%
function [Rate]=integratefirepsth(beta,X)

%Model Parameters
Tref=X.Tref;
SNR=X.SNR;
Fs=X.Fs;
L=X.L;
Im=X.data;

Tau=beta(1);
Nsig=X.Nsig;
%Tau=X.Tau;
%Nsig=beta(1);

%Initializing signal parameters
In=randn(1,length(Im)*6);
Vtresh=-55;
Vrest=-65;
flag=3;
detrendim='n';
detrendin='n';

%Generating PSTH for L trials
[taxis,RASTER]=rasterifsim(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L,In,detrendim,detrendin);
Rate=((mean(RASTER',1)*Fs));