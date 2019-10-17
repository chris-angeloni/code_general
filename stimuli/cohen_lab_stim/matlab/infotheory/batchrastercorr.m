%
%function []=batchrastercorr(BatchFile,Header,Fsd,T)
%
%
%       FILE NAME       : BATCH RASTER CORR
%       DESCRIPTION     : Computes the average across trial correlation
%			  from the response RASTERGRAM. Determines the
%			  p<0.01 and p<0.05 significance limits
%
%	BatchFile	: Experiment Batch File
%	Header		: Experiment Header
%	Fsd		: Desired sampling rate for RASTER (Hz)
%	T		: Time Lag Used for Cross-Correlation (msec)
%
%Example Batch File - Use same batch as for INFBATCH
%
%File                    Unit                    Contrast        Type
%--------------------------------------------------------------------------
%mt3_f00_ch1             0                       60              PRE
%mt3_f01_ch1             0                       30              PRE
%t3_f02_ch1              0                       Lin             PRE
%t2_f07_ch1              0                       60              STRF
%
function []=batchrastercorr(BatchFile,Header,Fsd,T)

%Preliminaries
more off

%Tab Charachter
Tab=setstr(9);

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
DataList=zeros(length(returnindex)-1,100);
for k=1:length(returnindex)-1

	CurrentList=setstr(List(returnindex(k)+1:returnindex(k+1)-1));
	DataList(k,1:length(CurrentList)+1)=[CurrentList Tab];

end
DataList=setstr(DataList);

%Finding Corresponding Files and Computing Enthropy
spet=[];
for k=1:length(returnindex)-1

	if strcmp(DataList(k,1),'t') | strcmp(DataList(k,1:2),'mt')

		%Finding File Number, Tape Number, Unit Number, and Type
		tabindex=findstr(DataList(k,:),Tab);
		if strcmp(DataList(k,1),'t')
			Tape=DataList(k,1:tabindex(1)-1);
		else
			Tape=DataList(k,2:tabindex(1)-1);
		end
		Units=DataList(k,tabindex(2)+1:tabindex(3)-1);
		Contrast=DataList(k,tabindex(5)+1:tabindex(6)-1);
		Type=DataList(k,tabindex(7)+1:tabindex(8)-1);

		%Spet File Name and Trig File Name
		SpetFile=[Header Tape ];
		TrigFile=[Header Tape(1:length(Tape)-3) 'Trig'];

		%Loading Spet and Trig Files
		f=['load ' TrigFile];
		eval(f);
		f=['load ' SpetFile];
		eval(f);

		%Finding Appropriate File Type and Computing Enthropy
		if strcmp(Type,'PRE')

			%Finding RASTER For Corresponding Units
			UnitsArray=[];
			for l=1:length(Units)
				if ~strcmp(Units(l),'+')
					%Generating Compound Spet
					if isempty(spet)
						f=['spet=spet' Units(l) ';'];
						eval(f)
					else
						f=['spet=[spet spet' Units(l) '];'];
						eval(f)
					end

					%Compound Unit umbers
					UnitsArray=[UnitsArray Units(l)];
				end
			end
			spet=sort(spet);

			%Computing Raster For Compound Spet
			[taxis,PSTH,RASTER]=psth(Trig,spet,Fs,Fsd);

			%Computing Average Raster Correlation - Removes first 
			%25 Trials to remove adaptation
			NN=size(RASTER,1);
			RASTER=RASTER(25:NN,:);
			[Ravg,Rstd,R05,R01]=rastercorr(RASTER,taxis,T); 

			%Saving To File
			f=['save ' SpetFile '_u' UnitsArray '_RasCorrAvg',...
			' Ravg Fsd T Rstd R05 R01 '];
			if ~strcmp(version,'4.2c')
				f=[f ' -v4'];
			end
			eval(f);	
			disp(f);	

			%Re-Initializing Ratser and Clearing Variables
			spet=[];
			clear RATSER RASTERs PSTH PSTHs taxis

		end

	end

end

