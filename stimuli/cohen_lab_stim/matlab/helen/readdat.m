%
%function  [Data]=readdat(filename)
%
%DESCRIPTION: Reads DAT file and returns data as a data structure
%
%   filename    : Input file name
%
%Monty A. Escabi, Helen Sabolek Feb. 2004
%
function  [Data]=readdat(filename)

%Opening input file
fid=fopen(filename,'r');

%Reading Junk Header
Junk=fread(fid,1024*8,'int16');
Header=fread(fid,10,'int16');
Data.Fs=Header(1);

%Reading file Data
Data.X=[];
while ~feof(fid)

    Data.X=[Data.X fread(fid,Header(9),'int16')'];
    Header=fread(fid,2,'int16');

end