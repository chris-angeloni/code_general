%
%function [] = compress(infile,outfile,f2,DF,TW,ATT,Fs,M,alpha)
%
%	FILE NAME 	: COMPRESS 
%	DESCRIPTION 	: Compresses the dynamic range of the spectro-temporal
%			  envelope of a WAV sound
%
%	infile		: Input data file
%	outfile		: Output data file
%	f2		: Upper Cutoff Frequency (Hz)
%	DF		: Frequency Resolution
%	TW		: Tranzition width (Hz)
%	ATT		: Filter Attenuation
%	Fs		: Sampling Rate
%	M		: Block size ( Default=1024*128 )
%	alpha		: Compression Factor
%			  Reduces the dynamic range in the modulation 
%			  envelope by a factor of alpha where 
%			  alpha E [0 1]
%
function [] = compress(infile,outfile,f2,DF,TW,ATT,Fs,M,alpha)

%Number of Bands to Filter
L=floor(f2/DF);

%Pre-Whitening Data File
fid=fopen(infile);
X=fread(fid,inf,'int16');
fclose(fid);
[Y,PP]=prewhiten(X,44100,100,f2,DF,3);
infilepre=[infile '.Pre'];
fid=fopen(infilepre,'w');
fwrite(fid,round(Y),'int16');
max(round(Y))

%Filtering File into Sub-Bands and Computing Hilbert Transform
Max=0;
for k=1:L
	%Displaying Output
	clc
	disp(['Filtering and Computing Hilbert Transform: Band ',...
		int2str(k) ' of ' int2str(L)])	

	%Filtering File
	filtfile(infilepre,'/tmp/tempfilt.sw',(k-1)*DF,k*DF,TW,ATT,Fs,1024*128,.75)

	%Loading Filtered File Data 
	fid=fopen('/tmp/tempfilt.sw');
	Y=fread(fid,inf,'int16');
	!rm /tmp/tempfilt.sw

	%Computing Hilbert Transform
	Z=hilbert(Y);	

	%Saving Temporary Data
	f=['save  /tmp/temp_b' int2str(k) ' Z'];
	eval(f);
	clear Y Z 

end

%Loading Sub-Bands and Reconstructing Sound
load /tmp/temp_b1.mat
X=zeros(1,length(Z));
for k=1:L
	%Displaying Output
	clc
	disp(['Reconstructing Sound: Band ' int2str(k) ' of ' int2str(L)])

	%Loading Temporary Block
	f=['load  /tmp/temp_b' int2str(k)];
	eval(f);

	%Removing Temporary Block
%	f=['!rm /tmp/temp_b' int2str(k) '.mat'];
%	eval(f);

	%Reconstructing Sound
	alpha=.5;
	X=X+Z./abs(Z).*10.^(log10(abs(Z)/Max)*alpha);

end

%Saving Data To Outfile
fidout=fopen(outfile);
fwrite(fidout,X,'int16');
fclose(fidout);
