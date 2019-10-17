%
%function [F]=tcfhalfpowfreq(w,beta)
%
%   FILE NAME   : TCF HALF POW FREQ
%   DESCRIPTION : Used to evaluates the half power frequency based the
%                 temporal coding fraction. The routine is desgined to run
%                 with LSQCURVEFIT. The returned paramter F =
%                 abs(AC*(1-0.5*Max) - 0.5*Max*DC) corresponds to the
%                 criteria required for half power. Half power is achieved
%                 when F = 0 and Lamdas=0. If Lambdas!=0 then the procedure 
%                 optimizes to find when the curve reaches 1/2 of the 
%                 maximum TCF for the input parameters. LSQCURVEFIT solves
%                 for the value of w where F=0.
%
%   w           : Radian Frequency (2*pi*Fm, rad/sec)
%   beta        : Model Parameter Vector
%                 lambdas   = spontaneous firing rate       = beta(1) 
%                 x         = reliability (spikes/cycle)    = beta(2)
%                 sigma     = spike timing jitter SD (ms)   = beta(3) 
%
%RETURNED VARIABLES
%
%   F          : Where F = abs(AC*(1-0.5*Max) - 0.5*Max*DC)
%                This is the criteria required to find the 1/2 power
%                frequency using LSQCURVEFIT. At half power F = 0
%
% (C) Monty A. Escabi, Aug 2014
%
function [F]=tcfhalfpowfreq(w,beta)

%Extracting Parameters
lambdas=beta(1);
x=beta(2);
sigma=beta(3);

%Finding Maximum TFC value
if lambdas>0 
    %Genrating TFC Curve - used to find maximum value
    L=500;
    Fm=.1*2.^(log2(500/.1)/L*(0:L));    %500 logarithmic spaced points between .1 and 500 Hz
    [Ft]=temporalcodingfractiontheoretical(sigma,x,lambdas,Fm);
    Max=max(Ft);
else
    Max=1;
end

%Finding Frequency at half maximum amplitude
sigma=sigma/1000;
k=1:100;
DC=4*pi^2*(lambdas+x*w/2/pi).^2;
AC=2*x^2.*w.^2*sum(exp(-k.^2*sigma^2.*w.^2));
F=AC./(AC+DC);
F=abs(AC*(1-0.5*Max) - 0.5*Max*DC);     %Criteria for half-power based on the maximum value of TCF