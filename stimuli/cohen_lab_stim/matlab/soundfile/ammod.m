%function []=ammod(infile,outfile,fam,gamma,modtype,Fs,M,type)
%
%       FILE NAME       : AM MOD
%       DESCRIPTION     : Adds AM noise modulations to infile and stores to 
%			  outfile
%
%       infile		: Input file name
%	outfile		: Output file name 
%       fam		: Maximum modulation frequency
%	gamma		: Modulation Index : decibels
%	modtype		: Type of modulation : Lin or dB
%	Fs		: Sampling frequency 
%Optional
%	M		: Segment length ( Default=1024*128 )
%	type		: File Type : 'float' or 'int16' ( Default='float' )
%
function []=ammod(infile,outfile,fam,gamma,modtype,Fs,M,type)

%Preliminaries
if nargin<7
	M=1024*128;
end
if nargin<8
	type='float';
end

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'a');

%Adding AM Modulations
k=1;
while ~feof(fidin)

	%Generating Modulation Signal
	AM=noiseunif(fam,Fs,M);
	index=find(AM(1:length(AM)-1)>.5 & AM(2:length(AM))<.5);
	AM=AM(index(1):index(length(index)));
	if strcmp(modtype,'Lin')
		gamma=1-10.^(-gamma/20);
		AM=gamma*AM + 1-gamma;
	else
		AM=gamma*(AM-1);
		AM=10.^(AM/20);
	end

	%Adding Modulations and saving to File
	X=fread(fidin,length(AM),type);
	N=min(length(AM),length(X));
	fwrite(fidout,X(1:N)'.*AM(1:N),type);
	clc;
	disp(['Saving Block ' num2str(k)]);
	k=k+1;
end

%Closing Files
fclose(fidin);
fclose(fidout);

