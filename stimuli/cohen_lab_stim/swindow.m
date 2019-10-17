%
%function [W]=swindow(Fs,p,dt)
%
%       FILE NAME       : SWINDOW
%       DESCRIPTION     : Smoothing window desinged using B-Spline derivation 
%			  by Roark and Escabi
%
%       Fs		: Sampling Rate
%	p		: B-spline window transition region order
%	dt		: B-spline window width ( msec )
%	
function [W]=swindow(Fs,p,dt)

%Generating window function
alpha=1;
wc=pi*.99;
wres=2*pi/round(dt/1000*Fs);
[Faxis,W]=wproto(p,alpha,wc,wres);
W=W/sum(W);
