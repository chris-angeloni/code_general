%function []=float2wavpre(infile,outfile,L,NCopy,Fs,N,M)
%
%	FILE NAME	: FLOAT 2 WAV PRE
%       DESCRIPTION     : Converts a binary 'float' file to a 4 channel wav
%			  Prediction File with the following properties:
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%			  ch3:  Trigger
%			  ch4:  Trigger
%
%       infile		: Input file name
%	outfile		: Output file name 
%	L 		: Number of Sound Blocks (32000 Segments)
%	NCopy		: Number of Copies for PSTH (Default=150)
%	Fs		: Sampling Rate (Default=44100)
%	N		: Inter Trigger Time 	(Default=32000)
%			  Block Size
%	M		: Segment Length	(Default=128k)
%
function []=float2wavpre(infile,outfile,L,NCopy,Fs,N,M)

%Input Arguments
if nargin<4
	NCopy=150;
	Fs=44100;
        N=32000;
        M=1024*128;
elseif nargin<5
	Fs=44100;
        N=32000;
        M=1024*128;
elseif nargin<6
	N=32000;
	M=1024*128;
elseif nargin<7
	M=1024*128
end

%Finding File Names
index=findstr('.',outfile);
file1=[outfile(1:index-1) '.int'];
file2=[outfile(1:index-1) '1.int'];
file3='trig1.int';
file4='trig2.int';
file5=[outfile(1:index-1) '.sw'];
file6=[outfile(1:index-1) '2.sw'];

%Converting Sound to int16 and Flipping from Left to Right
fid=fopen(infile);
fidout=fopen(file1,'w');
X=fread(fid,N*L,'float');
fwrite(fidout,round((norm1d(X)-.5)*2*1024*32*.9),'int16');
fclose('all');
flipfile(file1,file2,'int16',M);

%Finding the Input File length
FileL=N*L;

%Generating Trigger Files
trigfile(file3,N,1E6,FileL);
f=['!cp ' file3 ' ' file4];
eval(f);

%Appending a Blank one second segment to all Files
%fid1=fopen(file1,'a');
%fwrite(fid1,zeros(1,Fs),'int16');
%fid2=fopen(file2,'a');
%fwrite(fid2,zeros(1,Fs),'int16');
%fid3=fopen(file3,'a');
%fwrite(fid3,zeros(1,Fs),'int16');
%fid4=fopen(file4,'a');
%fwrite(fid4,zeros(1,Fs),'int16');
%fclose('all');

%Interlacing all 4 channels
interlace4(file1,file2,file3,file4,file5,M);

%Coppying NCopy Times
appendfile(file5,file6,NCopy,'int16',M);

%Removing Files
f=['!rm ' file1 ' ' file2 ' ' file3 ' ' file4 ' ' file5];
eval(f);

%Converting to WAV File
f=['!sox -r ' num2str(Fs) ' -c 4 ' file6 ' ' outfile];
eval(f);

%Removing SW File
f=['!rm ' file6];
eval(f);

