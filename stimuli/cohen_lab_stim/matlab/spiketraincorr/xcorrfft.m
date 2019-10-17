%
%function [F] = xcorrfft(X,Y,N)
%
%	FILE NAME 	: XCORRFFT
%	DESCRIPTION : Discrete Cross Correlation performed by using FFT
%
%	X,Y         : Input Signals
%
%OPTIONAL
%	N		: Maximum Lag
%
%(C) Monty A. Escabi, Edit June 2009
%
function [F] = xcorrfft(X,Y,N)

%Array Lengths
Nx=length(X);
Ny=length(Y);

if ~exist('/usr/local/bin/xcorrfl')	%Matlab Based Routine

	%Rearanging X
	S=size(Y);
	if S(1)>S(2)
		Y=flipud(Y);
	else
		Y=fliplr(Y);
	end

	%XCorrelating 
	M=2.^nextpow2(Nx+Ny-1);
	F=convfft(X,Y,0,M);
	if nargin<3
		F=F(1:Nx+Ny-1);
    else
        Nc=(Nx+Ny)/2;   %Fixed the center point of the correlation, now OK for unequal size vectors June 2009
		F=F(Nc-N:Nc+N);
	end

else	%C Based Routine%

	%Opening Temporary Files
	file1=['/tmp/xcorr' int2str(round(1024*1024*rand)) '.bin'];
	file2=['/tmp/xcorr' int2str(round(1024*1024*rand)) '.bin'];
	outfile=['/tmp/xcorr' int2str(round(1024*1024*rand)) '.bin'];
	fid1=fopen(file1,'wb');
	fid2=fopen(file2,'wb');

	%Zero Padding
	M=2^nextpow2(max(Nx,Ny)*2+1);
	if Nx>=Ny
		X=[ zeros(1,M-Nx) X];
		Y=[ Y zeros(1,M-Ny) ];
	else
		Y=[ zeros(1,M-Ny) Y];
		X=[ X zeros(1,M-Nx) ];
	end

	%Writing Data Files
	fwrite(fid1,X,'float');
	fwrite(fid2,Y,'float');

	%Performing Xcorrelation
	f=['!xcorrfl ' file1 ' ' file2 ' ' outfile ' ' int2str(M) ];
	eval(f);

	%Extracting Data
	fid3=fopen(outfile);
	F=fread(fid3,inf,'float')';
	F=F(1:M);
	if Nx>=Ny
		F=fliplr(F);
		F=F(1:2*Nx-1);
		if nargin==3
			F=F(Nx-N:Nx+N);
		end
	elseif Ny>Nx
		F=fliplr(F(2:2*Ny));
		if nargin==3
			F=F(Ny-N:Ny+N);
		end
	end
	
	%Removing Temporary Files
	f=['!rm ' file1 ' ' file2 ' ' outfile ];
	eval(f);
 
end

%Closing Opened Files
fclose all;
