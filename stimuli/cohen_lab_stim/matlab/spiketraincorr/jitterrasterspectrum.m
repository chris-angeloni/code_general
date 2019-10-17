%
%function [JitterSpecData]=jitterrasterspectrum(RASTER,Fsd,df,Disp)
%
%       FILE NAME   : JITTER RASTER SPECTRUM
%       DESCRIPTION : Computes the across trial (Pkl) and signel trial
%                     (Pkk) specturms from a RASTERGRAM. Uses Pkk and
%                     Pkl to estimate the neurons noise spectrum (PNoise)
%                     and the Hypothetical Denoised Spectrum (Pss).
%
%       RASTER      : RASTERGRAM - Compressed Format
%       Fsd         : Desired Sampling rate for spectral analysis
%       df          : Spectral resolution (Hz)
%       Disp        : Display Output (Optional; Default='n')
%
%Returned Variables
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
% (C) Monty A. Escabi, August 2006 (Edit Oct 2010)
%
function [JitterSpecData]=jitterrasterspectrum(RASTER,Fsd,df,Disp)

%Input Arguments
if nargin<4
	Disp='n';
end

%Across-Trial Spectral Density
[F,Pkl,PklS,df]=csdraster(RASTER,Fsd,df);

%Spectral Density
[F,Pkk,PkkS,df]=psdraster(RASTER,Fsd,df);

%Mean Firing Rate including reliability errors
lambdap=length([RASTER.spet])/RASTER(1).T/length(RASTER);

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
    plot(F,Pnoise,'r','linewidth',2)
    hold on
    plot(F,Pss,'k','linewidth',2)
    plot(F,Pkk,'g')
    hold on
    plot(F,Pkl,'b')
    ylabel('Magnitude')
    xlabel('Frequency (Hz)')
    title('Black=Theoretical Spectrum, Green=Pkk, Blue=Pkl, Red=PNoise')
end