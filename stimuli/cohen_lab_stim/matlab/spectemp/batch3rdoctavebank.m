%
%function []=batch3rdoctavebank(Fs,Fm,OF,ATT,M,overlap,overlapH,nice)
%
%       FILE NAME       : BATCH A GRAM FL
%       DESCRIPTION     : Computes the audiogram of all the '.sw' files
%			  in a directory using the C routine audiogramfl
%			  This routine stores data to 'float' format
%
%	Fs		: Sampling rate ( Hz )
%	Fm		: Maximum envelope modulation frequency ( Hz )
%	OF		: Envelope overampling factor ( > 1 )
%	ATT		: Sidelobe attenuation ( dB )
%	M		: FFT block size (default=262144)
%	overlap		: Percent filter overlap (default=0.0%)
%	overlapH	: Percent overlap for Hilbert transform (default=10%)
%	nice		: Nice priority (defult==19)
%
function []=batch3rdoctavebank(Fs,Fm,OF,ATT,M,overlap,overlapH,nice)

if nargin<5
	M=1024*256;
end
if nargin<6
	overlap=0;
end
if nargin<7
	overlap=10;
end
if nargin<8
	nice=19;
end

%Preliminaries
more off

%Generating a File List
f=['ls *.sw' ];
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
returnindex=findstr(List,setstr(10));
for l=1:length(returnindex)-1
	for k=1:30
		if k+returnindex(l)<returnindex(l+1)
			Lst(l,k)=List(returnindex(l)+k);
		else
			Lst(l,k)=setstr(32);
		end
	end
end

%Batching 3RDOCTAVEBANK
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.sw');
	filename=[ Lst(k,1:index-1) '.sw'];
	if exist(filename)
		f=['!nice -n ' num2str(nice) ' 3rdoctavebank ' filename ' ' num2str(Fs,8) ' ' num2str(Fm,8) ' ' num2str(OF,8) ' ' num2str(ATT,8) ' ' num2str(M,8) ' ' num2str(overlap,8) ' ' num2str(overlapH,8)];
		disp(f);
		eval(f);
	end
end
