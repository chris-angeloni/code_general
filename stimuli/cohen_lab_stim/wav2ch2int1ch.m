%function []=wav2ch2int1ch(infile,outfile,channel,M)
%
%       FILE NAME       : WAV 2 CH 2 INT 1 CH
%       DESCRIPTION     : Converts a 2 channel 'wav' sound file to
%			  single channel binary 'int16'
%
%       infile		: Input file name
%	outfile		: Output file name
%	channel		: Channel To extract: 1 or 2
%	M		: Segment Length
%
function []=wav2ch2int1ch(infile,outfile,channel,M)

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Converting to 'int16'
fseek(fidin,44,-1);
while ~feof(fidin)
	X=fread(fidin,M,'int16');
	if channel==1
		fwrite(fidout,X(1:2:length(X)),'int16');
	else
		fwrite(fidout,X(2:2:length(X)),'int16');
	end
end

%Closing Files
fclose(fidin);
fclose(fidout);
