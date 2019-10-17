%
%function [JitterSpecData]=jitterspectrum(spetA,spetB,Fs,Fsd,df,T,Disp)
%
%       FILE NAME   : JITTER SPECTRUM
%       DESCRIPTION : Computes the across trial (Pkl) and signel trial
%                     (Pkk) specturms from a two trial experiment. Uses Pkk and
%                     Pkl to estimate the neurons noise spectrum (Pnoise)
%                     and the Hypothetical Denoised Spectrum (Pss).
%
%       spetA,spetB : Spike event time arrays for trial A and B
%       Fs          : Sampling rate for spetA and spetB (Hz)
%       Fsd         : Desired Sampling rate for spectral analysis (Hz)
%       df          : Spectral resolution (Hz)
%       T           : Experiment Duration (sec)
%       Disp        : Display Output (Optional; Default='n')
%
%RETURNED VARIABLES
%
%   JitterSpecData  : Data structure containing the following
%
%                   .Pkk    - Power Spectral Density
%                   .Pkl    - Across Trial Spectral Density
%                   .Pnoise - Noise Spectrum
%                   .Pmodel - Model Noise Spectrum
%                   .Pss    - Denoised Hypothetical Spectrum
%                   .F      - Frequency Axis (Hz)
%                   .df     - Spectral Resolution (Hz)
%                   .p      - Estimated reliability
%                   .lambda - Estimated spike rate (hypothetical - 
%                             no jitter or reliability errors)
%                   .sigma  - Jitter standard deviation (msec)
%
% (C) Monty A. Escabi, July 2006 (Edit June 2010)
%
function [JitterSpecData]=jitterspectrum(spetA,spetB,Fs,Fsd,df,T,Disp)

%Input Arguments
if nargin<7
	Disp='n';
end

%Across-Trial Spectral Density
p=0.01;
Overlap=0.5;
[F,Pkl,Pklc,Pklp,K,Stdk,Stdl]=csdspike(spetA,spetB,Fs,Fsd,df,T,p,Overlap,'n','n');

%Spectral Density
[F,Pkk,Pkkc,Pkkp,K,Vark]=psdspike(spetA,Fs,Fsd,df,T,p,Overlap,'n','n');
[F,Pll,Pllc,Pllp,K,Varl]=psdspike(spetB,Fs,Fsd,df,T,p,Overlap,'n','n');
Pkk=(Pkk+Pll)/2;

%Mean Firing Rate including reliability errors
lambdap=length([spetA spetB])/2/T;

%Noise Spectrum
%Pnoise=abs(Pkl-Pkk+lambdap);   %ABS - otherwise complex
PN=real(Pkl-Pkk+lambdap);       %Better estimator for JITTER, the imaginary component is estimation Noise. Note that asumming infinite convergence, Pnoise is strictly real
Pnoise=PN;

%Estimate Hypothetical Spike Rate and Reliability
%DF=F(2)-F(1);
%p=Pnoise(1)/lambdap;            %Note that Pnoise(1)=DC Level of RNoise(tau)
%lambda=lambdap/p;
                                    
%Estimating Jitter, Reliability and hypothetical spike rate
%Note that R(W)=p^2*lambda*exp(-(2*pi*F).^2*sigma^2) = p*lambdap*exp(-(2*pi*F).^2*sigma^2)
beta = lsqcurvefit(@(beta,F) beta(1)*lambdap*exp(-(2*pi*F).^2*(beta(2)/1000)^2),[max(Pnoise)/lambdap 5],F,Pnoise,[0 0]);
sigma=beta(2);
p=beta(1);
lambda=lambdap/p;

%Model Noise Spectrum
Pmodel=p*lambdap*exp(-(2*pi*F).^2*(sigma/1000)^2);

%Ideal Signal Spectrum
Pss=lambda+p^2*lambda*(Pkk-lambdap)./Pnoise;

%Assinging Variables to Data Structure
JitterSpecData.Pkk=Pkk;
JitterSpecData.Pkl=Pkl;
JitterSpecData.Pnoise=Pnoise;
JitterSpecData.Pmodel=Pmodel;
JitterSpecData.Pss=Pss;
JitterSpecData.df=df;
JitterSpecData.F=F;
JitterSpecData.p=p;
JitterSpecData.lambda=lambda;
JitterSpecData.sigma=sigma;

%Displaying Output
if strcmp(Disp,'y')
    plot(F,Pnoise,'k','linewidth',2)
    hold on
    plot(F,Pmodel,'r','linewidth',2)
    %plot(F,Pss,'k','linewidth',2)
    %plot(F,Pkk,'g')
    %hold on
    %plot(F,Pkl,'b')
    ylabel('Magnitude')
    xlabel('Frequency (Hz)')
    title('Black=Theoretical Spectrum, Green=Pkk, Blue=Pkl, Red=Pnoise')
end