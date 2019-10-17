%
%function [HWordt,HSpiket,HSect,HWord,HSpike,HSec,Rate]=infwordraster(RASTER,taxis,Fsd,B,M)
%
%
%       FILE NAME       : INF WORD RASTER
%       DESCRIPTION     : Noise Enthropy of a Spike Train obtained from the 
%			  rastergram by computing the 
%			  Probability Distribution, P(W|t), of finding a B
%			  letter Word, W, in the Spike Train at time T
%
%       RASTER		: Rastergram
%	taxis		: Time Axis
%	Fsd		: Sampling rate for generating P(W)
%	B		: Length of Word, number of bits
%	M		: Number of RASTERs to remove to avoid adaptive 
%			  effects (Default: M=25)
%
%Returned Variables
%	HWordt		: Conditional Enthropy per Word
%	HSpiket		: Conditional Enthropy per Spike
%	HSect		: Conditional Enthropy per Second
%	HWord		: Enthropy per Word
%	HSpike		: Enthropy per Spike
%	HSec		: Enthropy per Second
%	Rate		: Mean Spike Rate
%	dt		: Actual Temporal Resolution Used
%
function [HWordt,HSpiket,HSect,HWord,HSpike,HSec,Rate,dt]=infwordraster(RASTER,taxis,Fsd,B,M)

%Input Arguments
if nargin<5
	M=25;
end

%Truncating RASTER if Desired
if M~=0
	RASTER=RASTER(M+1:size(RASTER,1),:);
end

%Temporal Resolution
dt=1/Fsd;
Fs=1/(taxis(2)-taxis(1));
L=max(round(Fs/Fsd),1);

%Making A Smoothing Window
W=ones(1,L);

%Convolving Smoothing Window With RASTER
for k=1:size(RASTER,1)
	RASTERc(k,:)=conv(RASTER(k,:),W);
end

%Binary Mask
D=max(max(max(RASTERc)),2);
Mask=[];
for k=1:B
        Mask=[Mask D^(k-1)];
end

%Finding Word Distribution : P(W|t)
P=0;
NN=0;
for k=1:size(RASTERc,2)-L*B

	%Initializing Conditionl Distribution to Zero
	Pt=zeros(size(NN));

	%Finding Word Distribution conditional t
	for l=1:size(RASTERc,1)
		Word=RASTERc(l,k+(0:L:L*B-1));
		n=sum(Mask.*Word);
		index=find(NN==n);
		if isempty(index)
			Pt=[Pt 1];
			P=[P 1];
			NN=[NN n];
		else
			Pt(index)=Pt(index)+1;
			P(index)=P(index)+1;
		end
	end

	%Normalizing Conditional Word Histogram
	PPt=Pt/sum(Pt);
	PP=P/sum(P);

	%Finding Enthropy
	index=find(PPt~=0);
	Ht(k)=sum(PPt(index).*log2(1./PPt(index)));
	index=find(PP~=0);
	H(k)=sum(PP(index).*log2(1./PP(index)));

	%Displaying Output
	if k/100==round(k/100)
		clc
		disp(['Percent Done: ' int2str(k/length(taxis)*100) ' %'])
	end

end

%Mean Spike Rate
Rate=mean(mean(RASTER)*Fs);

%Enthropy per time and per spike
HWordt=Ht;
HSect=HWordt/dt/B;
HSpiket=HSect/Rate;
HWord=H;
HSec=HWord/dt/B;
HSpike=HSec/Rate;
dt=L/Fsd;
