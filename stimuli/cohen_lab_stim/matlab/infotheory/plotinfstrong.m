%
%function [H]=plotinfstrong(BatchFile,Header,Fsd,LL)
%
%       FILE NAME       : PLOT INF
%       DESCRIPTION     : Plots the Mutual Information as a Function of
%			  Stimulus Contrast
%
%	BatchFile	: Experiment Batch File
%	Header		: Experiment Header
%	Fsd		: Desired sampling rate for Enthropy Computation
%	LL		: Number of Bootstraps
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
function [H]=plotinfstrong(BatchFile,Header,Fsd,LL)

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
H=struct('Ispike60',-9999*ones(1,500),'Ispike30',-9999*ones(1,500),'IspikeLin',-9999*ones(1,500),'Ispike60std',-9999*ones(1,500),'Ispike30std',-9999*ones(1,500),'IspikeLinstd',-9999*ones(1,500),'rate60',-9999*ones(1,500),'rate30',-9999*ones(1,500),'rateLin',-9999*ones(1,500),'unittype',-9999*ones(1,500));

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
				'_InfRasFsd' int2str(Fsd) 'Hz_Strong'];
				eval(f)

			%Bootstraping to Determine Mean +- STD
			[HStrong]=infstrongbootstrap(B,HSpike,HSpiket,LL,5);

				if strcmp(Contrast,'60')
					H.Ispike60(UnitNumber)=HStrong(1);
					H.Ispike60std(UnitNumber)=HStrong(2);
					H.rate60(UnitNumber)=mean(Rate);
				elseif strcmp(Contrast,'30')
					H.Ispike30(UnitNumber)=HStrong(1);
					H.Ispike30std(UnitNumber)=HStrong(2);
					H.rate30(UnitNumber)=mean(Rate);
				elseif strcmp(Contrast,'Lin')
					H.IspikeLin(UnitNumber)=HStrong(1);
					H.IspikeLinstd(UnitNumber)=HStrong(2);
					H.rateLin(UnitNumber)=mean(Rate);
				end

				%Unit Type
				if strcmp(DataList(k+count,1),'t')
					H.unittype(UnitNumber)=1;
				elseif strcmp(DataList(k+count,1),'m')
					H.unittype(UnitNumber)=0;
				end

			end

			%Updating Counter
			count=count+1;
		end

		%Incrementing Unit Number
		UnitNumber=UnitNumber+1

	end


end

%i=find(Hspk60~=-9999 & HspkLin~=-9999 & UnitType==1)
%i=find(Hspk30~=-9999 & HspkLin~=-9999 & UnitType==1 & Rate>5 & HspkLin>HspkNLin)
%i=find(Hspk60~=-9999 & HspkLin~=-9999 & 2*(Hspk60-HspkN60)./(Hspk60+HspkN60)<0.1& 2*(HspkLin-HspkNLin)./(HspkLin+HspkNLin)<0.1 )
%i=find(Hspk60~=-9999 & HspkLin~=-9999 )
%plot(HspkLin(i)-HspkNLin(i),Hspk30(i)-HspkN30(i),'ro')
%plot(HspkLin(i),HspkNLin(i),'ro')

%plot(RateLin(i),Rate60(i),'ro')
%plot(Hspk60(i),HspkLin(i),'ro')
%plot(Hsec60(i),HsecLin(i),'ro')

figure
subplot(221)
%i=find(H.Ispike30~=-9999 & H.IspikeLin~=-9999 & H.rateLin>5 & H.rate30>5)
%plot((Rate30(i)-RateLin(i))./RateLin(i)*100,(H30(i)-HLin(i))./HLin(i)*100,'b^')
%hist((H.Ispike30(i)-H.IspikeLin(i))./H.IspikeLin(i)*100,-20:10:50)
%mean((H.Ispike30(i)-H.IspikeLin(i))./H.IspikeLin(i)*100)
%[H,SIG]=ttest((H.Ispike30(i)-H.IspikeLin(i))./H.IspikeLin(i)*100,0,0.01,1)
axis([-20 50 0 5 ])

subplot(222)
%i=find(H.Ispike60~=-9999 & H.IspikeLin~=-9999 & H.rateLin>5 & H.rate60>5)
%plot((Rate60(i)-RateLin(i))./RateLin(i)*100,(H60(i)-HLin(i))./HLin(i)*100,'ro')
%hist((H.Ispike60(i)-H.IspikeLin(i))./H.IspikeLin(i)*100,-10:20:120)
%mean((H.Ispike60(i)-H.IspikeLin(i))./H.IspikeLin(i)*100)
%[H,SIG]=ttest((H60(i)-HLin(i))./HLin(i)*100,0,0.01,1)


