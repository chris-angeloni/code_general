%
%function [TrigTimes]=trigfind(infile,Fs,M,Tresh,ftype)
%
%   FILE NAME   : TRIG FIND
%   DESCRIPTION : Find triggers from a DAT tape file
%
%	infile		: filename 
%	Fs          : Sampling Rate
%	M           : Block Size
%                 Default: M==1024*256
%                 M must be Dyadic and < = 1024*1024
%	Tresh       : Threshhold : Normalized [.5 , 1]
%                 Default: Tresh==.75
%	TrigTimes	: Returned Trigger Time Vector (in sample number)
%
%       Note: For Trigger files that are broken up into blocks of size B
%             trigfind assumes that B is an integer multiple of M so that
%             when reading data an integer multiple of segments are read 
%             before reaching the end of the ith block proceeding to the
%             next block
%
%   ftype       : File type, Default=='int16'
%   
% (C) Monty A. Escabi, Edit June 2009
%
function [TrigTimes]=trigfind(infile,Fs,M,Tresh,ftype)

%Checking Inputs
if nargin<3
	M=1024*256;
end
if nargin<4
	Tresh=.75;  
end 
if nargin<5
    ftype='int16';
end

%Checking Threshold > .5
if Tresh<.5
	Tresh==.5;
end

%Extracting File name and renaming data
ii=find(infile=='.');
ext=infile(ii+1:length(infile));
filename=infile(1:ii-2);

%Finding Which File Blocks Exist
i=1;
file=[filename num2str(i) '.' ext];
while exist(file)

	%Incrementing File index
	i=i+1;

	%Incrementing File Name
	file=[filename num2str(i) '.' ext];

end
i=i-1;

%Opening File
fid=fopen([ filename '1.' ext ]);

%Finding the Aproximate Mean in the File
%Opening 1st File and Finding the Max
%Searching 10 Segments
MeanX=0;
for j=1:10
	%Reading Data
	X=fread(fid,M,ftype)';
	
	%Deleting Header If Necessary
	if j==1
		X(1:100)=zeros(1,100);
	end
	MeanX=MeanX+mean(X);
end
MeanX=MeanX/10;

%Finding the Aproximate Max in the File
%Opening 1st File and Finding the Max
%Searching 10 Segments
frewind(fid);
MaxX=-9999;
for j=1:10
	%Reading Data
	X=fread(fid,M,ftype)';
	
	%Deleting Header If Necessary
	if j==1
		X(1:100)=zeros(1,100);
	end
	MaxX=max([MaxX abs(X-MeanX)]);
end

%Closing Files
fclose('all');

%Uploading Files and Finding Triggers
TrigTimes=[];
count=0;
for k=1:i

	%Display Ouput 
	clc
	disp(['Analyzing Block '  int2str(k)]);

	%Opening File
	fid=fopen([ filename num2str(k) '.' ext ]);

	%Loading data and finding Triggers
	while ~feof(fid)

		%Reading Input File
		X=abs(fread(fid,M,ftype)'-MeanX)/MaxX;

		%Adding First Element to avoid missing trigger 
		%if trigger falls exactly on edge
		if k==1 & count==0
			X0=X(1);
			X=[X0 X];
		elseif length(X)>0
			X=[X0 X];	
		end

		%Deleting Header If Necessary
		if k==1 & count==0
			X(1:100)=zeros(1,100);
		end

		%Finding Triggers
		if length(X) > 0
			%Setting Anything < Tresh to zero
			index=find(X<Tresh);
			X(index)=zeros(1,length(index));
	
			%Finding Edges in X
			D=diff(X);
			indexD=find(D>=Tresh);	%Finding Trigger Locations
	
			%Converting to Trigger Times
			TrigTimes=[TrigTimes M*count+indexD];

			%Finding the Last Elemnt of X 
			%This is placed as the first element in the 
			%new X Array
			X0=X(length(X));

			%Incrementing Counter
			count=count+1;
		end
	end
end

%Checking for Extra Trigger in Tunning Curve
if ~isempty(TrigTimes)
	if TrigTimes(1)==101
		TrigTimes=TrigTimes(2:length(TrigTimes));
	end
end