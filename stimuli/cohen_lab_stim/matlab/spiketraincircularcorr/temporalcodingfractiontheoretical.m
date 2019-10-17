%
%function [Ft]=temporalcodingfractiontheoretical(sigma,x,lambdas,Fm)
%
%   FILE NAME   : Temporal Coding Fraction Theoretical
%   DESCRIPTION : Evaluation of the theoretical solution for the temporal 
%                 coding fraction
%
%                           F = sum(Ak^2)/sum(A0^2 + Ak^2)
%
%                 where Ak are the Fourier coefficients of the harmonic
%                 response componets and A0 is the DC coefficient. 
%                 This is a new version of the temporal coding fraction which
%                 is different from that defined by Yi & Escabi (2013): 
%
%                           F = lambda_ac^2/(lambda_dc + lambda_ac)^2
%
%   sigma       : Spike timming jitter standard deviation (ms)
%   x           : Reliability or reliable spikes / cycle (in spikes/cycle)
%   lambdas     : Spontaneous firing rate (Hz)
%   Fm          : Modulation frequency (can be a scalar or vector)
%
%RETURNED VARIABLES
%
%   Ft          : Theoretical value of F
%
% (C) Monty A. Escabi, July 2014
%
function [Ft]=temporalcodingfractiontheoretical(sigma,x,lambdas,Fm)

%Theoretical Equation for TCF
sig=sigma/1000;
w0=2*pi*Fm;
for l=1:length(w0)
        k=1:100;
        DCt(l)=4*pi^2*(lambdas+x*w0(l)/2/pi).^2;
        ACt(l)=2*x^2.*w0(l).^2*sum(exp(-k.^2*sig^2.*w0(l).^2));
        Ft(l)=ACt(l)./(ACt(l)+DCt(l));     
end