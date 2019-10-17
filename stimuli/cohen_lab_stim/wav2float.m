%function []=wav2float(infile,outfile,M,iftype)
%
%   FILE NAME       : WAV 2 FLOAT
%   DESCRIPTION     : Converts a 'wav' sound file to binary 'float'
%
%   infile		: Input file name
%	outfile		: Output file name
%	M		: Segment Length
%   iftype  : Infile type (Default='int16')
%
function []=wav2float(infile,outfile,M,iftype)

%Input Arguments
if nargin<4
    iftype='int16';
end

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Converting to 'float'
fseek(fidin,44,-1);
while ~feof(fidin)
	X=fread(fidin,M,iftype);
	fwrite(fidout,X,'float');
end

%Closing Files
fclose(fidin);
fclose(fidout);