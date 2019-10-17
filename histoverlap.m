function [counts, centers, index] = histoverlap(X,edges)

% function [counts, centers] = histoverlap(X,edges)
%
% makes a histogram with overlapping edges
% INPUTS:
% X: vector of values to compute histogram over
% edges: matrix of bin edges to compute sums over (needs to be
% 2xNbins)
% 
% OUTPUTS:
% counts: number of occurrances in X in each bin
% centers: the mean value of each histogram bin

if size(edges,1) == 2
    edges = edges';
elseif ~any(size(edges)) == 2
    error(['Edges must have two rows or columns, each pair corresponding ' ...
           'to the bin edges']);
end

index = [];
for i = 1:length(edges)
    counts(i) = sum(X >= edges(i,1) & X <= edges(i,2));
    centers(i) = mean(edges(i,:));
    index = [index ones(1,counts(i)) * i];
end



