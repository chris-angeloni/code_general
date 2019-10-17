function f = ridge_filter(width)
% Generate a filter tuned to ridges that are 2*width samples wide.
%
% The idea is that convolving the resultant filters will return maximal
% values over ridges of the corresponding width, and return zero over
% uniform regions.

x = (-5*width):(5*width);
f = (1 - (1/width^2) * x.^2) .* exp(-x.^2 / (2*width^2));