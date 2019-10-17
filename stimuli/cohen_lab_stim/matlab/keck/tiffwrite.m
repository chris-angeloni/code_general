function status = tiffwrite(arg1, arg2, arg3, arg4, arg5)
%TIFFWRITE Write a TIFF (Tagged Image File Format) file to disk.
%	TIFFWRITE(R,G,B,'filename') writes a TIFF file containing the RGB
%	image in the matrices R,G,B to a disk file called 'filename'.
%
%	TIFFWRITE(X,MAP,'filename') writes a TIFF file containing the
%	indexed image X and colormap MAP to a file called 'filename'.
%	Depending on the number of colors in MAP, TIFFWRITE creates a
%	8-bit or 4-bit TIFF file.  
%
%	TIFFWRITE(I,'filename') writes a TIFF file containing the
%	intensity image I to a file called 'filename'.  Intensity
%	images are written to the file as 8-bit indexed images
%	with a GRAY(256) colormap.  Binary images are written to 
%	the file as 1-bit indexed images with a GRAY(2) colormap.
%
%	TIFFWRITE(...,'compress_flag') permits control over compression.
%	'compress' forces TIFFWRITE to write a compressed TIFF file.
%	'nocompress' forces TIFFWRITE to write an uncompressed TIFF file.
%	'auto' tells tiffwrite to determine whether or not to compress
%	the image. The default is 'nocompress'.
%
%	The extension '.tif' will be added to 'filename' if it 
%	doesn't already have an extension.
%
%	TIFFWRITE is a baseline TIFF writer except that it doesn't
%	support CCITT compression.  TIFFWRITE can write only 
%	uncompressed and packbits compressed files.  LZW compression
%	is not supported.
%
%	See also TIFFREAD, GIFWRITE, HDFWRITE, BMPWRITE, PCXWRITE, XWDWRITE.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.13 $  $Date: 1993/09/09 21:33:26 $

% get size of drawing
[height,width] = size(arg1);

%TYPES: 1 - gray, 2 - RGB, 3 - palette

if nargin < 2, 
  error('Not enough input arguments.');
elseif nargin==2, % tiffwrite(I,'filename')
  if ~isstr(arg2), error('Filename must be a string.'); end
  % gray scale
  type = 1;
  draw = arg1;
  filename = arg2;
  comp_flag = 'nocompress';
elseif nargin==3
  if ~isstr(arg2),
    if size(arg2,2)~=3, error('Colormaps must be N-by-3.'); end
    % tiffwrite(A,CM,'filename') - palette color
    type = 3;
    draw = arg1-1;
    gct = arg2;
    filename = arg3;
    comp_flag = 'nocompress';
  else
    % tiffwrite(I,'filename','compress_flag') - gray scale
    type = 1;
    draw = arg1;
    filename = arg2;
    comp_flag = arg3;
  end
elseif nargin==4
  if isstr(arg3) == 0
    % tiffwrite(R,G,B,'filename') - rgb full color
    type = 2;
    draw = zeros(size(arg1,1),3*size(arg1,2));
    draw(:,1:3:width*3) = round(arg1*255);
    draw(:,2:3:width*3) = round(arg2*255);
    draw(:,3:3:width*3) = round(arg3*255);
    filename = arg4;
    comp_flag = 'nocompress';
  else
    % tiffwrite(A,CM,'filename','compress_flag') - palette color
    type = 3;
    draw = arg1-1;
    gct = arg2;
    filename = arg3;
    comp_flag = arg4;
  end
