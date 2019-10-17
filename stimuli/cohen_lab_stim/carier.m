%
%function []=carier(outfile,fc,Fs,L,M)
%
%       FILE NAME       : CARIER
%       DESCRIPTION     : Creates a sinusoidal carier and saves to outfile
%
%	outfile		: Output File
%       fc              : Carier Frequency
%       Fs              : Sampling Frequency
%	L		: Number of Samples
%Optional
%       M               : Block Size ( Default = 512*1024 ) 
%
function []=carier(outfile,fc,Fs,L,M)

%Preliminaries
if nargin==4
	M=1024*512;
end
 
%Opening Output File
fid=fopen(outfile,'w');

%Generating Carier and saving to outfile
N=floor(L/M);
phase=2*pi*rand;
for n=0:N-1
	disp(['Writing Block' num2str(n+1)])
	fwrite(fid,round(1024*32*0.95*sin(2*pi*fc/Fs*(n*M+(1:M))+phase)),'int16');
end
fwrite(fid,round(1024*32*0.95*sin(2*pi*fc/Fs*(N*M+(1:L-M*N))+phase)),'int16');

%Closing File
fclose(fid);
