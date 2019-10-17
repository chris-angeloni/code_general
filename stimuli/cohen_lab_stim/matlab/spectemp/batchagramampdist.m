%
%function []=batchagramampdist(f1,f2,Fs,dT,faxis,ND)
%
%	FILE NAME 	: BATCH AGRAM AMP DIST
%	DESCRIPTION 	: Batch for Emperically estimating the dB Contrast 
%			  Distribution from an STE (Audiogram) file
%
%       f1              : Lower Frequency for Analysis
%       f2              : Upper Frequency for Analysis
%	Fs		: Temporeal Sampling Frequency for Envelope
%	dT		: Temporal Resoultion for Contrast Measurement
%	faxis		: Frequency Axis
%       ND              : Polynomial Order: Detrends the local spectrum
%                         by fiting a polynomial of order ND. The fitted
%                         trend is then removed. If ND==0 then no detrending
%                         is performed. Default==0 (No detrending)
%
function []=batchagramampdist(f1,f2,Fs,dT,faxis,ND)

%Input Arguments
if nargin<6
	ND=0;
end

%Preliminaries
more off

%Generating a File List
f=['ls *_001.ste' ];
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

%Batching AGRAMAMPDIST
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'_001.ste');
	header=[ Lst(k,1:index-1)];
	filename=Lst(k,:);

	if exist(filename)
		%Evaluating AGRAMAMPDIST and Saving to File
		agramampdist(header,f1,f2,dT,faxis,Fs,'n','y'); 
	end
end
