%
%function [X]=cardinalbsplinetone(T,fc,p,Fs)
%
%       FILE NAME       : CARD B SPLINE TONE
%       DESCRIPTION     : Generates a tone that is multiplied by a
%                         cardinal b-spline envelope
%
%       T               : Tone Duration (msec)
%       fc              : Carrier frequency (Hz)
%       p               : B-Spline order (Number of Knots=p+1)
%       Fs              : Sampling Rate
%
%RETURNED VARIABLES
%
%       X               : B-Spline modulated tone
%       E               : B-Spline Envelope
%
% (C) Monty A. Escabi, Feb 2009
%
function [X,E]=cardinalbsplinetone(T,fc,p,Fs)

%Number of Samples and Time axis
N=floor(T/1000*Fs/2);
Time=(-N:N)/N;

%Generating B-spline envelope and Modulated Tone
E=cardinalbspline(Time,p);
E=E/max(E);
X=E.*sin(2*pi*fc*(0:2*N)/Fs);
