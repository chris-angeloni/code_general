%
%function [jitterLin,jitter30,jitter60,pLin,p30,p60,lLin,l30,l60]=batchcorrjitter(BatchFile,Header)
%
%
%       FILE NAME       : BATCH CORR JITTER
%       DESCRIPTION     : Estimates the jitter width (std) and the trial to 
%			  trial reproducibility probability (p) using the 
%			  response raster cross trial correlation function 
%			  (RASTERCORR) by fitting to a gaussian correlation
%			  model (CORRMODEL and CORRMODELFIT)
%
%	BatchFile	: Experiment Batch File
%	Header		: Experiment Header
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
function [jitterLin,jitter30,jitter60,pLin,p30,p60,lLin,l30,l60]=batchcorrjitter(BatchFile,Header)

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
jitterLin=-9999*ones(1,500);
jitter30=-9999*ones(1,500);
jitter60=-9999*ones(1,500);

pLin=-9999*ones(1,500);
p30=-9999*ones(1,500);
p60=-9999*ones(1,500);

lLin=-9999*ones(1,500);
l30=-9999*ones(1,500);
l60=-9999*ones(1,500);

UnitType=-9999*ones(1,500);

%Finding Corresponding Files and Computing Correlation Width/Reproducibility p 
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
				'_RasCorrAvg'];
				disp(f)
				eval(f)

				if strcmp(Contrast,'60')
					N=(length(Ravg)-1)/2;
					Tau=(-N:N)/Fsd;
					[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfitstd(Ravg,Tau);
[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfit(Ravg,Tau);
					jitter60(UnitNumber)=sigma;	
					p60(UnitNumber)=p;
%					p60(UnitNumber)=Rpeak-Rmean;
					l60(UnitNumber)=lambda;

				elseif strcmp(Contrast,'30')
					N=(length(Ravg)-1)/2;
					Tau=(-N:N)/Fsd;
					[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfitstd(Ravg,Tau);
[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfit(Ravg,Tau);
					jitter30(UnitNumber)=sigma;	
					p30(UnitNumber)=p;	
%					p30(UnitNumber)=Rpeak-Rmean;	
					l30(UnitNumber)=lambda;
				elseif strcmp(Contrast,'Lin')
					N=(length(Ravg)-1)/2;
					Tau=(-N:N)/Fsd;
					[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfitstd(Ravg,Tau);
[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfit(Ravg,Tau);
					jitterLin(UnitNumber)=sigma;	
					pLin(UnitNumber)=p;	
%					pLin(UnitNumber)=Rpeak-Rmean;	
					lLin(UnitNumber)=lambda;
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

	end


end