elseif nargin==5, % tiffwrite(R,G,B,'filename,'compress_flag')
  type = 2;
  draw = zeros(size(arg1,1),3*size(arg1,2));
  draw(:,1:3:width*3) = round(arg1*255);
  draw(:,2:3:width*3) = round(arg2*255);
  draw(:,3:3:width*3) = round(arg3*255);
  filename = arg4;
  comp_flag = arg5; 
else
  error('Too many arguments.');
end

%Add extension if necessary
if ~any(filename==46), filename = [filename,'.tif']; end

% open the file in big endian format
[file,message] = fopen(filename,'w','b');
if (file == -1), error(['Unable to open',filename,' for writing.']); end

% determine the number of bits needed per sample
%   1 bit for bilevel images
%   4 bits for palettes with 16 colors or less
%   8 bits for palettes with more than 16 colors
%   Grayscale images are always 8 bits
%   RGB images are always 8 bits per sample
bits = 8;
if (type == 1), % Intensity and binary images
  if isbw(draw),
    bits = 1;
    extra_cols = 8 - (width - floor(width/8)*8);
    if extra_cols < 8
      draw = [draw, zeros(height, extra_cols)];
    else
      extra_cols = 0;
    end
    w = width + extra_cols; 
    draw = draw(:,1:8:w)*128+draw(:,2:8:w)*64+draw(:,3:8:w)*32+...
    draw(:,4:8:w)*16+draw(:,5:8:w)*8+draw(:,6:8:w)*4+...
    draw(:,7:8:w)*2+draw(:,8:8:w);
  else
    bits = 8;
    draw = round(draw*255);	% 8 bit so need to spread out intensities
  end
end
if (type == 3), % Indexed images
  [m,n] = size(gct);
  if m <= 16
    bits = 4;
    w = width;
    if (width - floor(width/2)*2) == 1
      draw = [draw, zeros(height,1)];
      w = width +1;
    end
    draw = draw(:,1:2:w)*16 + draw(:,2:2:w);
  else
    bits = 8;
  end
  c_map = zeros(2^bits,3);
  c_map(1:m,:) = gct;
  c_map = round(c_map * 65535);
  c_map = reshape(c_map,2^bits*3,1);
end

comp_flag = [lower(comp_flag) ' ']; % Protect against short string
if comp_flag(1)=='n', % 'nocompress'
  comp = 1;
elseif comp_flag(1)=='c', % 'compress'
  comp = 32773;
  draw = tiff(draw);
elseif comp_flag(1)=='a', % 'auto'
  % Compress only if the number of repeated pixels is > .1 * number of pixels
  if sum(sum(diff(floor(draw),4)==0))>.5*prod(size(draw)),
    comp = 32773;
    draw = tiff(draw);
  else
    comp = 1;
  end
else
  error('''compress_flag'' must be ''compress'', ''nocompress'', or ''auto''.');
end
%
[m,n] = size(draw);
strip_bytes = m*n;

% write the tiff header
fwrite(file,'MM','uchar');
fwrite(file,42,'ushort');
fwrite(file,8,'ulong');

% create the image file directory (IFD)
if ((type == 1) | (type == 2))
  % don't have a color map
  fwrite(file,12,'ushort');
  strip_offset = 12*12+10;
else
  % do have a color map
  fwrite(file,13,'ushort');
  strip_offset = 13*12+10;
end
%
% set the offset for the first set of IFD values - must be word aligned
val_offset = ceil((strip_offset + strip_bytes)/2)*2;
%
% write out each 12 byte IFD entry
% image width
fwrite(file,256,'ushort');
fwrite(file,4,'ushort');
fwrite(file,1,'ulong');
fwrite(file,width,'ulong');
%
% image height
fwrite(file,257,'ushort');
fwrite(file,4,'ushort');
fwrite(file,1,'ulong');
fwrite(file,height,'ulong');
%
% bits per sample
fwrite(file,258,'ushort');
fwrite(file,3,'ushort');
if (type == 2)
  fwrite(file,3,'ulong');
  fwrite(file,val_offset,'ulong');
  val_offset = val_offset + 6;
else
  fwrite(file,1,'ulong');
  fwrite(file,bits,'ushort');
  fwrite(file,0,'ushort');
end
%
% compression
fwrite(file,259,'ushort');
fwrite(file,3,'ushort');
fwrite(file,1,'ulong');
fwrite(file,comp,'ushort');
fwrite(file,0,'ushort');
%
% photometric interpretation
fwrite(file,262,'ushort');
fwrite(file,3,'ushort');
fwrite(file,1,'ulong');
fwrite(file,type,'ushort');
fwrite(file,0,'ushort');
%
% strip offsets
fwrite(file,273,'ushort');
fwrite(file,4,'ushort');
fwrite(file,1,'ulong');
fwrite(file,strip_offset,'ulong');
%
% samples per pixel
fwrite(file,277,'ushort');
fwrite(file,3,'ushort');
fwrite(file,1,'ulong');
if (type == 2)
  fwrite(file,3,'ushort');
else
  fwrite(file,1,'ushort');
end
fwrite(file,0,'ushort');
%
% rows per strip
fwrite(file,278,'ushort');
fwrite(file,4,'ushort');
fwrite(file,1,'ulong');
fwrite(file,height,'ulong');
%
% strip byte counts
fwrite(file,279,'ushort');
fwrite(file,4,'ushort');
fwrite(file,1,'ulong');
fwrite(file,strip_bytes,'ulong');
%
% X resolution
fwrite(file,282,'ushort');
fwrite(file,5,'ushort');
fwrite(file,1,'ulong');
fwrite(file,val_offset,'ulong');
val_offset = val_offset + 8;
%
% Y resolution
fwrite(file,283,'ushort');
fwrite(file,5,'ushort');
fwrite(file,1,'ulong');
fwrite(file,val_offset,'ulong');
val_offset = val_offset + 8;
%
% resolution unit
fwrite(file,296,'ushort');
fwrite(file,3,'ushort');
fwrite(file,1,'ulong');
fwrite(file,1,'ushort');
fwrite(file,0,'ushort');
%
if (type == 3)
  % color map
  fwrite(file,320,'ushort');
  fwrite(file,3,'ushort');
  fwrite(file,2^bits*3,'ulong');
  fwrite(file,val_offset,'ulong');
end

% IFD is complete, now write the actual data
%
% first write the image
fwrite(file,draw','uchar');
%
% next, make sure that IFD values are word-aligned 
if (ceil((strip_offset + strip_bytes)/2)*2 > (strip_offset + strip_bytes))
  fwrite(file,0,'uchar');	 
end
%
% write out the bits per sample if necessary
if (type == 2)
  fwrite(file,[8 8 8],'ushort');
end
%
% write out the x and y resolution fractions
fwrite(file,[1 72 1 72],'ulong');
%
% now, write the color map if there is one
if (type == 3)
  fwrite(file,c_map,'ushort');
end
fclose(file);
