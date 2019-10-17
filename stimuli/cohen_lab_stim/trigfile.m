%
%function []=trigfile(outfile,M,N,L,Tripple)
%
%       FILE NAME       : TRIG FILE
%       DESCRIPTION     : Generates an 'int16' trigger file
%
%	outfile		: Output file name 
%	M		: Inter Trigger Times (Number of Samples)
%	N		: Number of Blocks in Between Double Triggers
%	L		: File Length (Number of Samples)
%	Tripple		: Tripple Trigger at Begining
%			  'y' or 'n'
%			  Default 'n'
%
function []=trigfile(outfile,M,N,L,Tripple)

%Input arguments
if nargin<5
	Tripple='n';
end

%Opening Output File
fid=fopen(outfile,'w');

%Writing Triggers Blocks of Length M 
NBlocks=floor(L/M);
Block=zeros(1,M);
Block(1:2000)=ones(1,2000)*(1024*32-1);
for k=1:NBlocks
	if floor((k-1)/N)==(k-1)/N & k~=1
		Block(4001:6000)=ones(1,2000)*(1024*32-1);
		fwrite(fid,Block,'int16');
		Block(4001:6000)=zeros(1,2000);
	elseif k==1 & strcmp(Tripple,'n')
		Block(4001:6000)=ones(1,2000)*(1024*32-1);
		fwrite(fid,Block,'int16');
		Block(4001:6000)=zeros(1,2000);
	elseif k==1 & strcmp(Tripple,'y')
		Block(4001:6000)=ones(1,2000)*(1024*32-1);
		Block(8001:10000)=ones(1,2000)*(1024*32-1);
		fwrite(fid,Block,'int16');
		Block(4001:6000)=zeros(1,2000);
		Block(8001:10000)=zeros(1,2000);
	else
		fwrite(fid,Block,'int16');
	end
end

%Writing the last block
if L-NBlocks*M>2000
	Block=zeros(1,L-NBlocks*M); 
	Block(1:2000)=ones(1,2000)*(1024*32-1);
else
	Block=ones(1,L-NBlocks*M)*(1024*32-1);
end
if ~isempty(Block)
	fwrite(fid,Block,'int16');
end

%Closing Output File
fclose('all');
