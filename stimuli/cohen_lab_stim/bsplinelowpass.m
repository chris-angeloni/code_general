%
%function [h]=bsplinelowpass(fc,p,Fs)
%
%       FILE NAME       : CARDINAL B SPLINE LOWPASS
%       DESCRIPTION     : Generates the p-th order cardinal b-spline
%                         function
%
%       fc              : Cutoff frequency (Hz)
%       p               : B-spline order
%       Fs              : Sampling rate
%
%RETURNED VALUES
%       h               : Impulse response
%
%   (C) M. Escabi, Jan 2008 (Edit March 2009)
%
function [h]=bsplinelowpass(fc,p,Fs)

%Normalizing cutoff for frequency domain prototype
%This is done by finding the 3-dB cutoff and frequency shifting
%Note that the prototopy is of the form: tau^p*sinc(1/pi*w*tau/2/p).^p
Opt=optimset('fsolve');
Opt.TolFun=1E-10;                       %set tolerance for optimization
Opt.TolX=1E-10;                         %set tolerance for optimization
x = fsolve(@(x) sinc(1/pi*x).^(p)-1/sqrt(2),[0:.05:2],Opt);
tau=2*x(2)/2/pi/fc*p;                   %tau is the with of the B-spline in the time domain
N=round(tau*Fs/2);                      %Number of samples
time=(-N:N)/Fs;                         %Real time axis
time=time/tau*2;                        %Normalized time axis - between [-1 1]
h=1/pi/tau*cardinalbspline(time,p);     %Normalization provides a DC gain of 1 - note that the area of the "ideal" spline is 2*pi
