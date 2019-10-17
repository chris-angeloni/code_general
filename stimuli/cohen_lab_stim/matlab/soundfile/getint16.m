%function []=getint16(infile,outfile,nchannel,dchannel,M)
%
%       FILE NAME       : GET INT16
%       DESCRIPTION     : Extracts a single channel from 'int16' file
%
%       infile		: Input file name
%	outfile		: Output file name 
%	nchannel	: Number of Data Channels
%	dchannel	: Data channel to extract
%	M		: Segment Length (Optional)
%
function []=getint16(infile,outfile,nchannel,dchannel,M)

%Default Segment Length
if nargin==4
	M=1024*128;
end

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'wb');

%Converting to 'int16'
fseek(fidin,0,-1);
while ~feof(fidin)
	X=fread(fidin,M,'int16');
	fwrite(fidout,X(dchannel:nchannel:length(X)),'int16');
end

%Closing Files
fclose('all');

