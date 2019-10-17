function [r,g,b] = tiffread(filename)
%TIFFREAD Read a TIFF (Tagged Image File Format) file from disk.
%	[R,G,B] = TIFFREAD('filename') reads the TIFF file 'filename'
%	and returns the RGB image in the matrices R,G,B. 
%
%	[X,MAP] = TIFFREAD('filename') reads the file 'filename' and
%	returns the indexed image X and associated colormap MAP.
%	[X,MAP] is created via uniform quantization if the file
%	contains an RGB image.
%	
%	TYPE = TIFFREAD('filename') reads the file header and returns
%	24 if the image is an RGB image, 8 if it is an 8-bit indexed
%	image, 4 if it is a 4-bit indexed image, or 1 if it is a
%	1-bit (binary) indexed image.
%
%	If no extension is given with the filename, the extension
%	'.tif' is assumed.
%
%	Gray (intensity) and binary images are returned as indexed
%	images with a gray colormap.  Use IND2GRAY after reading the
%	file to create an intensity image.  For example,
%	    [X,map] = tiffread('grayimage.tif');
%	    I = ind2gray(X,map);
%
%	TIFFREAD is a baseline TIFF reader except that it doesn't
%	support CCITT compression.  TIFFREAD can read only 
%	uncompressed and packbits compressed files.  LZW compression
%	is not supported.
%
%	See also TIFFWRITE, IND2GRAY, GIFREAD, HDFREAD, BMPREAD, 
%	         PCXREAD, XWDREAD.

%	Copyright (c) 1993 by The MathWorks, Inc.
%	$Revision: 1.16 $  $Date: 1993/09/22 14:26:01 $

global file;
%
% set defaults
bits = 1;
comp = 1;
res_unit = 2;

if isempty(findstr(filename,'.'))
	filename=[filename,'.tif'];
end;

[file, message] = fopen(filename,'r','l');
if file == -1
  a=['file ',filename,' not found.'];
  error(a);
end

% read header
% read byte order: II = little endian, MM = big endian
byte_order = setstr(fread(file,2,'uchar'));
if ((~strcmp(byte_order','II')) & (~strcmp(byte_order','MM')))
  error('This is not a TIFF file (no MM or II).');
end

