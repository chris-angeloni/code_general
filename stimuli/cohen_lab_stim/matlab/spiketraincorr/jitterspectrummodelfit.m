%
%function [JitterSpecModel]=jitterspectrummodelfit(Pnoise,lambdap,Faxis,disp)
%
%
%   FILE NAME       : JITTER SPECTRUM MODEL FIT
%   DESCRIPTION     : Fits the Jitter noise spectrum with a Gaussian function.
%
%	Rnoise          : Average Noise Spectrum
%   lambdap         : Measured spike rate (lambda_i * p)
%	Faxis           : Frequency Axis (Hz)
%	disp            : Display: 'y' or 'n', Defualt=='n'
%
%Returned Variables
%   JitterSpecModel : Data structure containing the following
%
%                   .Pnoise - Noise Spectrum
%                   .Pmodel - Model Noise Spectrum
%                   .F      - Frequency Axis (Hz)
%                   .p      - Estimated reliability
%                   .lambda - Estimated spike rate (hypothetical - 
%                             no jitter or reliability errors)
%                   .sigma  - Jitter standard deviation (msec)
%
% (C) Monty A. Escabi, Edit June 2010
%
function [JitterSpecModel]=jitterspectrummodelfit(Pnoise,lambdap,Faxis,disp)

%Input Arguments
if nargin<4
	disp='n';
end        

%Estimating Jitter, Reliability and hypothetical spike rate
%Note that R(W)=p^2*lambda*exp(-(2*pi*F).^2*sigma^2) = p*lambdap*exp(-(2*pi*F).^2*sigma^2)
beta = lsqcurvefit(@(beta,Faxis) beta(1)*lambdap*exp(-(2*pi*Faxis).^2*(beta(2)/1000)^2),[max(Pnoise)/lambdap 5],Faxis,Pnoise,[0 0],[1.1 20]);
sigma=beta(2);
p=beta(1);
lambda=lambdap/p;

%Model Noise Spectrum
Pmodel=p*lambdap*exp(-(2*pi*Faxis).^2*(sigma/1000)^2);

%Assinging Variables to Data Structure
JitterSpecModel.Pnoise=Pnoise;
JitterSpecMoel.Pmodel=Pmodel;
JitterSpecModel.F=Faxis;
JitterSpecModel.p=p;
JitterSpecModel.lambda=lambda;
JitterSpecModel.sigma=sigma;

%Displaying Output
if strcmp(disp,'y')
    plot(Faxis,Pnoise,'k','linewidth',2)
    hold on
    plot(Faxis,Pmodel,'linewidth',2)
    ylabel('Magnitude')
    xlabel('Frequency (Hz)')
    title('Black=Pnoise, Red=Pmodel')
end