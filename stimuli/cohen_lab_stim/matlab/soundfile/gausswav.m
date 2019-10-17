%function []=gausswav(outfile,Fs,Tdur,Trig,M)
%
%       FILE NAME       : GAUSS WAV
%       DESCRIPTION     : Generates a Gaussian White Noise .WAV file
%
%	outfile		: Output file name (No Extension)
%	Fs		: Sampling frequency
%	Tdur		: Sound duration in (sec) 
%Optional
%	Trig		: Add second channel as Tirgger: 'y' or 'n'
%			  ( Default == 'n' )
%	M		: Segment length ( Default=1024*128 )
%
function []=gausswav(outfile,Fs,Tdur,Trig,M)

%Preliminaries 
if nargin < 4
	Trig='n';
	M=1024*128;
elseif nargin<5
	M=1024*128;
end
M=2^nextpow2(M);		%Make sure M is dyadic

%Opening File 
L=findstr(outfile,'wav');
if ~isempty(L)
	rawoutfile=outfile(1:L-2);
else
	rawoutfile=outfile;
end
fidraw=fopen([rawoutfile '.raw'],'wb');

%Number of Segments for required length
N=ceil(Tdur*Fs/M);		%Number of M segments

%Trigger Parameters
NTrig=2^(nextpow2(Fs)-1);	%Number of Samples Between Triggers
LTrig=NTrig/16;			%Trigger Length ~ 1/16 sec

%Generating Sound and Trigger and Writing to RAW File
MaxX=-9999;
for k=1:N

	X=randn(1,M);
	if Trig=='y'
		Trigger=zeros(1,M);		 
		for j=1:M/NTrig
			Trigger((j-1)*NTrig+1:(j-1)*NTrig+LTrig)=ones(1,LTrig)*1024*31;
		end
		Y=zeros(1,2*M);
		Y(1:2:2*M)=X;
		Y(2:2:2*M)=Trigger;
	else
		Y=X;
	end
	fwrite(fidraw,Y,'float32');
	MaxX=max(max(abs(X)),MaxX);
end

%Closing Outfile and Opening SW Outfile
fclose(fidraw);
fidraw=fopen([rawoutfile '.raw'],'r');
fidsw=fopen([rawoutfile '.sw'],'w');

%Normalyzing and Writing to SW
for k=1:N
	X=fread(fidraw,2*M,'float32');
	X(1:2:2*M)=round(1024*32*.95*X(1:2:2*M)/MaxX);
	X(2:2:2*M)=round(X(2:2:2*M));
	fwrite(fidsw,X,'int16');
end

%Removing RAW File
f=['!rm ' rawoutfile '.raw' ];
eval(f)

%Saving to 'wav'
if Trig=='y'
	f=['!sox -r ' int2str(Fs) ' -c 2  ' rawoutfile '.sw ' rawoutfile '.wav'];

else
	f=['!sox -r ' int2str(Fs) ' -c 1 ' rawoutfile '.sw ' rawoutfile '.wav'];
end
eval(f)
disp(['Performing: ' f]);

%Removing SW File
f=['!rm ' rawoutfile '.sw' ];
eval(f)
