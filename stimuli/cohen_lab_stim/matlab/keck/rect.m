%
%function [y]=rect(x)
%
%
%       FILE NAME       : RECT
%       DESCRIPTION     : Rectifies a signal.
%
%	x		: Input
%	y		: Output
%
function [y]=rect(x)

y=max(x,0);
