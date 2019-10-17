%
%function [dBType,SPLType,RateMax,Rate60dB,RateLin,MaxdB,FileList,SpikeType]=batchdbsplstat(BatchFile,Header,T,p)
%
%	FILE NAME       : BATCH DB SPL STAT
%	DESCRIPTION     : Uses a batch file to find contrast tuned units
%			  and reponse ratio for Lin vs dB modulations. Derived
%			  directly from dB vs. SPL response curve
%
%	BatchFile	: Batch file containing unit numbers
%	Header		: Experiment Header 
%	T		: Time at each intensity and contrast condition
%	p		: Confidence probability
%
%RETURNED VARIABLES
%
%	dBType		: Array of contrast response types
%			  1 - Increasing Monotonic 
%			  2 - Decreasing Monotonic 
%			  3 - Non monotonic - Tuned
%			  4 - Flat
%
%	SPLType		: Array of Intensity response types
%			  1 - Monotonic 
%			  2 - Non monotonic
%	RateMax		: Maximum Rate
%	Rate60		: Rate for 60 dB contrast 
%	RateLin		: Rate for Lin contrast
%	MaxdB		: Maximum Contrast Location
%			  1==Lin , 2==15 dB , 3==30 dB, 4==45 dB, 5==60 dB
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
function [dBType,SPLType,RateMax,Rate60dB,RateLin,MaxdB,FileList,SpikeType]=batchdbsplstat(BatchFile,Header,T,p)

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

			%Finding Maximum, 60dB, and Lin Rate 
			[i,j]=find(Rate==max(max(Rate)));
			if length(i)>1
				i=i(1);
				j=j(1);
			end
			RateMax(count)=Rate(i,j);
			Rate60dB(count)=Rate(i,5);
			RateLin(count)=Rate(i,1);
			RateMaxSPL(count)=Rate(1,j);	
			RateMinSPL(count)=Rate(5,j);	
	
			%Finding Maximum dB
			MaxdB(count)=j;

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

%Finding Contrast and Intensity Tuning Types
for k=1:length(RateMax)
	
	%If Maximum Rate Occurs at 60dB
	if RateMax(k)==Rate60dB(k)

		%Testing significance
		[p1,p2]=poisratestat(Rate60dB(k),RateLin(k),T,p);
	
		%Monotonic Response Curve
		if p1<p & p2<p
			dBType(k)=1;
		else
		%Flat Response Curve
			dBType(k)=4;
		end
		
	end

	%If Maximum Rate Occurs at Lin
	if RateMax(k)==RateLin(k)

		%Testing significance
		[p1,p2]=poisratestat(Rate60dB(k),RateLin(k),T,p);

		%Decreasing Monotonic Response Curve
		if p1<p & p2<p
			dBType(k)=2;
		else
		%Flat Response Curve
			dBType(k)=4;
		end

	end

	%If Maximum Rate does not occurs at Lin or 60dB
	if RateMax(k)~=Rate60dB(k) & RateMax(k)~=RateLin(k)

		%Testing significance
		[p1,p2]=poisratestat(RateMax(k),RateLin(k),T,p);
		[p3,p4]=poisratestat(RateMax(k),Rate60dB(k),T,p);

		%Tuned Response Curve	
		if p1<p & p2<p & p3<p & p4<p
			dBType(k)=3;

		%Increasing Monotonic Response Curve
		elseif p1<p & p2<p 
			dBType(k)=1;

		%Decreasing Monotonic Response Curve
		elseif p3<p & p4<p
			dBType(k)=2;

		%Flat Response curve
		else
			dBType(k)=4;

		end

	end	

	%SPL Response Type - 1=Monotonic , 2=Non-Monotonic
	%If Maximum Rate does not occurs at Min or Max SPL 
	if RateMax(k)~=RateMaxSPL(k) 

		%Testing significance
		[p1,p2]=poisratestat(RateMax(k),RateMaxSPL(k),T,p);

		%Tuned Response Curve	
		if  p1<p & p2<p
			SPLType(k)=2;
		else
			SPLType(k)=3;
		end
	else
		SPLType(k)=1;
	end	


end
