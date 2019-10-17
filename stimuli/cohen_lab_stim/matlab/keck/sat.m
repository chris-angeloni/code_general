%
%function [y]=sat(x,xmax)
%
%
%       FILE NAME       : SAT
%       DESCRIPTION     : Saturates (Clips) a signal at xmax
%
%	x		: Input
%	xmax		: Saturation Level
%	y		: Output
%
function [y]=sat(x,xmax)

y=min(xmax,x);
