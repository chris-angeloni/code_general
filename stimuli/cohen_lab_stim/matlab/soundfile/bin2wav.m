%
%function []=bin2wav(filename,Y,Fs)
%	
%	FILE NAME 	: BIN2WAV
%	DESCRIPTION 	: Converts an array Y to a Binary File
%			  and then uses sox program to convert to 
%			  WAV
%
%	filename	: File
%       Y		: Sound Signal
%	Fs		: Sampling Rate
%
function []=bin2wav(filename,Y,Fs)

%Normalizing
Y=( norm1d(Y) -.5 ) * 2 *.95 * 32768;

%Opening Output Files
fnum=fopen([filename '.sw'], 'a');

%Saving Output File 
outdata=zeros(1,2*length(Y));
outdata(1:2:length(Y)*2)=Y;
fwrite(fnum,outdata,'short');

%Closing Output File
fclose(fnum);

%Convert binary file to WAV file
f=['converting ',filename,'.sw to ',filename,'.wav'];
disp(f);
cmdline = sprintf('sox -r %d -c 2 %s.sw %s.wav',Fs, filename, filename);
unix(cmdline); 
