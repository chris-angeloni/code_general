function edges = absBandEdge(dataCol, level);
%function edges = absBandEdge(dataCol, level);
% compute bandedges at absolute intensities 
%                      (rather than relative to threshold at CF)
%
% dataCol: column of data from ntc data matrix
% level: stimulus level at which FRA edges should be computed
% edges: [lowEdge highEdge]

INCLUDE_DEFS;

thresh = dataCol(THRESHOLD);
if (level > thresh) & (level < thresh+40),
    x = thresh + (0:10:40);
    ylow = dataCol(...
        [CF INFO10+OFFSETA INFO20+OFFSETA INFO30+OFFSETA INFO40+OFFSETA]);
    yhigh = dataCol(...
        [CF INFO10+OFFSETB INFO20+OFFSETB INFO30+OFFSETB INFO40+OFFSETB]);
    highEdge = interp1(x,yhigh,level);
    lowEdge = interp1(x,ylow,level);
  else
    highEdge = NaN;
    lowEdge = NaN;
  end % (if)
  
edges = [lowEdge highEdge];

return

