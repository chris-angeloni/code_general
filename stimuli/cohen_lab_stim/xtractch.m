%
%function []=xtractch(infile,ch,M,B)
%
%       FILE NAME       : XTRACT CH
%       DESCRIPTION     : Extracts a given channel sequnce from 'int16' infile 
%			  and stores as 'int16'.  The data is stored 
%			  as a sequence of numbered files each not exceding 
%			  a sample length of B Megs
%			  Output Data file name is choosen automatically 
%			  from infile with 'bin' extension
%
%       infile          : Input File
%	ch		: Channel (s) to extract. Can be an array of channels.
%			  eg., ch=[1] , ch=[1 3 4], etc.
%OPTIONAL
%	M		: Buffer Length : 128K Default 
%	B		: File Block Size, Number of Megs
%			  Default = 10 Meg
%
function []=xtractch(infile,ch,M,B)

%Checking Input Arguments
if nargin<3 
	M=1024*128;
	B=10;
elseif nargin<4
	B=10;
end
M=2^ceil(log2(M));

%Determining Input File name and extension
ii=find(infile=='.');
ext='raw';
filename=[infile(1:ii-1) '_ch' num2str(ch)];

%Read Header information fram DAT File
[Sr,interleave] = dat_header(infile);  
nchan = length(interleave);		
ch = find(interleave==ch);		% finds chan in interleaved sampling sequence

%Opening Input File
fidin=fopen(infile,'r');

%Reading and Saving data
M=2^(round(log2(M)))/2;
L=1024*1024*B*nchan;
filecounter=1;
while  ~feof(fidin) & L~=0
	%Ouput File
	outfile=[filename '_b' num2str(filecounter) '.' ext];
	fidout=fopen(outfile,'w');
	
	%Saving data to File
	count=0;
	while count*M<L 
		X=fread(fidin,M,'int16');
		fwrite(fidout,X(ch:nchan:length(X)),'int16');
		count=count+1;
	end

	%Closing File and Incrementing File Counter
	fclose(fidout);
	filecounter=filecounter+1;
end

%Closing Files
fclose('all');
