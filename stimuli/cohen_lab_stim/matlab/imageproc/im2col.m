function b=im2col(a,block,kind)
%IM2COL	Rearrange image blocks into columns.
%	IM2COL rearranges blocks of an image into columns for
%	column-based processing. IM2COL handles two types of blocks,
%	'distinct' and 'sliding'. 'sliding' is the default. See the Image
%	Processing Toolbox guide for the definition of these two block
%	types.
%
%	B = IM2COL(A,[M N],'distinct') rearranges each distinct M-by-N
%	block of the matrix A into columns of B. A is padded, if
%	necessary so that its size is a multiple of M-by-N. A is padded
%	with ones if it is an indexed image or padded with zeros
%	otherwise.  If A = [A11 A12;A21 A22] where each Aij is M-by-N,
%	then B = [A11(:) A21(:) A12(:) A22(:)].
%
%	B = IM2COL(A,[M N],'sliding') converts each M-by-N sliding
%	neighborhood of A into a column of B. A is not padded. B will
%	have M*N rows and will contain as many columns as there are
%	M-by-N neighborhoods of A. If A is MA-by-NA then B will 
%	be (M*N)-by-((MA-M+1)*(NA-N+1)).  Each column of B contains the
%	neighborhoods of A reshaped as N(:) where N is an M-by-N 
%	neighborhood of A. The columns of B are ordered so that they can
%	be reshaped to form a matrix in the normal way. For instance, 
%	suppose B is operated upon by a function that compresses each 
%	column to a scalar (for example, SUM(B)) then the result can be
%	directly deposited into a (MA-M+1)-by-(NA-N+1) matrix using 
%	COL2IM, e.g. C = COL2IM(SUM(B),[MA NA],'sliding');
%
%	COL2IM undoes the effect of IM2COL. IM2COL is used by the function
%	COLFILT.
%
%	Example use: Distinct Blocks      | Example use: Sliding Blocks
%	 [m,n] = size(a);                 |  [m,n] = size(a);
%	 b = im2col(a,[3 3],'distinct');  |  b = im2col(a,[3 3],'sliding');
%	 c = (ones(9,1)/9)*sum(b);        |  c = sum(b)/9;
%	 d = col2im(c,[3 3],size(a),'d'); |  d = col2im(c,[3 3],size(a),'s');
%
%	See also: COL2IM, COLFILT.

%	Clay M. Thompson 10-6-92
%	Copyright (c) 1992 by The MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 1993/09/30 17:17:08 $

error(nargchk(2,3,nargin));
if nargin<3, kind = 'sliding'; end

if ~isstr(kind), 
  error('The block type parameter must be either ''distinct'' or ''sliding''.');
end

kind = [lower(kind) ' ']; % Protect against short string

if kind(1)=='d', % Distinct
  % Pad A if size(A) is not divisible by block.
  [m,n] = size(a);
  mpad = rem(m,block(1)); if mpad>0, mpad = block(1)-mpad; end
  npad = rem(n,block(2)); if npad>0, npad = block(2)-npad; end
  if isind(a),
    aa = ones(m+mpad,n+npad);
  else
    aa = zeros(m+mpad,n+npad);
  end
  aa(1:m,1:n) = a;
  
  [m,n] = size(aa);
  mblocks = m/block(1);
  nblocks = n/block(2);
  
  b = zeros(prod(block),mblocks*nblocks);
  x = zeros(prod(block),1);
  rows = 1:block(1); cols = 1:block(2);
  for i=0:mblocks-1,
    for j=0:nblocks-1,
      x(:) = aa(i*block(1)+rows,j*block(2)+cols);
      b(:,i+j*mblocks+1) = x;
    end
  end
  
elseif kind(1)=='s', % Sliding
  [ma,na] = size(a);
  m = block(1); n = block(2);
  
  % Create Hankel-like indexing sub matrix.
  mc = block(1); nc = ma-m+1; nn = na-n+1;
  cidx = (0:mc-1)'; ridx = 1:nc;
  t = cidx(:,ones(nc,1)) + ridx(ones(mc,1),:);    % Hankel Subscripts
  tt = zeros(mc*n,nc);
  rows = [1:mc];
  for i=0:n-1,
    tt(i*mc+rows,:) = t+ma*i;
  end
  ttt = zeros(mc*n,nc*nn);
  cols = 1:nc;
  for j=0:nn-1,
    ttt(:,j*nc+cols) = tt+ma*j;
  end
  b = a(ttt);
else
  error([deblank(kind),' is a unknown block type']);
end

