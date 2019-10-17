%
%function [faxis,EnsASP]=batchensspectrumagram(filename)
%
%	FILE NAME 	: BATCH ENS SPECTRUM AGRAM
%	DESCRIPTION 	: Batch file which computes the ENSEMBLE spectrum
%			  for all AUDIOGRAM (STE) files in a directory.
%	
%	filename	: Output File Name
%
%RETURNED VARIABLES
%	faxis		: Frequency Axis
%	EnsASP		: Ensemble Audiogram Spectrum
%
function [faxis,EnsASP]=batchensspectrumagram(filename)

%Preliminaries
more off

%Generating a File List
f=['ls *STE_AGRAM.mat' ];
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

%Finding Ensemble Audiogram Spectrum 
count=0;
for k=1:size(Lst,1)
	filename=[Lst(k,:)];

	if exist(filename)
		f=['load ' filename];
		eval(f) 

		%Normalizing All Spectrum for Unit Energy
		ASP=ASP/sqrt(sum(ASP.^2));

		%Finding Ensemble Spectrum
		if ~exist('EnsASP','var')
			EnsASP=ASP;
		else
			EnsASP=EnsASP + ASP;
		end

		%Number of Averages
		count=count+1; 

	end
end

%Dividing by Number of Averages
EnsASP=EnsASP/count;
