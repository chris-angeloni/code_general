%
%function [TrigTimes]=trig2matE(infile,Fs,M,Tresh)
%
%       FILE NAME	: TRIG FIND
%       DESCRIPTION     : Find triggers from a DAT tape file; if tuning
%			   curve, must be triggers of type 'E'
%
%	infile		: filename 
%	Fs		: Sampling Rate
%	M		: Block Size
%			  Default: M==1024*128
%			  M must be Dyadic and < = 1024*1024
%	Tresh		: Threshhold : Normalized [.5 , 1]
%			  Default: Tresh==.75
%	TrigTimes	: Returned Trigger Time Vector (in sample number)
%
function [TrigTimes]=trig2matE(infile,Fs,M,Tresh)

%Checking Inputs
if nargin<3
	M=1024*128;
	Tresh=.75;
elseif nargin<4
	Tresh=.75;
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

%Finding the Aproximate Max in the File
%Opening 1st File and Finding the Max
%Searching 10 Segments
fid=fopen([ filename '1.' ext ]);
MaxX=-9999;
for j=1:10
	%Reading Data
	X=fread(fid,M,'int16')';
	
	%Deleting Header If Necessary
	if j==1
		X(1:100)=zeros(1,100);
	end
	MaxX=max([MaxX abs(X)]);
end

%Uploading Files and Finding Triggers
TrigTimes=[];
count=0;
for k=1:i

	%Display Ouput 
	clc
	disp(['Analyzing Block '  int2str(k)])

	%Opening File
	fid=fopen([ filename num2str(k) '.' ext ]);

	%Loading data and finding Triggers
	while ~feof(fid)

		%Reading Input File
		X=abs(fread(fid,M,'int16')')/MaxX;
	
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
			TrigTimes=[TrigTimes M*count+indexD+1];
		end

		%Incrementing Counter
		if ~feof(fid)
			count=count+1;
		end
	end
end

numTrigs=length(TrigTimes);		%take out spurious first trigger if exists
d=diff(TrigTimes);
if numTrigs==676
   if d(1)>Fs
      TrigTimes=TrigTimes(2:end);
   end
end
numTrigs=length(TrigTimes);
disp([num2str(numTrigs) ' triggers found.']);

where = findstr(filename,'_b');
outfile = [filename(1:(where-1)) '.mat'];

eval(['save ' outfile ' TrigTimes Fs']);
outstr = [outfile ' saved.'];
disp(outstr);
