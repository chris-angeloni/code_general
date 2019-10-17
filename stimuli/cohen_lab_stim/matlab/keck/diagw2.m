%function [DW2]=diagw2(infile,Fs,T1,T2,nchannel,dch,set)
%
%       FILE NAME       : DIAG W2 
%       DESCRIPTION     : Diagonal of 2nd Order Wiener Kernel
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
function [DW2]=diagw2(infile,Fs,T1,T2,nchannel,dch,set)

%Converting delay intervals to samples
N1=round(T1*Fs);
N2=round(T2*Fs);
N=length(set);

%Opening Input File
fid=fopen(infile,'r');

%Computing 2nd Order REVCORR
clc
disp('Evaluating 2nd Order REVCORR')
R2=zeros(1,N2-N1);
for k=1:N
	if (set(k)-N2-1)*nchannel > 1
		%Reading Data
		fseek(fid,2*((set(k)-N2-1)*nchannel),-1);
		X=fread(fid,(N2-N1)*nchannel,'int16');
		X=fliplr( X(dch:nchannel:length(X))' );
		R2=R2+X.^2/N;		
	end

	%Percent Done
	if floor(k/N*10)==round(k/N*1000)/100
		clc
		disp(['Evaluating 2nd Order REVCORR: ' num2str(round(k/N*100)) ' % Done'])
	end
end

%Computing 2nd Order AutoCorrelation ( Power ) at T1=T2
clc
disp('Finding Signal Power')
frewind(fid);
count=1;
Rxx=zeros(size(R2));
for k=1:N
	X=fread(fid,(N2-N1)*nchannel,'int16');
	if ~feof(fid)==1
		X=fliplr( X(dch:nchannel:length(X))' );
		Rxx=Rxx + X.^2;
		count=count+1;
	end
end
Rxx=Rxx/count;

%Diagonal of 2nd Order Wiener Kernel
DW2=length(set)/count*Fs/2*(R2-Rxx);












