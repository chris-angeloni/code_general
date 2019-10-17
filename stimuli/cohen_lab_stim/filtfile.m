%
%function [] = filtfile(infile,outfile,f1,f2,TW,ATT,Fs,M,FiltGain,ftype,H)
%
%	FILE NAME 	: FILTFILE
%	DESCRIPTION : Filters the data in 'filename' and saves results to
%                 'outfile'. Uses overlap save method to assure that there
%                 are no edge artifacts.
%
%	infile		: Input data file
%	outfile		: Output data file
%	f1          : Lower Cutoff Freqeuncy (Hz)
%	f2          : Upper Cutoff Frequency (Hz)
%	TW          : Tranzition width (Hz)
%	ATT         : Filter Attenuation
%	Fs          : Sampling Rate
%	M           : Block size ( Default=1024*128)
%	FiltGain	: Filter Gain ( Default=1) 
%	ftype		: File Type: 'int16' or 'float'
%                 Default: 'int16'
%   H           : Impulse response vector of the filter that will be 
%                 applied to the input data. All other filter parameters 
%                 are ignored (f1,f2,TW, ATT, FiltGain).
%
% (C) Monty A. Escabi, Edit Jan 2016
%
function [] = filtfile(infile,outfile,f1,f2,TW,ATT,Fs,M,FiltGain,ftype,H)

%Input Arguments
if nargin<8
	M=1024*128;
end
if nargin<9
	FiltGain=1;
end
if nargin<10
	ftype='int16';
end

%Designing Filter
if nargin<11
    if f1==0
        H=lowpass(f2,TW,Fs,ATT,'off');
    else
        H=bandpass(f1,f2,TW,Fs,ATT,'off');
    end
    H=H*FiltGain;
end
N=floor(length(H)/2);

%Opening File
fidin=fopen(infile);
fidout=fopen(outfile,'w');

%Reading and Filtering File
count=0;
while ~feof(fidin)
	if count==0
		X=fread(fidin,M+N,ftype);
		Y=conv(H,X);
		Y=Y(N+1:M+N);
	else
		if strcmp(ftype,'int16') 
			fseek(fidin,2*(count*M-N+1),-1);
		else
			fseek(fidin,4*(count*M-N+1),-1);
		end
		X=fread(fidin,M+2*N,ftype);
		Y=conv(H,X);
		if length(Y)==M+4*N
			Y=Y(2*N:M+2*N-1);
		else
			M=length(X)-N;
			Y=Y(2*N:M+2*N);
		end
	end
	if strcmp(ftype,'int16') 
		fwrite(fidout,round(Y),ftype);
	else
		fwrite(fidout,Y,ftype);
	end

	count=count+1;
end

%Closing Files
fclose('all');
