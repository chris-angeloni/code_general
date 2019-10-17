%
%function [] = compress(infile,outfile,f2,DF,TW,ATT,M,alpha)
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
%	M		: Block size ( Default=1024*128 )
%	alpha		: Compression Factor
%			  Reduces the dynamic range in the modulation 
%			  envelope by a factor of alpha where 
%			  alpha E [0 1]
%
function [] = compress(infile,outfile,f2,DF,TW,ATT,M,alpha)

%Number of Bands to Filter
L=floor(f2/DF);

%Filtering File into Sub-Bands and Computing Hilbert Transform
Max=0;
for k=1:L
	%Displaying Output
	clc
	disp(['Filtering and Computing Hilbert Transform: Band ',...
		int2str(k) ' of ' int2str(L)])	

	%Loading Wav File
	[X,Fs,Format]=wreadn2m(infile,0,inf);

	%Filtering Data into Sub-Bands
	H=bandpass((k-1)*DF,k*DF,TW,Fs,ATT,'off');
	Y=convfft(X,H,(length(H)-1)/2);
	Y=Y(1:length(X));
	clear X

	%Computing Hilbert Transform
	Z=hilbert(Y);
	Max=max([Max abs(Z)]);
%	Max=max([Max abs(Y)]);

	%Saving Temporary Data
%	f=['save  /tmp/temp_b' int2str(k) ' Y'];
	f=['save  temp_b' int2str(k) ' Z'];
	eval(f);
	clear Y Z 

end

%Loading Sub-Bands and Reconstructing Sound
load temp_b1.mat
X=zeros(1,length(Z));
for k=1:L
	%Displaying Output
	clc
	disp(['Reconstructing Sound: Band ' int2str(k) ' of ' int2str(L)])

	%Loading Temporary Block
	f=['load  temp_b' int2str(k)];
	eval(f);

	%Removing Temporary Block
	f=['!rm temp_b' int2str(k) '.mat'];
	eval(f);

%	%Reconstructing Sound
%	index1=find(Y>0);
%	index2=find(Y<0);

%X(index1)=X(index1)+10.^(log10(Y(index1)/Max)*alpha);
%X(index2)=X(index2)-10.^(log10(-Y(index2)/Max)*alpha);
	X=X+Z./abs(Z).*10.^(log10(abs(Z)/Max)*alpha);
%plot(X)
%hold on
%plot(Y/Max,'r')
%pause
end


%Loawpass Filtering To Remove High Frequency Noise
H=bandpass(0,f2,TW,Fs,ATT,'off');
Y=convfft(X,H,(length(H)-1)/2);
X=Y(1:length(X));
clear Y

save montysound X
