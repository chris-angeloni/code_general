%
%function [Rate,dRMSRate,dMaxRate,STRFnorm,Nspike,RR,SpikeType]=batchdbcontstat(BatchFile,Header)
%
%	FILE NAME       : BATCH DB CONT STAT
%	DESCRIPTION     : Uses a batch file to find contrast tuned unit
%			  properties and differential response properties 
%			  for Lin vs dB modulations. Derived directly from 
%			  STRF File
%
%	BatchFile	: Batch file containing unit numbers
%	Header		: Experiment Header 
%
%RETURNED VARIABLES
%
%	Rate		: Spike Rate Matrix
%			  (Column 1 = Lin, Column 2 = 30dB, Column 3 = 60 dB) 
%	dRMSRate	: Differential spike rate from STRF
%			  (Column 1 = Lin, Column 2 = 30dB, Column 3 = 60 dB) 
%	dMaxRate	: Peak to Peak differential rate matrix
%			  (Column 1 = Lin, Column 2 = 30dB, Column 3 = 60 dB) 
%	RMSnorm		: STRF norm (STD obtained from significant RF) matrix
%	Nspike		: Spike Count Matrix
%			  (Column 1 = Lin, Column 2 = 30dB, Column 3 = 60 dB) 
%	RR		: STRF Correlation Coefficient Matrix
%			  Column 1 = Lin vs 30
%			  Column 2 = Lin vs 60
%			  Column 3 = 30 vs 60
%	SpikeType	: Single or Multi Unit
%			  Single Unit =='S'
%			  Multi  Unit =='M'
%
%Example Batch File
%
%FILELin	SPIKES	FILE30dB	SPIKES	FILE60dB	SPIKE   TYPE
%-----------------------------------------------------------------------
%
%t2_f36_ch2	0	t2_f39_ch2	---
%t2_f36_ch2	1	t2_f39_ch2	0
%t3_f07_ch1	0	t3_f11_ch1	---
%t3_f17_ch1	0+2	t3_f18_ch1	0
%t3_f17_ch1	1	t3_f18_ch1	0+1
%
function [Rate,dRMSRate,dMaxRate,STRFnorm,Nspike,RR,SpikeType]=batchdbcontstat(BatchFile,Header)

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

	CurrentList=setstr(List(returnindex(k)+1:returnindex(k+1)));
	DataList(k,1:length(CurrentList))=CurrentList;

end

%Finding Corresponding Files and Relevant Rates
Tab=setstr(9);
Return=setstr(10);
count=0;
LL=32;
DataList=setstr(DataList);
for k=1:length(returnindex)-1

	%Initializing List Array
	List=setstr(32*ones(1,8*LL));

	%If Data List contains a proper data sequence
	if strcmp(DataList(k,1),'t') | strcmp(DataList(k,1:2),'mt')

		%File Counter
		count=count+1;

		%Spike Type
		if strcmp(DataList(k,1),'t')
			SpikeType(count)='S';
		else
			SpikeType(count)='M';
		end

		%Finding Tape Number, File Number, Unit Numbers, Sound Channel
		tabindex=findstr(DataList(k,:),Tab);
		returnindex=findstr(DataList(k,:),Return);

		%Lin Contrast
		if strcmp(DataList(k,1),'t') 
			TapeLin=DataList(k,1:tabindex(1)-1);
		else
			TapeLin=DataList(k,2:tabindex(1)-1);
		end
		UnitsLin=DataList(k,tabindex(1)+1:tabindex(2)-1);

		%30 dB Contrast
		Tape30=DataList(k,tabindex(2)+1:tabindex(3)-1);
		Units30=DataList(k,tabindex(3)+1:tabindex(4)-1);

		%60 dB Contrast
		if isempty(Tape30)		
			Tape60=DataList(k,tabindex(5)+1:tabindex(6)-1);
			Units60=DataList(k,tabindex(6)+1:tabindex(7)-1);
			SoundCh=DataList(k,tabindex(7)+1:returnindex-1);
		else
			Tape60=DataList(k,tabindex(4)+1:tabindex(5)-1);
			Units60=DataList(k,tabindex(5)+1:tabindex(6)-1);
			if isempty(Tape60)
				SoundCh=DataList(k,tabindex(7)+1:returnindex-1);
			else
				SoundCh=DataList(k,tabindex(6)+1:returnindex-1);
			end
		end

		%Finding STRF and Mean Rate for Lin Contrast
		WoLin=-9999;
		NoLin=-9999;
		STRFLin=-9999;
		for l=1:length(UnitsLin)

			if ~strcmp(UnitsLin(l),'+') & ~strcmp(UnitsLin(l),'-')

				%Loading Lin File
				fileLin=[Header TapeLin '_u' UnitsLin(l) '_Lin.mat'];
				f=['load ' fileLin];
				eval(f);
