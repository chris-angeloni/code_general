%function []=float2wav4ch(infile,outfile,Fs,L,N,M,MACHINE,SOX)
%
%	FILE NAME	: FLOAT 2 WAV 4 CH
%       DESCRIPTION     : Converts a binary 'float' file to a 4 channel wav
%			  File with the following properties:
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%			  ch3:  Trigger
%			  ch4:  Trigger
%
%   infile  : Input file name
%	outfile : Output file name 
%	Fs		: Sampling Rate (Default=44100)
%	L		: Number of Blocks in Between Double Triggers
%			  (Default=400)
%	N		: Inter Trigger Time	(Default=32000)
%	M		: Segment Length	(Default=128k)
%   MACHINE : Machine Float Format, See FREAD for MACHINEFORMAT types
%           : Default: 'n', Native
%   SOX     : Pipe SW file to SOX : 'y' or 'n' (Default='n')
%
% Requires SOX, Sound Exchange: http://sox.sourceforge.net/
%
% (C) Monty A. Escabi, Dec 2005 (Edit May 2007)
%
function []=float2wav4ch(infile,outfile,Fs,L,N,M,MACHINE,SOX)

%Input Arguments
if nargin<3
	Fs=44100;
	L=400;
    N=32000;
    M=1024*128;
    MACHINE='n';
    SOX='n';
elseif nargin<4
	L=400;
	N=32000;
	M=1024*128;
    MACHINE='n';
    SOX='n';
elseif nargin<5
	N=32000;
	M=1024*128;
    MACHINE='n';
    SOX='n';
elseif nargin<6
	M=1024*128;
    MACHINE='n';
    SOX='n';
elseif nargin<7
    MACHINE='n';
    SOX='n';
elseif nargin<8
    SOX='n';
end

%Checking for Command Line Arguments
if ispc
    Delete='del';
    Copy='copy';
else
    Delete='rm';
    Copy='cp';
end

%Finding File Names
index=findstr('.',outfile);
file1=[outfile(1:index-1) '.int'];
file2=[outfile(1:index-1) '2.int'];
file3='trig1.int';
file4='trig2.int';
file5=[outfile(1:index-1) '.sw'];

%Converting Sound to int16 and Flipping from Left to Right
float2int(infile,file1,M,MACHINE);
flipfile(file1,file2,'int16',M);

%Finding the Input File length
FileL=0;
fid=fopen(infile);
while ~feof(fid)
	X=fread(fid,1024*128,'float',0,MACHINE);
	FileL=length(X)+FileL;
end
fclose(fid);

%Generating Trigger Files
trigfile(file3,N,L,FileL);
f=['!' Copy ' ' file3 ' ' file4];
eval(f)

%Interlacing all 4 channels
interlace4(file1,file2,file3,file4,file5,M);

%Removing Files
f=['!' Delete ' ' file1 ' ' file2 ' ' file3 ' ' file4];
eval(f);

if SOX=='y'
    %Converting to WAV File
    f=['!sox -r ' num2str(Fs) ' -c 4 ' file5 ' ' outfile];
    eval(f);

    %Removing SW File
    f=['!' Delete ' ' file5];
    eval(f);
end

%Closing All Files
fclose('all')