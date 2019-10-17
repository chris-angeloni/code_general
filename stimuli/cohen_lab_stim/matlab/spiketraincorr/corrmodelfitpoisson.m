%
%function [JitterModelPoiss]=corrmodelfitpoisson(Rab,lambdap,Tau,disp)
%
%   FILE NAME       : CORR MODEL FIT POISSON
%   DESCRIPTION     : Gaussian Function fit for Noise correlogram analysis.
%                     Computes the spike timing jitter and reliability.
%                     Assumes spike train has Poisson serial statistics (no
%                     correction for refractoriness, bursting etc)
%
%	Rab             : Shuffled Autocorrelogram
%   lambdap         : Measured spike rate (lambda_i * p)
%	Tau             : Delay Axis (msec)
%	disp            : Display: 'y' or 'n', Defualt=='n'
%
%Returned Variables
%
% JitterModel : Data structure containing
%       .Rmodel     - Optimal Fitted Correlation Function
%       .sigmag     - Gaussian model Jitter STD
%       .pg         - Gaussian model reliability
%       .lambdag    - Gaussian model ideal firing rate
%       .lambdap    - Firing rate including reliability errors
%
% (C) Monty A. Escabi, Edit Aug 2015
%
function [JitterModelPoiss]=corrmodelfitpoisson(Rab,lambdap,Tau,disp)

%Input Arguments
if nargin<3
	disp='y';
end

%Converting Tau to seconds
Tau=Tau/1000;

%Fitting Gaussian Jitter Model to Rab
i=find(abs(Tau)<.050);    %Select only values with delays < 50 msec for optimization
[beta,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(@(beta,Tau) beta(1)*lambdap*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2)+lambdap^2,[0.5 10],Tau(i),Rab(i),[0 0],[1.1 20]);
sigmag=beta(2);
pg=beta(1);
Rmodel=beta(1)*lambdap*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2)+lambdap^2;

%Plotting Data and Model
if strcmp(disp,'y')
	hold off
	plot(Tau,Rab,'k')
	hold on
	plot(Tau,Rmodel)
	xlabel('Delay (msec)')
	ylabel('Crosscorrelation Amplitude')
	pause(.1)
end

%Data Structure containing Model and Parameters
JitterModelPoiss.Rmodel=Rmodel;
JitterModelPoiss.sigmag=sigmag;
JitterModelPoiss.pg=pg;
JitterModelPoiss.lambdag=lambdap/pg;
JitterModelPoiss.lambdap=lambdap;