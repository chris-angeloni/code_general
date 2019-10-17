function b = estDrift(evObs,evTrue)

% function b = estDrift(evObs,evTrue)
%
% Uses a linear model to estimate the scaling parameters between
% observed event times and actual event times. Assumes that spikes
% will ultimately be columns, and estimates the intercept (0
% crossing of first event) so requires a column of ones and a
% column of spikes to make the adjustment.
%
% spks_true = [ones(length(spks),1) spks] * b;
%
%  INPUT:
%   evObs  = array of clock times for each event in evTrue
%   evTrue = array of real event times for each event in evObs
%
%  OUTPUT:
%   b = parameters fitting evObs to evTrue, thus allowing you to 
%       matrix multiply an array of spike times (and column of ones)
%       to convert them to real time
%
%  EXAMPLE:
%  
%   evObs = block(1).stimOn; % recorded event times
%   evTrue = 0:block(1).dt:block(1).n*block(1).dt)-1; % true times
%   b = estDrift(evObs,evTrue);
%   spks_true = [ones(size(block(1).spikes)) block(1).spikes] * b;

% x predicts y, thus maps from clock time to true time
x = evObs;
y = evTrue;

% transpose each to column vectors
if size(x,1) == 1
    x = x';
elseif size(y,1) == 1
    y = y';
end

X = [ones(size(x)) x];

b = X\y;