disp(f)
				%Generating Compund Rate
				if l==1
					WoLin=Wo1;
					NoLin=No1;
				else
					WoLin=WoLin+Wo1;
					NoLin=NoLin+No1;
				end

				%Generating Compund STRF
				if l==1	%Need to Initialize
					%Choosing STRF from Apropriate Channel
					if strcmp(SoundCh,'1')
						STRFLin=STRF1s*sqrt(PP);
					elseif strcmp(SoundCh,'2')
						STRFLin=STRF2s*sqrt(PP);
					elseif strcmp(SoundCh,'1+2')
						STRFLin=[STRF1s STRF2s]*sqrt(PP);
					end
				else	%Add to Compund STRF
					%Choosing STRF from Apropriate Channel
					if strcmp(SoundCh,'1')
						STRFLin=STRFLin+STRF1s*sqrt(PP);
					elseif strcmp(SoundCh,'2')
						STRFLin=STRFLin+STRF2s*sqrt(PP);
					elseif strcmp(SoundCh,'1+2')
						STRFLin=STRFLin+[STRF1s STRF2s]*sqrt(PP);
					end
				end
			end
		end	

		%Finding STRF and Mean Rate for 30dB Contrast
		Wo30=-9999;
		No30=-9999;
		STRF30=-9999;
		for l=1:length(Units30)

			if ~strcmp(Units30(l),'+') & ~strcmp(Units30(l),'-')

				%Loading 30dB File
				file30=[Header Tape30 '_u' Units30(l) '_dB.mat'];
				f=['load ' file30];
				eval(f);
disp(f)
				%Generating Compund Rate
				if l==1
					Wo30=Wo1;
					No30=No1;
				else
					Wo30=Wo30+Wo1;
					No30=No30+No1;
				end

				%Generating Compund STRF
				if l==1	%Need to Initialize
					%Choosing STRF from Apropriate Channel
					if strcmp(SoundCh,'1')
						STRF30=STRF1s*sqrt(PP);
					elseif strcmp(SoundCh,'2')
						STRF30=STRF2s*sqrt(PP);
					elseif strcmp(SoundCh,'1+2')
						STRF30=[STRF1s STRF2s]*sqrt(PP);
					end
				else	%Add to Compund STRF
					%Choosing STRF from Apropriate Channel
					if strcmp(SoundCh,'1')
						STRF30=STRF30+STRF1s*sqrt(PP);
					elseif strcmp(SoundCh,'2')
						STRF30=STRF30+STRF2s*sqrt(PP);
					elseif strcmp(SoundCh,'1+2')
						STRF30=STRF30+[STRF1s STRF2s]*sqrt(PP);
					end
				end
			end
		end	

		%Finding STRF and Mean Rate for 60dB Contrast
		Wo60=-9999;
		No60=-9999;
		STRF60=-9999;
		for l=1:length(Units60)

			if ~strcmp(Units60(l),'+') & ~strcmp(Units60(l),'-')

				%Loading 30dB File
				file60=[Header Tape60 '_u' Units60(l) '_dB.mat'];
				f=['load ' file60];
				eval(f);
