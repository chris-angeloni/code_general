%
%function []=batchspgampdist(f1,f2,ND)
%
%	FILE NAME 	: BATCH SPG AMP DIST
%	DESCRIPTION 	: Batch for Emperically estimating the dB Contrast 
%			  Distribution from an SPG (spectrogram) file
%
%       f1              : Lower Frequency for Analysis
%       f2              : Upper Frequency for Analysis
%       ND              : Polynomial Order: Detrends the local spectrum
%                         by fiting a polynomial of order ND. The fitted
%                         trend is then removed. If ND==0 then no detrending
%                         is performed. Default==0 (No detrending)
%
function []=batchspgampdist(f1,f2,ND)

%Input Arguments
if nargin<3
	ND=0;
end

%Preliminaries
more off

%Generating a File List
f=['ls *.spg' ];
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

%Batching SPGAMP
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.spg');
	filename=[ Lst(k,1:index-1) '.spg'];

	if exist(filename)

		%Evaluating SpgAmp and Saving to File
		spgampdist(filename,f1,f2,ND,'y','n');

	end
end
