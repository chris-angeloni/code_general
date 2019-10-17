%
%function []=infbatchextrapolate(BatchFile,Header,Fsd,B,M,L,N)
%
%
%       FILE NAME       : INF BATCH EXTRAPOLATE
%       DESCRIPTION     : Computes the Information for Pre and Spet Files 
%			  In an Experiment
%
%	BatchFile	: Experiment Batch File
%	Header		: Experiment Header
%	Fsd		: Desired sampling rate for Enthropy Computation
%	B		: Array of Number of Bits Per Word
%			  Default: B=[5 6 8 10 15 20 40 80 160 200]
%	L		: Number of Bootstrap Iterations (Default: L=10)
%	M		: Number of RASTERs to remove to avoid adaptive 
%			  effects (Default: M=25)
%	N		: Enthropy Estimated Every N/1000 sec for 
%			  INFWORDSPIKE
%			  Default: N=250
%
%Example Batch File
%
%File                    Unit                    Contrast        Type
%--------------------------------------------------------------------------
%mt3_f00_ch1             0                       60              PRE
%mt3_f01_ch1             0                       30              PRE
%t3_f02_ch1              0                       Lin             PRE
%t2_f07_ch1              0                       60              STRF
%
function []=infbatchextrapolate(BatchFile,Header,Fsd,B,M,L,N)

if nargin <4
	B=[5 6 8 10 15 20 40 80 160 200];
end
if nargin <5
	M=25;
end
if nargin <6
	L=10;
end
if nargin <7
	N=1000;
end

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
Raster=[];
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

			%Finding Pre For Corresponding Units
			UnitsArray=[];
			for l=1:length(Units)
				if ~strcmp(Units(l),'+')
					%Loading Pre File
					PreFile=[SpetFile '_u' Units(l) '_Pre' int2str(Fsd) 'Hz'];
					f=['load ' PreFile];
					eval(f);

					%Generating Compund Raster
					if isempty(Raster)
						Raster=RASTER; 
					else
						Raster=Raster+RASTER;
					end

					%Compound Unit umbers
					UnitsArray=[UnitsArray Units(l)];
				end
			end

			%Computing Enthropy - removes first 25 trials
			NN=size(Raster,1);
			Raster=Raster(25:NN,:);
			[HWordt,HSpiket,HSect,HWord,HSpike,HSec,...
			Rate]=infextrapolateb(RASTER,taxis,Fsd,B,M,L)

			%Saving To File
			f=['save ' SpetFile '_u' UnitsArray '_InfRas',...
			'Fsd' int2str(Fsd) 'Hz_Strong HWordt HSpiket',...
			' HSect HWord HSpike HSec B Fsd Rate '];
			if ~strcmp(version,'4.2c')
				f=[f ' -v4'];
			end
			eval(f);	
			disp(f);	

			%Re-Initializing Ratser and Clearing Variables
			Raster=[];
			clear RATSER RASTERs PSTH PSTHs taxis

		end

	end

end

