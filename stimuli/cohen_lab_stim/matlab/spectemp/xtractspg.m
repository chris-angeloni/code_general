%
%function [spg]=xtractspg(header,NB1,NB2)
%
%       FILE NAME       : XTRACT SPG 
%       DESCRIPTION     : Xtracts a segment of the Spectro-Temporal Envelope
%			  (from .spg file) deliniated by the blocks NB1...NB2
%
%	header		: File name header
%	NB1		: Starting Block Number (1:NBMax)
%	NB2		: Ending Block Number (1:NBMax)
%
%RETURNED VALUES
%
%	spg		: Spectro-temporal envelope matrix
%			  returns -1 upon failure or EOF
%
function [spg]=xtractspg(header,NB1,NB2)

%Input Files
Paramfile=[header '_param.mat'];
Spgfile=[header '.spg'];

%Opening SPG File
fid=fopen(Spgfile);

%Loading Parameter File
f=['load ' Paramfile];
eval(f)

%Reading Data Segment
count=0;
spg=[];
spg1=[];
spg10=[];
spg100=[];
NB1=NB1-1;
flag=fseek(fid,4*(NB1*NT*NF),-1)
while count<NB2-NB1 & ~feof(fid)

	spg1=fread(fid,NT*NF,'float');
	if length(spg1)==NT*NF
		NTT=length(spg1)/NF;
		spg1=reshape(spg1,NF,NT);
		spg10=[spg10 spg1];
		count=count+1
	
		if count/10==round(count/10)
			spg100=[spg100 spg10];
			spg10=[];
		end
		if count/100==round(count/100)
			spg=[spg spg100];
			spg100=[];
		end
	end
end
if size(spg100,2)>10 & size(spg10,2)>1
	spg=[spg spg100 spg10];

hi=1
elseif size(spg100,2)>10
	spg=[spg spg100];
hi=2
elseif size(spg10,2)>1
	spg=[spg spg10];
end

