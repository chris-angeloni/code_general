%function [W1]=wiener1(infile,Fs,T1,T2,nchannel,dch,set)
%
%       FILE NAME       : WINER1 
%       DESCRIPTION     : 1st Order Wiener Kernel
%			  Uses Lee/Schetzen Aproach
%
%	infile		: Input file name
%	Fs		: Sampling Rate
%	T1, T2		: Evaluation delay interval for W1(T)
%			  T = [T1 T2] ( sec )
%	nchannel	: Number of channels
%	dch		: Data Channel ( Stimulus ) 
%	set		: Array of spike event times
%
function [W1]=wiener1(infile,Fs,T1,T2,nchannel,dch,set)

%Converting delay intervals to samples
N1=round(T1*Fs);
N2=round(T2*Fs);
N=length(set);

%Opening Input File
fid=fopen(infile,'r');

%Computing 1st Order Kernel
disp('Evaluating W1')
W1=zeros(1,N2-N1);
for k=1:N
	if (set(k)-N2-1)*nchannel > 1
		fseek(fid,2*((set(k)-N2-1)*nchannel),-1);
		X=fread(fid,(N2-N1)*nchannel,'int16');
		X=fliplr( X(dch:nchannel:length(X))' )/N;
		W1=W1+X;
	end

	%Percent Done
	if floor(k/N*10)==round(k/N*1000)/100
		clc
		disp(['Percent Done: ' num2str(round(k/N*100)) ' %'])
	end
end
