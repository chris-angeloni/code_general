%
%function [SI,SInoLin,FileList,SpikeType]=batchdbsplind(BatchFile,Header,T,p)
%
%	FILE NAME       : BATCH DB SPL IND
%	DESCRIPTION     : Computes the separability index for the contrast-
%			  intensity response curves
%
%	BatchFile	: Batch file containing unit numbers
%	Header		: Experiment Header 
%	T		: Time at each intensity and contrast condition
%	p		: Significance probability - makes sure that the
%			  maximum rate is statistically different than zero
%
%RETURNED VARIABLES
%
%	SI		: Separability Index
%	SInoLin		: Separability Index no Linear Contrast
%	FileList	: Array containing corresponding filenames
%	SpikeType	: Single or Multi Unit
%			  Single Unit =='S'
%			  Multi  Unit =='M'
%
%Example Batch File
%
%dBSPLFILE	SPIKES
%-----------------------------------------------------------------------
%
%t2_f36_ch2	0 
%t2_f36_ch2	1
%mt3_f07_ch1	0
%mt3_f17_ch1	0+2
%t3_f17_ch1	1
%
function [SI,SInoLin,FileList,SpikeType]=batchdbsplind(BatchFile,Header,T,p)

%Preliminaries
more off

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
fclose(fid);
List=[10 List 10];
returnindex=find(List==10);
DataList=zeros(length(returnindex)-1,100);
for k=1:length(returnindex)-1

	CurrentList=setstr(List(returnindex(k)+1:returnindex(k+1)-1));
	DataList(k,1:length(CurrentList))=CurrentList;

end
DataList=setstr(DataList);

%Finding Corresponding Files and Relevant Rates
Tab=setstr(9);
count=0;
LL=32;
for k=1:length(returnindex)-1

	%Initializing List Array
	List=setstr(32*ones(1,8*LL));

	%If Data List contains a proper data sequence
	if strcmp(DataList(k,1),'t') | strcmp(DataList(k,1:2),'mt')

		%Finding Tape Number, File Number, Unit Numbers, Sound Channel
		if strcmp(DataList(k,1),'t')
			UnitType='S';
		else
			UnitType='M';
		end
		tabindex=findstr(DataList(k,:),Tab);
		if strcmp(DataList(k,1),'t')
			Tape=DataList(k,1:tabindex(1)-1);
		else
			Tape=DataList(k,2:tabindex(1)-1);
		end
		Units=DataList(k,tabindex(1)+1:tabindex(2)-1);

		%Finding Rate Curves for Units
		for l=1:length(Units)

			if ~strcmp(setstr(Units(l)),'+') & ~strcmp(setstr(Units(l)),'-')

				%Loading dB vs. SPL File
				file=[Header Tape '_u' Units(l) '_dBSPL.mat'];
				f=['load ' file];
				eval(f);

				%Initializing if necessary
				if l==1
					MeandBSPL=zeros(size(Mean));
				end

				%Finding Compound dB vs. SPL Curve
				MeandBSPL=MeandBSPL+Mean;

				%Adding File List
				List((l-1)*LL+(1:length(file)))=file;

			end
		end

		%Finding Overall Rate Curve from Spike Count
		Rate=MeandBSPL*Fsd;

		%Testing significance of Max Rate Relative to Zero
                [p10,p20]=poisratestat(0,max(max(Rate)),T,p);  

 
                %If Max Rate is Significant Add to Data Array
                if p10<p & p20<p
     	
			%Incrementing Counter
			count=count+1;

			%Spike Type
			SpikeType(count)=UnitType;

			%Finding Separability Index 
			[U,S,V]   = svd(Rate);
			SI(count) = S(1,1).^2 /sum(sum(S.^2)) ;
			[U,S,V]   = svd(Rate(:,2:5));
			SInoLin(count) = S(1,1).^2 /sum(sum(S.^2)) ;

			%Adding file to FileList
			FileList(count,:)=List;

			%Plotting Rate Curves
			dBA=min(dBAxis):3:max(dBAxis);
			SPLA=flipud((min(SPLAxis):3:max(SPLAxis))');
			M=interp2(dBAxis,SPLAxis,MeandBSPL,dBA,SPLA);
			pcolor(dBA,SPLA,M/.1),colormap jet,colorbar
			pause(0)
		end

	end
end
