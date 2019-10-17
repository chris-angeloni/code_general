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
%	filename	: File Name
%
function []=channelcheck(filename)


X1=zeros(1,44100);
X1(1:1000)=ones(1,1000);
X2=X1;
X2(2001:3000)=ones(1,1000);
X3=X2;
X3(3001:4000)=ones(1,1000);
X4=X3;
X4(4001:5000)=ones(1,1000);

X=zeros(1,44100*4);
X(1:4:44100*4)=X1;
X(2:4:44100*4)=X2;
X(3:4:44100*4)=X3;
X(4:4:44100*4)=X4;

X=[X X X X X X X X X X ];

fid=fopen(filename,'w');
fwrite(fid,X,'int16');



