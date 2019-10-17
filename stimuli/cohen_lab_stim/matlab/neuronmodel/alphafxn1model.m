%
%function [F]=alphafxn1model(beta,time)
%
%       FILE NAME       : ALPHA FXN 1 MODEL
%       DESCRIPTION     : One segment alpha function. Used to fit EPSP or
%                         FTC PSTH with sharp onset 
%
%       beta            : Alpha fxn parameter array. Contains the following
%                         parameters: beta = [delay tau alpha K]
%
%                         delay - temporal delay (msec)
%                         tau   - Time Constant (msec)
%                         alpha - Alpha Function Amplitude
%                         K     - DC offset
%
%       time            : Time axis (msec)
%
%OUTPUT SIGNAL
%
%       F               : Returned alpha function
%
function [F]=alphafxn1model(beta,time)

%Parameters
delay=beta(1);
tau=beta(2);
alpha=beta(3);
K=beta(4);

%Converting Decay and Rise Times from msec to sec
time=time/1000;
Fs=1/(time(2)-time(1));
tau=tau/1000;
delay=delay/1000;

%Generating Alpha Fxn (1 segment)
F=(time-delay)/tau.*exp(-(time-delay-tau)/tau);
ND=floor(delay*Fs);
F(1:ND)=zeros(1,ND);