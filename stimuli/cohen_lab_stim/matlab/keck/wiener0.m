%
%function [W0]=wiener0(spet,T)
%
%       FILE NAME       : Wiener0
%       DESCRIPTION     : Zeroth order Wiener Kernel
%
%	spet		: Array of spike event times in sample number
%	T		: Signal length (min)
%
function [W0]=wiener0(spet,T)

W0=length(spet)/T/60;
