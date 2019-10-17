%
%function [T,Y,Y1,Y2,Trig]=strfsprpretrig(sprfile,timeaxis,freqaxis,STRF1,STRF2,MdB,L,ftype)
%
%   FILE NAME   : STRF SPR PRE TRIG
%   DESCRIPTION : Predicts output of an SPR file using the STRF
%                 No amplitude normalization is performed!
%                 Generates triggers that can be used to construct the STRF
%
%	sprfile		: Spectrotemporal envelope input file
%	timeaxis	: Time Axis for STRF
%	freqaxis	: Frequency Axis for STRF
%	STRF1		: Contra STRF
%	STRF2		: Ipsi STRF
%	MdB         : Modulation Depth
%   L           : the number of blocks
%                 for MR, L=1706;
%                 for RN, L=1500;
%	ftype       : File Type (Optional; Default=='float')
%
%OUTPUT VARIABLES
%	T		: Time Axis
%	Y		: Predicted Output
%	Y1		: Predicted Output for STRF1
%	Y2		: Predicted Output for STRF2
%	Trig    : Triggers for generating STRF using rtwstrfdb
%
%(C) Monty A. Escabi, Dec 2011
%
function [T,Y,Y1,Y2,Trig]=strfsprpretrig(sprfile,timeaxis,freqaxis,STRF1,STRF2,MdB,L,ftype)

if nargin<8
	ftype='float';
end

%Loading Param File
i=find(sprfile=='.');
paramfile=[sprfile(1:i-1) '_param.mat'];
f=['load ' paramfile];
eval(f);

%Opening SPR File
fid=fopen(sprfile);

%Sampling Rate and STRF dimmensions
Fs=Fs/DF;
N1=size(STRF1,1);
N2=size(STRF1,2);

%Reading Input SPR Block
S=reshape(fread(fid,NT*NF,ftype),NF,NT);

%Reading Data and Computing Spectro-temporal Convolution
Trig=[];
count=1;
Y1=zeros(1,N2-1);
Y2=zeros(1,N2-1);
while ~feof(fid) & (count-1<L)

	%Display Output
	clc
	disp(['Performing Spectrotemporal Convolution on Segment: ' num2str(count)])

	%Performing Spectrotemporal Convolution
	[T,Yblock,Yblock1,Yblock2]=strf2pre(S,timeaxis,freqaxis,STRF1,STRF2,MdB,'n'); 
	Nb1=length(Yblock1);
	Nb2=length(Yblock2);

	%Concatenating Output Segments using overlap add method
	Ny1=length(Y1);
	Ny2=length(Y2);
	Y1=[Y1(1:Ny1-N2+1) Y1(Ny1-N2+2:Ny1)+Yblock1(1:N2-1) Yblock1(N2:Nb1)];
	Y2=[Yblock2(1:Nb2-N2+1) Y2(1:N2-1)+Yblock2(Nb2-N2+2:Nb2) Y2(N2:Ny2)];

	%Generating Triggers for each SPR sound block
	Trig=[Trig Ny1-N2+1];
    
	%Incrementing counter
	count=count+1;

	%Reading Input SPR Block
        if count~=L+1;
            S=reshape(fread(fid,NT*NF,ftype),NF,NT);
        end;

end

%Delay one sample
Y1=[Y1(2:length(Y1)) 0];
Y2=[0 Y2(1:length(Y2)-1)];

%Total intracellular current for both ears
Y=Y1+Y2;

%Closing spr file
fclose all;
