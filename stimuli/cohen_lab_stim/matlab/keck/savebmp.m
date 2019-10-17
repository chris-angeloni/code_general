function savebmp(bmpfile,X,map)
% SAVEBMP  Save Microsoft Windows 3.x .BMP format image files.
%
%          SAVEBMP(bmpfile,X,map) saves a .BMP format file specified by
%          "bmpfile". The .BMP extension in the filename is optional.
%
%          The input arguments for SAVEBMP are as follows:
%
%          bmpfile   A string containing the name of the .BMP file to create
%          X         The image data to save (8 bit max)
%          map       The colormap of the image
%
%          Note: SAVEBMP currently supports only uncompressed .BMP files
%                with at most 256 colors.
%
%          See also LOADBMP.

%          Copyright (c) 1993 by
%          
%          Ralph Sucher
%          Dept. of Communications Engineering
%          Technical University of Vienna
%          Gusshausstrasse 25/389
%          A-1040 Vienna
%          AUSTRIA
%          
%          Phone: +431-58801/3518
%          Fax:   +431-5870583
%          Email: rsucher@email.tuwien.ac.at

if nargin~=3
   error('Wrong number of input arguments! Type HELP SAVEBMP for info.');
end

if findstr(bmpfile,'.')==[]
   bmpfile=[bmpfile,'.bmp'];
end

fid=fopen(bmpfile,'rb');
if fid~=-1
   fclose(fid);
   error('File already exists! Please choose another filename.');
end

[nCol,rgb]=size(map);
if nCol>256
   error('SAVEBMP supports only images with at most 256 colors.');
end
if rgb~=3
   error('The colormap must have 3 columns: [R,G,B].');
end
if min(map(:))<0 | max(map(:))>1
   error('The colormap must have values in [0,1].');
end

% determine number of bits per pixel
if nCol<=2
   biBitCnt=1;
elseif nCol<=16
   biBitCnt=4;
else
   biBitCnt=8;
end

% truncate image data
X=round(X);
xmin=find(X<1);
xmax=find(X>nCol);
X(xmin)=ones(1,length(xmin));
X(xmax)=nCol*ones(1,length(xmax));

% determine image size
[biHeight,biWidth]=size(X);
Width=ceil(biWidth*biBitCnt/32)*32/biBitCnt;
ndata=Width*biHeight*biBitCnt/8;
X=[X(biHeight:-1:1,:)-1 zeros(biHeight,Width-biWidth)]';
Xsize=Width*biHeight;

fid=fopen(bmpfile,'wb');

% ------------------------------- BMP HEADER -------------------------------

% write file identifier
fwrite(fid,'BM','uchar');

% write file length (bytes)
bfSize=54+4*nCol+ndata;
fwrite(fid,bfSize,'long');

% set bytes reserved for later extensions to zero
fwrite(fid,0,'long');

% write offset from beginning of file to first data byte
bfOffs=54+4*nCol;
fwrite(fid,bfOffs,'long');

% ----------------------------- BMP INFO-BLOCK -----------------------------

% *** bitmap information header ***

% write length of bitmap information header
fwrite(fid,40,'long');

% write width of bitmap
fwrite(fid,biWidth,'long');

% write height of bitmap
fwrite(fid,biHeight,'long');

% write number of color planes
fwrite(fid,1,'ushort');

% write number of bits per pixel
fwrite(fid,biBitCnt,'ushort');

% write type of data compression
fwrite(fid,0,'long');

% write size of compressed image
fwrite(fid,0,'long');

% write horizontal resolution
fwrite(fid,0,'long');

% write vertical resolution
fwrite(fid,0,'long');

% write number of used colors
fwrite(fid,0,'long');

% write number of important colors
fwrite(fid,0,'long');

% *** colormap ***

map=[fix(255*map(:,3:-1:1)) zeros(nCol,1)]';
fwrite(fid,map,'uchar');

% ------------------------------ BITMAP DATA -------------------------------

if biBitCnt==1
   x=zeros(1,ndata);
   for i=1:8
       x=x+2^(8-i)*X(i:8:Xsize);
   end
   fwrite(fid,x,'uchar');
elseif biBitCnt==4
   x=16*X(1:2:Xsize)+X(2:2:Xsize);
   fwrite(fid,x,'uchar');
else
   fwrite(fid,X,'uchar');
end

fclose(fid);