% read in a number which identifies file as TIFF format
if (strcmp(byte_order','II'))
  tiff_id = fread(file,1,'ushort','l');
else
  tiff_id = fread(file,1,'ushort','b');
end

if (tiff_id ~= 42)
  error('This is not a TIFF file (no 42).');
end

% read the byte offset for the first image file directory (IFD)
if (strcmp(byte_order','II'))
  ifd_pos = fread(file,1,'ulong','l');
else
  ifd_pos = fread(file,1,'ulong','b');
end

% move in the file to the first IFD
fseek(file,ifd_pos,-1);

%read IFD
%read in the number of IFD entries
if (strcmp(byte_order','II'))
  num_entries = fread(file,1,'ushort','l');
else 
  num_entries = fread(file,1,'ushort','b');
end

%read and process each IFD entry
for i = 1:num_entries
  % save the current position in the file
  file_pos = ftell(file);

  % read entry tag
  if (strcmp(byte_order','II'))
    tag = fread(file,1,'ushort','l');
  else
    tag = fread(file,1,'ushort','b');
  end

  % image width - number of columns
  if (tag == 256)
    if (strcmp(byte_order','II'))
      type = fread(file,1,'ushort','l');
      fseek(file,4,0);
      if (type == 3)
        width = fread(file,1,'ushort','l');
      else
        width = fread(file,1,'ulong','l');
      end
    else
      type = fread(file,1,'ushort','b');
      fseek(file,4,0);
      if (type == 3)
        width = fread(file,1,'ushort','b');
      else
        width = fread(file,1,'ulong','b');
      end
    end

  % image height - number of rows
  elseif (tag == 257)
    if (strcmp(byte_order','II'))
      type = fread(file,1,'ushort','l');
      fseek(file,4,0);
      if (type == 3)
        height = fread(file,1,'ushort','l');
      else
        height = fread(file,1,'ulong','l');
      end
    else
      type = fread(file,1,'ushort','b');
      fseek(file,4,0);
      if (type == 3)
        height = fread(file,1,'ushort','b');
      else
        height = fread(file,1,'ulong','b');
      end
    end

  % bits per sample
  elseif (tag == 258)
    if (strcmp(byte_order','II'))
      type = fread(file,1,'ushort','l');
      count = fread(file,1,'ulong','l');
      if (2*count > 4)
        % next field contains an offset
        val_offset = fread(file,1,'ulong','l');
        fseek(file,val_offset,-1);
        bits = fread(file,count,'ushort','l');
      else
        % next field contains values
        bits = fread(file,count,'ushort','l');
      end
    else
      type = fread(file,1,'ushort','b');
      count = fread(file,1,'ulong','b');
      if (2*count > 4)
        % next field contains an offset
        val_offset = fread(file,1,'ulong','b');
        fseek(file,val_offset,-1);
        bits = fread(file,count,'ushort','b');
      else
        % next field contains values
        bits = fread(file,count,'ushort','b');
      end
    end
    if (bits(1) ~= 1) & (bits(1) ~= 4) & (bits(1) ~=8)
      error('Unsupported number of bits per sample.');
    end
    num_samples = count;
    if nargout <= 1,
      if num_samples==3, % RGB image
        r = 24;
      elseif bits(1)==1, % binary image
        r = 1;
      elseif bits(1)==4, % 16 color indexed image
        r = 4;
      else
        r = 8;
      end
      return
    end
    if (nargout == 2) & (num_samples == 3),
      disp(['Warning: File contains an RGB image. ' ...
            'Color information will be lost.'])
      disp('  Use [r,g,b] = tiffread(''filename'') instead.')
    end
    if (nargout == 3) & (num_samples == 1),
      disp('Warning: File contains an indexed image. ')
      disp('  Use [a,cm] = tiffread(''filename'') instead.')
    end

  % compression
  elseif (tag == 259)
    if (strcmp(byte_order','II'))
      fseek(file,6,0);
      comp = fread(file,1,'ushort','l');
    else
      fseek(file,6,0);
      comp = fread(file,1,'ushort','b');
    end
    if (comp ~= 1) & (comp ~= 32773)
      error('Compression format not supported.');
    end

  % photometric interpretation
  elseif (tag == 262)
    if (strcmp(byte_order','II')) 
      fseek(file,6,0);
      photo_type = fread(file,1,'ushort','l');
    else
      fseek(file,6,0);
      photo_type = fread(file,1,'ushort','b');
    end

  % strip offsets
  elseif (tag == 273)
    if (strcmp(byte_order','II')) 
      type = fread(file,1,'ushort','l');
      count = fread(file,1,'ulong','l');
      if ((type-2)*2*count > 4) 
        % next field contains an offset
        val_offset = fread(file,1,'ulong','l'); 
        fseek(file,val_offset,-1);
        if (type == 3)
          strip_offsets = fread(file,count,'ushort','l');
        else 
          strip_offsets = fread(file,count,'ulong','l');
        end
      else
        % next field contains values 
        if (type == 3)
          strip_offsets = fread(file,count,'ushort','l');
        else 
          strip_offsets = fread(file,count,'ulong','l');
        end
      end
    else
      type = fread(file,1,'ushort','b');
      count = fread(file,1,'ulong','b');
      num_strips = count;
      if ((type-2)*2*count > 4)
        % next field contains an offset
        val_offset = fread(file,1,'ulong','b');
        fseek(file,val_offset,-1); 
        if (type == 3)
          strip_offsets = fread(file,count,'ushort','b');
        else 
          strip_offsets = fread(file,count,'ulong','b');
        end
      else
        % next field contains values 
        if (type == 3)
          strip_offsets = fread(file,count,'ushort','b');
        else 
          strip_offsets = fread(file,count,'ulong','b');
        end
      end
    end

  % rows per strip
  elseif (tag == 278)
    if (strcmp(byte_order','II'))
      type = fread(file,1,'ushort','l');
      fseek(file,4,0);
      if (type == 3)
        rows_per_strip = fread(file,1,'ushort','l');
      else
        rows_per_strip = fread(file,1,'ulong','l');
      end
    else
      type = fread(file,1,'ushort','b');
      fseek(file,4,0);
      if (type == 3)
        rows_per_strip = fread(file,1,'ushort','b');
      else
        rows_per_strip = fread(file,1,'ulong','b');
      end
    end
     
  % strip byte counts - number of bytes in each strip after any compression
  elseif (tag == 279)
    if (strcmp(byte_order','II'))
      type = fread(file,1,'ushort','l');
      count = fread(file,1,'ulong','l');
      if ((type-2)*2*count > 4)
        % next field contains an offset
        val_offset = fread(file,1,'ulong','l');
        fseek(file,val_offset,-1);
        if (type == 3)
          strip_bytes = fread(file,count,'ushort','l');
        else
          strip_bytes = fread(file,count,'ulong','l');
        end
      else
        % next field contains values
        if (type == 3)
          strip_bytes = fread(file,count,'ushort','l');
        else
          strip_bytes = fread(file,count,'ulong','l');
        end
      end
    else
      type = fread(file,1,'ushort','b');
      count = fread(file,1,'ulong','b');
      if ((type-2)*2*count > 4)
        % next field contains an offset
        val_offset = fread(file,1,'ulong','b');
        fseek(file,val_offset,-1);
        if (type == 3)
          strip_bytes = fread(file,count,'ushort','b');
        else
          strip_bytes = fread(file,count,'ulong','b');
        end
      else
        % next field contains values
        if (type == 3)
          strip_bytes = fread(file,count,'ushort','b');
        else
          strip_bytes = fread(file,count,'ulong','b');
        end
      end
    end

  % X resolution
  elseif (tag == 282)
    fseek(file,6,0);
    if (strcmp(byte_order','II'))
      val_offset = fread(file,1,'ulong','l');
      fseek(file,val_offset,-1);
      numerator = fread(file,1,'ulong','l');
      denominator = fread(file,1,'ulong','l');
    else
      val_offset = fread(file,1,'ulong','b');
      fseek(file,val_offset,-1);
      numerator = fread(file,1,'ulong','b');
      denominator = fread(file,1,'ulong','b');
    end
      x_res = numerator / denominator;
   
  % Y resolution          
  elseif (tag == 283)
    fseek(file,6,0);
    if (strcmp(byte_order','II'))
      val_offset = fread(file,1,'ulong','l');
      fseek(file,val_offset,-1);
      numerator = fread(file,1,'ulong','l');
      denominator = fread(file,1,'ulong','l');
    else
      val_offset = fread(file,1,'ulong','b');
      fseek(file,val_offset,-1);
      numerator = fread(file,1,'ulong','b');
      denominator = fread(file,1,'ulong','b');
    end
      y_res = numerator / denominator;

  % resolution unit
  elseif (tag == 296)
    fseek(file,6,0);
    if (strcmp(byte_order','II'))
      res_unit = fread(file,1,'ushort','l');
    else
      res_unit = fread(file,1,'ushort','b');
    end

  % color map
  elseif (tag == 320)
    if (strcmp(byte_order','II'))
      type = fread(file,1,'ushort','l');
      count = fread(file,1,'ulong','l');
      val_offset = fread(file,1,'ulong','l');
      fseek(file,val_offset,-1);
      if (type == 1) 
        c_map = fread(file,count,'uchar','l');
      else
        c_map = fread(file,count,'ushort','l');
      end
    else
      type = fread(file,1,'ushort','b');
      count = fread(file,1,'ulong','b');
      val_offset = fread(file,1,'ulong','b');
      fseek(file,val_offset,-1);
      if (type == 1) 
        c_map = fread(file,count,'uchar','b');
      else
        c_map = fread(file,count,'ushort','b');
      end
    end
    colors = count/3;
     
  end
  % move to next FID entry in the file
  fseek(file,file_pos+12,-1);
end

% compute the width of each row in bytes
width_bytes = ceil(width/(8/bits(1)))*num_samples;

% read the strips, decompress them, and place them in a matrix
for i = 1:num_strips
  fseek(file,strip_offsets(i),-1);
  if (strcmp(byte_order','II'))
    strip = fread(file,strip_bytes(i),'schar','l');
  else
    strip = fread(file,strip_bytes(i),'schar','b');
  end
  if length(strip)~=strip_bytes(i), 
    error('End of file reached unexpectedly.');
  end
%
  % decompress strip if necessary
  if (comp == 32773)
    draw = [draw;untiff(strip,width_bytes,strip_bytes(i))];
  else
    % don't need to decompress
    count = 0;
    draw = [draw,reshape(strip,width_bytes,(strip_bytes(i)/width_bytes))];
  end
end
if comp == 1, draw = draw'; end

% turn signed bytes into unsigned bytes
a = find(draw < 0);
draw(a) = draw(a) + 256;

% if data is stored with 4 bits per pixel then
% matrix needs to be expanded so that each element has only
% one pixel
if bits(1) == 4
  high = floor(draw/16);
  low = floor(draw - high*16);
  draw(:,1:2:width_bytes*2) = high;
  draw(:,2:2:width_bytes*2) = low;
end

% if the image is bilevel (black and white) then matrix
% needs to be expanded so that each element has only one pixel
if bits(1) == 1
  b7 = floor(draw/128);
  b6 = floor((draw-b7*128)/64);
  b5 = floor((draw-b7*128-b6*64)/32);
  b4 = floor((draw-b7*128-b6*64-b5*32)/16);
  b3 = floor((draw-b7*128-b6*64-b5*32-b4*16)/8);
  b2 = floor((draw-b7*128-b6*64-b5*32-b4*16-b3*8)/4);
  b1 = floor((draw-b7*128-b6*64-b5*32-b4*16-b3*8-b2*4)/2);
  b0 = draw-b7*128-b6*64-b5*32-b4*16-b3*8-b2*4-b1*2;
  draw(:,1:8:width_bytes*8) = b7;
  draw(:,2:8:width_bytes*8) = b6;
  draw(:,3:8:width_bytes*8) = b5;
  draw(:,4:8:width_bytes*8) = b4;
  draw(:,5:8:width_bytes*8) = b3;
  draw(:,6:8:width_bytes*8) = b2;
  draw(:,7:8:width_bytes*8) = b1;
  draw(:,8:8:width_bytes*8) = b0;
end

if (num_samples == 3) % If this is an RGB image
  % rgb color
  r = draw(:,1:3:width*3)/255;
  g = draw(:,2:3:width*3)/255;
  b = draw(:,3:3:width*3)/255;

  if (nargout == 2) % Convert to an indexed image if user requests it.
    [r,g] = rgb2ind(r,g,b,.2);
  end
else
  if isempty(c_map), % This is a gray scale image
    if bits(1) == 8
      gct = gray(256);
      if photo_type == 0
        draw = 255 - draw;
      end
    elseif bits(1) == 4
      gct = gray(16);
      if photo_type == 0
        draw = 15 - draw;
      end
    elseif bits(1) == 1
      gct = gray(2);
      if photo_type == 0
        draw = 1 - draw;
      end
    end
    % adjust matrix so that color indexes begin with 1 instead of 0
    draw = draw + 1;
  else % This is a color image
    gct = reshape(c_map,colors,3);
    gct = gct / 65535;
    draw = draw + 1;
  end

  % adjust colormap to min and max of image
  min_val = min(min(draw));
  max_val = max(max(draw));
  gct = gct(1:max_val,:);

  % Extract valid part of data
  if ~all(size(draw)==[height width]),
    draw = draw(1:height,1:width);
  end
  if nargout==3, % Convert to RGB image if user requests it.
    [r,g,b] = ind2rgb(draw,gct);
  else
    r = draw;
    g = gct;
  end
end
fclose(file);
