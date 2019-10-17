%
%function []=wavvolume(infile,outfile,ATT,M)
%
%       FILE NAME       : WAV VOLUME
%       DESCRIPTION     : Changes the intensity of a wavfile
%
%       infile	        : Input File
%	outfile		: Output File
%	ATT		: Attenuation in dB
%	M		: Buffer Length - Optional (1024*512 Default)
%
function []=wavvolume(infile,outfile,ATT,M)

%Checking Input Arguments
if nargin<5
        M=1024*512;
end

%Opening Infile
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');

X=fread(fidin,22,'int16');
fwrite(fidout,X,'int16');
%Attenuating File
while ~feof(fidin)
	X=fread(fidin,M,'int16');
	X=round(X*10.^(-ATT/20));
	fwrite(fidout,X,'int16');
end

%Closing Files
fclose('all');
