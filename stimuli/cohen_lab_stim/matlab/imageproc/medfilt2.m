function b = medfilt2(a,mn,block)
%MEDFILT2 Two-dimensional median filtering.
%	J = MEDFILT2(I,[M N]) performs median filtering of the 
%	image I in two dimensions.  The result J contains the 
%	median value in the M-by-N neighborhood around each pixel
%	in the original image. The image is assumed to be padded 
%	with 0s outside so the median values for the points within 
%	[M N]/2 of the edges may appear distorted. Block processing
%	is used to save memory (see BESTBLK).
%
%	J = MEDFILT2(I) uses a 3-by-3 neighborhood.
%
%	J = MEDFILT2(I,[M N],[MBLOCK NBLOCK]) performs median 
%	filtering of I in blocks of size MBLOCK-by-NBLOCK.  Use 
%	MEDFILT2(I,[M N],SIZE(I)) to process the matrix all at once.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.9 $  $Date: 1993/09/10 00:06:23 $

error(nargchk(1,3,nargin));
if nargin<2, mn = [3 3]; end
if nargin<3, block = bestblk(size(a)); end

if all(block>=size(a)),
  b = colfilt(a,mn,'sliding','median');
else
  b = colfilt(a,mn,block,'sliding','median');
end
