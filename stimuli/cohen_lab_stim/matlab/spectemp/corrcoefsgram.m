%
%function [R]=corrcoefsgram(header,L)
%
%       FILE NAME       : CORR COEF SGRAM
%       DESCRIPTION     : Computes the Cross Band Coerrelation Coefficient
%			  for the spectrogram derived spectro-temporal envelope
%
%	header		: File name header
%	M		: Data block size
%	L		: Number of blocks to use (Default=inf)
%
%RETURNED VALUES
%
%	R		: Correlatoin Coefficient Matrix
%
function [R]=corrcoefsgram(header,L)

%Input Arguments
if nargin<2
	L=inf;
end

%Loading Param File
f=['load ' header '_param.mat'];
eval(f);

%Opening SPG File
filename=[header '.spg'];
fid=fopen(filename);

%Finding Cross Band Correlatoin Coefficient Matrix
count=0;
R=zeros(NF,NF);
while ~feof(fid) & count<L
count
	%Displaying Output
	clc
	disp(['Evaluating Block Number: ' int2str(count+1)])

	%Reading Input Data Block
	spg=fread(fid,NF*NT,'float');
	NTT=length(spg)/NF
	spg=reshape(spg,NF,NTT);

	%Computing CorrCoef Matrix
	for k=1:size(spg,1)
		for l=1:k
			RR=corrcoef(spg(k,:),spg(l,:));
			if size(RR)==[2 2]
				R(k,l)=R(k,l)+RR(1,2);
			end;
		end
	end
	count=count+1;
end
R=R/count;

%Since matrix is symetric copy second half
for k=1:size(R,1)
	for l=1:k-1
		R(l,k)=R(k,l);		
	end
end

%Fixing diagonal correlation
R(1,1)=R(1,2);
R(size(R,1),size(R,1))=R(size(R,1),size(R,1)-1);
for k=2:size(R,1)-1
	R(k,k)=(R(k-1,k)+R(k-1,k+1)+R(k,k+1))/3;
end
