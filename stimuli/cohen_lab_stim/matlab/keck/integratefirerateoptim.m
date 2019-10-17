%
%function [Rate]=integratefirerate(beta,X)
%
%       FILE NAME       : INTEGRATE FIRE RATE OPTIM
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
%   beta        : Model parameter vector, [Tau]
%                   Tau    - Time constant (msec)
%   Nsig        : Vector containing Nsig values to evaluate
%   Rate        : Desired firing rate to mactch during optimization
%
%OUTPUT SIGNAL
%
%	beta        : Parameter Vecor containing all Taus for each Nsig
%
% (C) Monty A. Escabi, Dec 2005
%
function [beta]=integratefirerateoptim(Nsig,X,Rate)

%Setting LSQCURVEFIT Options
options=optimset('lsqcurvefit');
options=optimset(options,'DiffMinChange',1,'DiffMaxChange',10,'DerivativeCheck','on');

%Initial Parameter
beta0=10;
    
%Optimizing Tau vs. Nsig
for k=1:length(Nsig)

    X.Nsig=Nsig(k);   
    [beta(k),resnorm]=lsqcurvefit('integratefirerate',beta0,X,Rate*ones(1,X.L),3,100,options);

end