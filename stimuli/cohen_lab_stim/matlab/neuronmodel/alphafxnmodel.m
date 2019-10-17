%
%function [F]=alphafxnmodel(beta,time)
%
%       FILE NAME       : ALPHA FXN MODEL
%       DESCRIPTION     : Two segment alpha function. Used to fit EPSP or
%                         FTC PSTH with sharp onset 
%
%       beta            : Alpha fxn parameter array. Contains the following
%                         parameters: beta = [delay t1 t2 alpha]
%
%                         delay - temporal delay (msec)
%                         t1 - Rise Time Constant (msec)
%                         t2 - Decay Time Constant (msec)
%                         alpha - Alpha Function Amplitude
%                         K - DC offset
%
%       time            : Time axis (msec)
%
%OUTPUT SIGNAL
%
%       F               : Returned gamma function
%
function [F]=alphafxnmodel(beta,time)

%Parameters
delay=beta(1);
t1=beta(2);
t2=beta(3);
alpha=beta(4);
K=beta(5);

%Converting Decay and Rise Times from msec to sec
time=time/1000;
Fs=1/(time(2)-time(1));
t1=t1/1000;
t2=t2/1000;
delay=delay/1000;

%Number of samples per segment
ND=floor(delay*Fs);
N1=floor((t1+delay)*Fs+1E-10)-ND;        %1E-10 added for roundoff error
N2=length(time)-ND-N1;

%Generating Alpha Fxn (2 segments)
time1=(0:N1-1)/Fs+delay-ND/Fs;
F(1:N1)=K+alpha*time1/t1.*exp(-time1/t1)/exp(-1);
time2=(N1:N2+N1-1)/Fs+delay-ND/Fs;
F(N1+1:N2+N1)=K+alpha.*(time2+t2-t1)/t2.*exp((-time2+t1-t2)/t2)/exp(-1);
F=[K*ones(1,ND) F];                      %Adding Fixed Delay