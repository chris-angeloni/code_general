%
%function []=float2wav2ch(infile,outfile,Fs,M)
%
%	FILE NAME	: FLOAT 2 WAV 2 CH
%       DESCRIPTION     : Converts a binary 'float' file to a 2 channel wav
%			  File with the following properties:
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%
%       infile		: Input file name
%	outfile		: Output file name 
%	Fs		: Sampling Rate (Default=44100)
%	M		: Segment Length (Default=128k)
%
function []=float2wav2ch(infile,outfile,Fs,M)

%Input Arguments
if nargin<3
	Fs=44100;
        M=1024*128;
elseif nargin<4
	M=1024*128;
end

%Finding File Names
index=findstr('.',outfile);
file1=[outfile(1:index-1) '.int'];
file2=[outfile(1:index-1) '2.int'];
file3=[outfile(1:index-1) '.sw'];

%Converting Sound to int16 and Flipping from Left to Right
float2int(infile,file1,M);
flipfile(file1,file2,'int16',M);

%Interlacing all 4 channels
interlace(file1,file2,file3,M);

%Removing Files
f=['!rm ' file1 ' ' file2  ];
eval(f);

%Converting to WAV File
f=['!/usr/local/bin/sox -r ' num2str(Fs) ' -c 2 ' file3 ' ' outfile];
eval(f);

%Removing SW File
f=['!rm ' file3];
eval(f);

