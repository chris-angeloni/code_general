%function [W2]=wiener2(infile,Fs,T11,T12,T21,T22,nchannel,dch,set,ds)
%
%       FILE NAME       : WIENER 2 
%       DESCRIPTION     : 2nd Order Wiener Kernel
%			  Uses Lee/Schetzen Aproach
%
%	infile		: Input file name
%	Fs		: Sampling Rate
%	T11, T12	: Evaluation delay interval for W2(T1,T2)
%			  T1 = [T11 T12] ( sec )
%	T21, T22	: Evaluation delay interval for W2(T1,T2)
%			  T2 = [T21 T22] ( sec )
%	nchannel	: Number of channels
%	dch		: Data Channel ( Stimulus ) 
%	set		: Array of spike event times
%	ds		: Down Sampling Factor
%
function [W2]=wiener2(infile,Fs,T11,T12,T21,T22,nchannel,dch,set,ds)

%Converting delay intervals to samples
N11=round(T11*Fs);
N12=round(T12*Fs);
N21=round(T21*Fs);
N22=round(T22*Fs);
N=length(set);

%Opening Input File
fid=fopen(infile,'r');

%Computing 2nd Order REVCORR
clc
disp('Evaluating 2nd Order REVCORR')
R2=zeros(floor((N12-N11)/ds),floor((N22-N21)/ds));
for k=1:N
	if (set(k)-N12-1)*nchannel > 1 & (set(k)-N22-1)*nchannel > 1
		%Reading Data
		fseek(fid,2*((set(k)-N12-1)*nchannel),-1);
		X1=fread(fid,(N12-N11)*nchannel,'int16');
		fseek(fid,2*((set(k)-N22-1)*nchannel),-1);
		X2=fread(fid,(N22-N21)*nchannel,'int16');

		%Finding R2
		X1=fliplr( X1(dch:nchannel:length(X1)) );
		X2=fliplr( X2(dch:nchannel:length(X2)) );
		X1= X1(1:ds:length(X1))' ;
		X2= X2(1:ds:length(X2))' ;
		R2=R2+X1'*X2/N;
	end

	%Percent Done
	if floor(k/N*10)==round(k/N*1000)/100
		clc
		disp(['Evaluating 2nd Order REVCORR: ' num2str(round(k/N*100)) ' % Done'])
	end
end

%Findign 2nd Order XCORR
clc
disp('Finding Signal Power')
L=1024*256;
fseek(fid,L,-1);
count=1;
Rxx=zeros(size(R2));
for k=1:N
	

	if ~feof(fid)==1
		
		%Reading Data
		fseek(fid,2*( (L + k*(N12-N11) - N12 -1 )*nchannel ),-1);
		X1=fread(fid, (N12-N11)*nchannel,'int16');
		fseek(fid,2*( (L + k*(N22-N21) - N22 -1 )*nchannel ),-1);
		X2=fread(fid, (N22-N21)*nchannel,'int16');

		%Finding R2
		X1=fliplr( X1(dch:nchannel:length(X1)) );
		X2=fliplr( X2(dch:nchannel:length(X2)) );
		X1= X1(1:ds:length(X1))' ;
		X2= X2(1:ds:length(X2))' ;
		Rxx=Rxx+X1'*X2/N;

	end
end

%Subtracting X-Corr From Rev-Corr
W2=R2-Rxx;

%Rotating 
W2=rot90(rot90(W2));