disp(f)
				%Generating Compund Rate
				if l==1
					Wo60=Wo1;
					No60=No1;
				else
					Wo60=Wo60+Wo1;
					No60=No60+No1;
				end

				%Generating Compund STRF
				if l==1	%Need to Initialize
					%Choosing STRF from Apropriate Channel
					if strcmp(SoundCh,'1')
						STRF60=STRF1s*sqrt(PP);
					elseif strcmp(SoundCh,'2')
						STRF60=STRF2s*sqrt(PP);
					elseif strcmp(SoundCh,'1+2')
						STRF60=[STRF1s STRF2s]*sqrt(PP);
					end
				else	%Add to Compund STRF
					%Choosing STRF from Apropriate Channel
					if strcmp(SoundCh,'1')
						STRF60=STRF60+STRF1s*sqrt(PP);
					elseif strcmp(SoundCh,'2')
						STRF60=STRF60+STRF2s*sqrt(PP);
					elseif strcmp(SoundCh,'1+2')
						STRF60=STRF60+[STRF1s STRF2s]*sqrt(PP);
					end
				end
			end
		end	


		%Finding Mean Rate, Differential Rate, and RMS value of STRF
		if STRFLin~=-9999
%			index=find(STRFLin~=0);
%			dRMSLin(count)=sqrt(mean(STRFLin(index).^2));
			Fst=1/(taxis(2)-taxis(1));
			N2=size(STRFLin,2)/2;
			STRFnormLin(count)=strfnorm(STRFLin(:,1:N2),STRFLin(:,N2+1:2*N2),1);
			dRMSLin(count)=strfstd(STRFLin(:,1:N2),STRFLin(:,N2+1:2*N2),1,Fst);
			dRLin(count)=abs(max(max(STRFLin))-min(min(STRFLin)));
			RLin(count)=WoLin;
			NspikeLin(count)=NoLin;
		else
			STRFnormLin(count)=-9999;
			dRMSLin(count)=-9999;
			dRLin(count)=-9999;
			RLin(count)=-9999;
			NspikeLin(count)=-9999;
		end
		if STRF30~=-9999
%			index=find(STRF30~=0);
%			dRMS30(count)=sqrt(mean(STRF30(index).^2));
N2=size(STRF30,2)/2;
			STRFnorm30(count)=strfnorm(STRF30(:,1:N2),STRF30(:,N2+1:2*N2),1);
dRMS30(count)=strfstd(STRF30(:,1:N2),STRF30(:,N2+1:2*N2),1,Fst);
			dR30(count)=abs(max(max(STRF30))-min(min(STRF30)));
			R30(count)=Wo30;
			Nspike30(count)=No30;
		else
			STRFnorm30(count)=-9999;
			dRMS30(count)=-9999;
			dR30(count)=-9999;
			R30(count)=-9999;
			Nspike30(count)=-9999;
		end
		if STRF60~=-9999
%			index=find(STRF60~=0);
%			dRMS60(count)=sqrt(mean(STRF60(index).^2));
N2=size(STRF60,2)/2;
			STRFnorm60(count)=strfnorm(STRF60(:,1:N2),STRF60(:,N2+1:2*N2),1);
dRMS60(count)=strfstd(STRF60(:,1:N2),STRF60(:,N2+1:2*N2),1,Fst);
			dR60(count)=abs(max(max(STRF60))-min(min(STRF60)));
			R60(count)=Wo60;
			Nspike60(count)=No60;
		else
			STRFnorm60(count)=-9999;
			dRMS60(count)=-9999;
			dR60(count)=-9999;
			R60(count)=-9999;
			Nspike60(count)=-9999;
		end
pause(0)

	%Finding STRF corrcoef 
	if STRFLin~=-9999 & STRF30~=-9999
		RR(count,1)=strfcorrcoef(STRFLin,STRF30);
	else
		RR(count,1)=-9999;
	end
	if STRFLin~=-9999 & STRF60~=-9999
		RR(count,2)=strfcorrcoef(STRFLin,STRF60);
	else
		RR(count,2)=-9999;
	end
	if STRF60~=-9999 & STRF30~=-9999
		RR(count,3)=strfcorrcoef(STRF60,STRF30);
	else
		RR(count,3)=-9999;
	end

	end
end

%Renaming Output Data
Rate=[RLin' R30' R60'];
dRMSRate=[dRMSLin' dRMS30' dRMS60'];
dMaxRate=[dRLin' dR30' dR60'];
STRFnorm=[STRFnormLin' STRFnorm30' STRFnorm60'];
Nspike=[NspikeLin' Nspike30' Nspike60'];
SpikeType=SpikeType';

