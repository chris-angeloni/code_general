%function []=wav2int(infile,outfile,M)
%
%       FILE NAME       : WAV 2 INT
%       DESCRIPTION     : Converts a 'wav' sound file to binary 'int16'
%
%       infile		: Input file name
%	outfile		: Output file name
%	M		: Segment Length
%
function []=wav2int(infile,outfile,M)

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Converting to 'int16'
fseek(fidin,44,-1);
while ~feof(fidin)
	X=fread(fidin,M,'int16');
	fwrite(fidout,X,'int16');
end

%Closing Files
fclose(fidin);
fclose(fidout);
