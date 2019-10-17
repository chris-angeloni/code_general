function [K]=findK(s,sd)

R=findR(s,sd);
K= R + sqrt( 1 + R^2 );
