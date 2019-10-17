%
%function [Hspk60,HspkN60,HspkLin,HspkNLin,Hspk30,HspkN30]=infbatch(BatchFile,Header,Fsd,B)
%
%
%       FILE NAME       : PLOT INF
%       DESCRIPTION     : Plots the Mutual Information as a Function of
%			  Stimulus Contrast
%
%	BatchFile	: Experiment Batch File
%	Header		: Experiment Header
%	Fsd		: Desired sampling rate for Enthropy Computation
%	B		: Number of Bits Per Word
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
function [Hspk60,HspkN60,HspkLin,HspkNLin,Hspk30,HspkN30]=infbatch(BatchFile,Header,Fsd,B)

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

%Initializing Arrays
Hspk60=-9999*ones(1,500);
Hsec60=-9999*ones(1,500);
Hword60=-9999*ones(1,500);
Rate60=-9999*ones(1,500);
Hspk30=-9999*ones(1,500);
Hsec30=-9999*ones(1,500);
Hword30=-9999*ones(1,500);
Rate30=-9999*ones(1,500);
HspkLin=-9999*ones(1,500);
HsecLin=-9999*ones(1,500);
HwordLin=-9999*ones(1,500);
RateLin=-9999*ones(1,500);

HspkN60=-9999*ones(1,500);
HsecN60=-9999*ones(1,500);
HwordN60=-9999*ones(1,500);
RateN60=-9999*ones(1,500);
HspkN30=-9999*ones(1,500);
HsecN30=-9999*ones(1,500);
HwordN30=-9999*ones(1,500);
RateN30=-9999*ones(1,500);
HspkNLin=-9999*ones(1,500);
HsecNLin=-9999*ones(1,500);
HwordNLin=-9999*ones(1,500);
RateNLin=-9999*ones(1,500);

UnitType=-9999*ones(1,500);





%Finding Corresponding Files and Computing Enthropy
Raster=[];
UnitNumber=1;
for k=1:length(returnindex)-1

	if strcmp(DataList(k,1),'-')

		count=1;
		while ~strcmp(DataList(k+count,1),'-') & (strcmp(DataList(k+count,1),'t') | strcmp(DataList(k+count,1),'m')) 
	
			%Finding File Number, Tape Number, Unit Number, and Type
			tabindex=findstr(DataList(k+count,:),Tab);
			if strcmp(DataList(k+count,1),'t')
				Tape=DataList(k+count,1:tabindex(1)-1);
			else
				Tape=DataList(k+count,2:tabindex(1)-1);
			end
			Units=DataList(k+count,tabindex(2)+1:tabindex(3)-1);
			Contrast=DataList(k+count,tabindex(5)+1:tabindex(6)-1);
			Type=DataList(k+count,tabindex(7)+1:tabindex(8)-1);

			%Spet File Name and Trig File Name
			SpetFile=[Header Tape ];
			TrigFile=[Header Tape(1:length(Tape)-3) 'Trig'];

			%Finding Units Array
			UnitsArray=[];
			for l=1:length(Units)
				if ~strcmp(Units(l),'+')
					%Compound Unit umbers
					UnitsArray=[UnitsArray Units(l)];
                                end
			end
			

			if strcmp(Type,'PRE')

				%Loading Information File
				f=['load ' SpetFile '_u' UnitsArray ,...
				'_InfRasB' int2str(B) 'Fsd' int2str(Fsd) 'Hz'];
				disp(f)
				eval(f)

				if strcmp(Contrast,'60')
					HspkN60(UnitNumber)=mean(HSpikeN);
					HsecN60(UnitNumber)=mean(HSecN);
					HwordN60(UnitNumber)=mean(HWordN);
					RateN60(UnitNumber)=mean(RateN);
				elseif strcmp(Contrast,'30')
					HspkN30(UnitNumber)=mean(HSpikeN);
					HsecN30(UnitNumber)=mean(HSecN);
					HwordN30(UnitNumber)=mean(HWordN);
					RateN30(UnitNumber)=mean(RateN);
				elseif strcmp(Contrast,'Lin')
					HspkNLin(UnitNumber)=mean(HSpikeN);
					HsecNLin(UnitNumber)=mean(HSecN);
					HwordNLin(UnitNumber)=mean(HWordN);
					RateNLin(UnitNumber)=mean(RateN);
				end

				%Unit Type
				if strcmp(DataList(k+count,1),'t')
					UnitType(UnitNumber)=1;
				elseif strcmp(DataList(k+count,1),'m')
					UnitType(UnitNumber)=0;
				end

			elseif strcmp(Type,'STRF2')

				%Loading Information File
				f=['load ' SpetFile '_u' UnitsArray ,...
				'_InfB' int2str(B) 'Fsd' int2str(Fsd) 'Hz'];
				eval(f);
				disp(f)

				if strcmp(Contrast,'60')
					Hspk60(UnitNumber)=mean(HSpike);
					Hsec60(UnitNumber)=mean(HSec);
					Hword60(UnitNumber)=mean(HWord);
					Rate60(UnitNumber)=Rate;
				elseif strcmp(Contrast,'30')
					Hspk30(UnitNumber)=mean(HSpike);
					Hsec30(UnitNumber)=mean(HSec);
					Hword30(UnitNumber)=mean(HWord);
					Rate30(UnitNumber)=Rate;
				elseif strcmp(Contrast,'Lin')
					HspkLin(UnitNumber)=mean(HSpike);
					HsecLin(UnitNumber)=mean(HSec);
					HwordLin(UnitNumber)=mean(HWord);
					RateLin(UnitNumber)=Rate;
				end

				%Unit Type
				if strcmp(DataList(k+count,1),'t')
					UnitType(UnitNumber)=1;
				elseif strcmp(DataList(k+count,1),'m')
					UnitType(UnitNumber)=0;
				end

			end


			%Updating Counter
			count=count+1;
		end

		%Incrementing Unit Number
		UnitNumber=UnitNumber+1
pause
	end


end



i=find(Hspk60~=-9999 & HspkLin~=-9999 & UnitType==1);
%i=find(Hspk30~=-9999 & HspkLin~=-9999 & UnitType==1 & Rate>5 & HspkLin>HspkNLin)
%i=find(Hspk60~=-9999 & HspkLin~=-9999 & 2*(Hspk60-HspkN60)./(Hspk60+HspkN60)<0.1& 2*(HspkLin-HspkNLin)./(HspkLin+HspkNLin)<0.1 )


figure

plot(HsecLin-HsecNLin,Hsec60-HsecN60,'ro')
%plot(Hsec60(i)./Hspk60(i),HsecN60(i)./HspkN60(i),'ro')
%hold on
figure
plot(HsecLin(i),Hsec60(i),'g+')
%plot(HsecLin(i)./HspkLin(i),HsecNLin(i)./HspkNLin(i),'g+')



