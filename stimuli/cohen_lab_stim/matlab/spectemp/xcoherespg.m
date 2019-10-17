%
%function [R]=corrcoefsgram(header,L,dfm)
%
%       FILE NAME       : X COHERE SPG
%       DESCRIPTION     : Computes the Cross Band Coherence Function
%			  for an SPG Spectrogram File
%
%	header		: File name header
%	M		: Data block size
%	L		: Number of blocks to use (Default=inf)
%	dfm
%
%RETURNED VALUES
%
%	C		: Coherence Matrix
%	N		: 
%
function [C]=xcoherespg(header,M,L,dfm)

%Input Arguments
if nargin<3
	L=inf;
end

%Loading Param File
f=['load ' header '_param.mat'];
eval(f);

%Opening SPG File
filename=[header '.spg'];
fid=fopen(filename);

%Temporal Sampling Rate For Spectrogram
Fs=1/(taxis(2)-taxis(1));

%Designing Window For Coherence
ATT=40;
W=designw(dfm,ATT,Fs,'3dB');
NFFT=2.^(nextpow2(length(W)));

%Finding Cross Band Coherence Matrix
count=0;
C=[];
while ~feof(fid) & count<L

	%Displaying Output
	clc
	disp(['Evaluating Block Number: ' int2str(count+1)])

	%Generating Data Block of At Least M Temporal Samples
	SPG=[];
	while ~feof(fid) & size(SPG,2)<M
		%Reading Input Data Block
		spg=fread(fid,NF*NT,'float');
		NTT=length(spg)/NF;
		spg=reshape(spg,NF,NTT);
		SPG=[SPG spg];
size(SPG)
	end
%pcolor(SPG),shading flat,colormap jet
%pause(0)

	%Computing Coherence Matrix
	for k=1:NF
k
		for l=1:k

%			%Generating k-th adn l-th Temporal Sequence
%			spgk=[];
%			spgl=[];
%			while ~feof(fid)
%				%Reading Input Data Block
%				spg=fread(fid,NF*NT,'float');
%				NTT=length(spg)/NF;
%				spg=reshape(spg,NF,NTT);
%				spgk=[spgk spg(k,:)];
%				spgl=[spgl spg(l,:)];
%			end 
[Ckl,Faxis]=cohere(SPG(k,:),SPG(l,:),NFFT,Fs,W); 

%			RR=corrcoef(spg(k,:),spg(l,:));
%			if size(RR)==[2 2]
%				R(k,l)=R(k,l)+RR(1,2);
%			end;
		end
	end
	count=count+1;

end

