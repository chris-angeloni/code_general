%
%function [X]=cardinalbsplineamtone(T,fc,Fm,p,Fs)
%
%       FILE NAME       : CARD B SPLINE TONE
%       DESCRIPTION     : Generates a tone that is periodically 
%                         modulated by a cardinal b-spline envelope. The
%                         envelope duration is rounded up for a integer
%                         number of periods. This envelope is different
%                         than the one used in PNBBSPLINEAMNOISE.
%
%       T               : Tone Duration (msec)
%       fc              : Carrier frequency (Hz)
%       Fm              : Modulation frequency (Hz)
%       p               : B-Spline order (Number of Knots=p+1)
%       Fs              : Sampling Rate
%
%RETURNED VARIABLES
%
%       X               : B-Spline modulated tone
%       E               : B-Spline Envelope
%       Fm              : Rounded off value for Fm
%
% (C) Monty A. Escabi, Feb 2009
%
function [X,E,Fm]=cardinalbsplineamtone(T,fc,Fm,p,Fs)

%Generating 
L=ceil(T/1000*Fm);
Tm=1/Fm*1000;
[X,EE]=cardinalbsplinetone(Tm,fc,p,Fs);

%Generating Envelope
E=[];
for k=1:L
   E=[E EE]; 
end

%Modulating Carrier
N=length(E);
X=E.*sin(2*pi*fc*(1:N)/Fs);

%Rounded of Fm
Fm=Fs/length(EE);