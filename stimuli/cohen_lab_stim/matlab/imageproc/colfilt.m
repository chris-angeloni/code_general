function b = colfilt(a,nhood,block,kind,P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10)
%COLFILT Non-linear filtering as columns.
%	COLFILT is used to non-linear filter an image with a column
%	based method.  COLFILT handles two types of blocks, 'distinct'
%	and 'sliding'. See the Image Processing Toolbox guide for the 
%	definition of these two block types.  COLFILT uses IM2COL to 
%	rearrange the image into columns before processing.
%
%	B = COLFILT(A,[M N],'sliding','fun') applies the m-file 'fun' to
%	each M-by-N sliding neighborhood of A.  The m-file 'fun' should 
%	operate on the columns of its argument and return a result, 
%	c = fun(x) of size 1-by-size(x,2), which is the filtered value
%	for the center pixel in the M-by-N neighborhood.  Block 
%	processing is used to save memory (see BESTBLK).
%
%	B = COLFILT(A,[M N],'distinct','fun') applies the m-file 'fun'
%	to each M-by-N distinct block of A.  The m-file 'fun' should 
%	operate on the columns of its argument and return a result,
%	c = fun(x) the same size as x, which is the filtered value for
%	the M-by-N block. Block processing is used to save memory
%	(see BESTBLK).
%
%	B = COLFILT(A,[M N],[MBLOCK NBLOCK],'type','fun') processes the
%	the matrix A as above but in blocks of size MBLOCK-by-NBLOCK.
%	'type' can be is either 'sliding' or 'distinct'.
%
%	Up to 10 additional parameters can be passed to the function
%	 'fun' using
%	   B=COLFILT(A,[M N],'type','fun',P1,P2,P3,...) or
%	   B=COLFILT(A,[M N],[MBLOCK NBLOCK],'type','fun',P1,P2,P3,...)
%	in which case 'fun' is called using c = fun(x,P1,P2,P3,...).
%	At the edges, the M-by-N block is formed by padding
%	with ones if A is an indexed image or with zeros otherwise.
%	This function can be used to perform the same purpose as 
%	NLFILTER but much faster.
%
%	Example: Distinct block averaging (pixelation)
%	    b = colfilt(a,[3 3],'distinct','ones(9,1)*sum(x)/9');
%
%	Example: Sliding block averaging (smoothing)
%	    b = colfilt(a,[3 3],'sliding','sum(x)/9');
%
%	See also NLFILTER, BLKPROC, IM2COL, COL2IM.

%	Clay M. Thompson 1-25-93
%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.15 $  $Date: 1993/09/30 17:16:54 $

error(nargchk(4,15,nargin));

if nargin==4,
  FUN = kind;
  kind = block;
  block = bestblk(size(a));
  if ~any(FUN<48), fcall = [FUN,'(x)']; else fcall = FUN; end
else
  if isstr(P0), 
    FUN = P0; 
    % Form call string.
    params = [];
    for n=6:nargin
      params = [params,',P',int2str(n-5)];
    end
    if ~any(FUN<48), fcall = [FUN,'(x',params,')']; else fcall = FUN; end
  else
    FUN = kind;
    kind = block;
    block = bestblk(size(a));
    % Form call string and shift parameters
    params = [];
    for n=5:nargin
      params = [params,',P',int2str(n-3)];
      eval(['P',int2str(nargin-n+1),'=P',int2str(nargin-n),';']);
    end
    if ~any(FUN<48), fcall = [FUN,'(x',params,')']; else fcall = FUN; end
  end
end

if ~isstr(kind), 
  error('The block type parameter must be either ''distinct'' or ''sliding''.');
end

kind = [lower(kind) ' ']; % Protect against short string

if kind(1)=='s', % Sliding
  if all(block>=size(a)), % Process the whole matrix at once.
    % Expand A
    [ma,na] = size(a);
    if isind(a),
      aa = ones(size(a)+nhood-1);
    else
      aa = zeros(size(a)+nhood-1);
    end
    aa(floor((nhood(1)-1)/2)+(1:ma),floor((nhood(2)-1)/2)+(1:na)) = a;
  
    % Convert neighborhoods of matrix A to columns
    x = im2col(aa,nhood,'sliding');
  
    % Apply m-file to column version of a
    b = zeros(size(a));
    b(:) = eval(fcall);
  
  else, % Process the matrix in blocks of size BLOCK.
    % Expand A: Add border, pad if size(a) is not divisible by block.
    [ma,na] = size(a);
    mpad = rem(ma,block(1)); if mpad>0, mpad = block(1)-mpad; end
    npad = rem(na,block(2)); if npad>0, npad = block(2)-npad; end
    if isind(a),
      aa = ones(size(a) + [mpad npad] + (nhood-1));
    else
      aa = zeros(size(a) + [mpad npad] + (nhood-1));
    end
    aa(floor((nhood(1)-1)/2)+(1:ma),floor((nhood(2)-1)/2)+(1:na)) = a;
  
    %
    % Process each block in turn.
    %
    m = block(1) + nhood(1)-1;
    n = block(2) + nhood(2)-1;
    mblocks = (ma+mpad)/block(1);
    nblocks = (na+npad)/block(2);
    b = zeros(ma+mpad,na+npad);
    arows = (1:m); acols = (1:n);
    brows = (1:block(1)); bcols = (1:block(2));
    mb = block(1); nb = block(2);
    for i=0:mblocks-1,
      for j=0:nblocks-1,
        x = im2col(aa(i*mb+arows,j*nb+acols),nhood);
        b(i*mb+brows,j*nb+bcols) = reshape(eval(fcall),block(1),block(2));
      end
    end
    b = b(1:ma,1:na);
  end

elseif kind(1)=='d', % Distinct
  if all(block>=size(a)), % Process the whole matrix at once.
   % Convert neighborhoods of matrix A to columns
    x = im2col(a,nhood,'distinct');
  
    % Apply m-file to column version of A and reshape
    b = col2im(eval(fcall),nhood,size(a),'distinct');
  
  else, % Process the matrix in blocks of size BLOCK.
    % Expand BLOCK so that it is divisible by NHOOD.
    mpad = rem(block(1),nhood(1)); if mpad>0, mpad = nhood(1)-mpad; end
    npad = rem(block(2),nhood(2)); if npad>0, npad = nhood(2)-npad; end
    block = block + [mpad npad];
    
    % Expand A: Add border, pad if size(A) is not divisible by BLOCK.
    [ma,na] = size(a);
    mpad = rem(ma,block(1)); if mpad>0, mpad = block(1)-mpad; end
    npad = rem(na,block(2)); if npad>0, npad = block(2)-npad; end
    if isind(a),
      aa = ones(size(a) + [mpad npad]);
    else
      aa = zeros(size(a) + [mpad npad]);
    end
    aa((1:ma),(1:na)) = a;
  
    %
    % Process each block in turn.
    %
    m = block(1); n = block(2);
    mblocks = (ma+mpad)/block(1);
    nblocks = (na+npad)/block(2);
    b = zeros(ma+mpad,na+npad);
    rows = 1:block(1); cols = 1:block(2);
    for i=0:mblocks-1,
      ii = i*m+rows;
      for j=0:nblocks-1,
        jj = j*n+cols;
        x = im2col(aa(ii,jj),nhood,'distinct');
        b(ii,jj) = col2im(eval(fcall),nhood,block,'distinct');
      end
    end
    b = b(1:ma,1:na);
  end

else
  error([deblank(kind),' is a unknown block type']);
end
