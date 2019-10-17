function y = isind(x)
%ISIND True for indexed images.
%	ISIND(A) returns 1 if A is an indexed image and 0 otherwise.
%	An indexed image contains integer values that are indices into
%	an associated colormap.
%
%	See ISGRAY, ISBW.

%	Clay M. Thompson 2-25-93
%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1994/03/04 19:53:26 $

y = (min(min(x))>=1 & max(max(x))<=256) & all(all(abs(x-floor(x))<eps));
