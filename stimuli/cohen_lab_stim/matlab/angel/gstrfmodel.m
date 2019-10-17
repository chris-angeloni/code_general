%function [STRFm,STRFam,STRFbm,STRFcm,x0,w,sf0,spectrop,t0,c,tf0,q,k,belta,SIs,SIt,SI,Errs,alpha_d,N]=gstrfmodel(STRF,taxis,faxis,PP,Tresh,TreshType,Method,display);
%
% Function                     fitting STRF by Gabor functions
% Input     
%              STRF            measured STRF
%              taxis           time axis
%              faxis           frequency axis
%              PP              Power level
%              Tresh           the level of noise or Threshold/3.1 that comes from wstrfstat.m
%              TreshType       if Tresh is the level of noise determined by svd, TreshType='svd'
%                               otherwise, TreshType='nsvd'; 
%              Method          'svd'--- fitting singular vector
%                              'nsvd' --- fitting spectral profile and temporal profile(across sections through STRF)
%                               default is 'nsvd'
%              display         'y'  display the result
%                     	       'n'  do not show figures
%                     		default is 'y'
%
% Output
%              STRFm           the fitted STRF
%              STRFam          the fitted STRF coming from the first component
%              STRFbm          the fitted STRF coming from the second component
%	       STRFcm          the fitted STRF coming from the third component
%              x0              center frequency
%              w               bandwidth of the spectral evenlope
%              sf0             the best ripple density
%              spectrop        spectral phase
%              t0              peak latency
%              c               response duration
%              tf0             the best modulation frequency
%              belta           the skewness of temporal evenlope.
%              k               the absolute peak value of STRFm
%              SIs             similarity index between fitted and measured spectral profiles
%              SIt             similarity index between fitted and measured temporal profiles
%              SI              similarity index between STRFm and STRFs
%              Errs            the error between STRF and STRFm
%              alpha_d         separability index
%                              alpha_d(1)=(S(1,1)^2-S(2,2)^2-S(3,3)^2)/(S(1,1)^2+S(2,2)^2+S(3,3)^2);
%                              alpha_d(2)=(S(1,1)-S(2,2)-S(3,3))/(S(1,1)+S(2,2)+S(3,3)); 
%              N               how many components are used in this model
%
% Definition
%       a, b and c correspond to the first, second and third component,respectively.
%       E* expresses energy
%       *m  describes the fitted result
%
% ANQI QIU
% 05/07/2002                             


function [STRFm,STRFam,STRFbm,STRFcm,x0,w,sf0,spectrop,t0,c,tf0,q,k,belta,SIs,SIt,SI,Errs,alpha_d,N]=gstrfmodel(STRF,taxis,faxis,PP,Tresh,TreshType,Method,display);   

if nargin<7
	Method='nsvd';
end;
if nargin<8
	display='y';
end;



% initial returned parameters
STRFm=zeros(size(STRF));
STRFam=zeros(size(STRF));
STRFbm=zeros(size(STRF));
STRFcm=zeros(size(STRF));
x0=0;
w=0;
sf0=0;
spectrop=0;
t0=0;
c=0;
tf0=0;
q=0;
k=0;
belta=0;
SIs=0;
SIt=0;
SI=0;
Errs=1;
alpha_d=0;
N=0;

%zeros STRF
STRF0=zeros(size(STRF));

%temporal sampling rate
Fst=1/(taxis(2)-taxis(1));

%time axis is shifted from the origin
taxis=taxis+abs(taxis(1));

%frequency in unit of octave
xaxis=log2(faxis/500);

if STRF==0
	return;
end;

%singular value decomposition
try
	[U,S,V]=svd(STRF);
catch
	return;
end;

S1=zeros(size(STRF));
S2=zeros(size(STRF));
S3=zeros(size(STRF));
S1(1,1)=S(1,1);
S2(2,2)=S(2,2);
S3(3,3)=S(3,3);
STRFa=U*S1*V';
STRFb=U*S2*V';
STRFc=U*S3*V';

%energy of each components
Ea=strfstd(STRFa,STRF0,PP,Fst);
Eb=strfstd(STRFb,STRF0,PP,Fst); 
Ec=strfstd(STRFc,STRF0,PP,Fst); 

%the number of components into GSTRF model
if strcmp(TreshType,'svd')
	if S(3,3)>Tresh
        	N=3;
        else  if S(2,2)>Tresh
			N=2;
	      else   if S(1,1)>Tresh
			N=1;
 		     else
			N=0;
			return;
		     end;		
	      end;
        end;
else
	if Ec>Tresh
		N=3;
	else if Eb>Tresh
             	N=2;
	     else if Ea>Tresh
		  	N=1;
		  else
			N=0;
			return;
		  end;
	     end;
	end;
end;


switch N
	case 1
		 alpha_d(1)=1;
                 alpha_d(2)=1;
	case 2
		 alpha_d(1)=(S(1,1)^2-S(2,2)^2)/(S(1,1)^2+S(2,2)^2);
                 alpha_d(2)=(S(1,1)-S(2,2))/(S(1,1)+S(2,2));
	case 3
                 alpha_d(1)=(S(1,1)^2-S(2,2)^2-S(3,3)^2)/(S(1,1)^2+S(2,2)^2+S(3,3)^2);
                 alpha_d(2)=(S(1,1)-S(2,2)-S(3,3))/(S(1,1)+S(2,2)+S(3,3));   
end;


clear S1 S2 S3;
 

%  The first component

%the best temporal and spectral modulation frequency
[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRFa,300,4,'n');
[BestFm,BestRD]=rtfparam(Fm,RD,RTF,0.5,'n');
clear Fm RD RTF;

%to find spectral envelope and create Gaussian function
Tpeak1=find(sum(abs(STRFa))==max(sum(abs(STRFa))));
Fpeak1=find(sum(abs(STRFa'))==max(sum(abs(STRFa'))));  

%fitting spectral profile at Tpeak1
if strcmp('svd',Method)
	[beta,SRF1]=srfmodel(xaxis,S(1,1)*U(:,1),abs(BestRD(1)));
else  
	[beta,SRF1]=srfmodel(xaxis,STRFa(:,Tpeak1),abs(BestRD(1)));
end;

x0(1)=beta(1);
w(1)=beta(2);
sf0(1)=beta(3);
spectrop(1)=beta(4);
k(1)=beta(5);
clear beta;

%fitting temporal profile
if  strcmp('svd',Method)
	[beta,TRF1]=trfmodel(taxis,S(1,1)*V(:,1)',abs(BestFm(1)));
else
	[beta,TRF1]=trfmodel(taxis,STRFa(Fpeak1,:),abs(BestFm(1)));
end;

t0(1)=beta(1);
c(1)=beta(2);
tf0(1)=beta(3);
q(1)=beta(4);
belta(1)=beta(6);
clear beta;

if  strcmp('svd',Method) | STRFa(Fpeak1,Tpeak1)>0
	STRFam=SRF1'*TRF1;
        STRFam=STRFam/strfstd(STRFam,STRF0,PP,Fst)*Ea;
else
	STRFam=-SRF1'*TRF1;
        STRFam=STRFam/strfstd(STRFam,STRF0,PP,Fst)*Ea;
end;

if N>=2
	%  The second component
 
	%the best temporal and spectral modulation frequency
	[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRFb,300,4,'n');
	[BestFm,BestRD]=rtfparam(Fm,RD,RTF,0.5,'n');
	clear Fm RD RTF;
 
	%to find spectral envelope and create Gaussian function
	Tpeak2=find(sum(abs(STRFb))==max(sum(abs(STRFb))));
	Fpeak2=find(sum(abs(STRFb'))==max(sum(abs(STRFb'))));
 
	%fitting spectral profile at Tpeak1
	if  strcmp('svd',Method) 
		[beta,SRF2]=srfmodel(xaxis,S(2,2)*U(:,2),abs(BestRD(1)));
        else
		[beta,SRF2]=srfmodel(xaxis,STRFb(:,Tpeak2),abs(BestRD(1)));
	end 
	x0(2)=beta(1);
	w(2)=beta(2);
	sf0(2)=beta(3);
	spectrop(2)=beta(4);
	k(2)=beta(5);
	clear beta;
 
	%fitting temporal profile
	if  strcmp('svd',Method) 
		 [beta,TRF2]=trfmodel(taxis,S(2,2)*V(:,2)',abs(BestFm(1)));	
	else
	     	 [beta,TRF2]=trfmodel(taxis,STRFb(Fpeak2,:),abs(BestFm(1)));
	end;
	t0(2)=beta(1);
	c(2)=beta(2);
	tf0(2)=beta(3);
	q(2)=beta(4);
	belta(2)=beta(6);
	clear beta;
	
	if  strcmp('svd',Method) | STRFb(Fpeak2,Tpeak2)>0
        	STRFbm=SRF2'*TRF2;
        	STRFbm=STRFbm/strfstd(STRFbm,STRF0,PP,Fst)*Eb;
	else
        	STRFbm=-SRF2'*TRF2;
        	STRFbm=STRFbm/strfstd(STRFbm,STRF0,PP,Fst)*Eb;
	end;            


        if N==3
        	%  The third component
 
        	%the best temporal and spectral modulation frequency
        	[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRFc,300,4,'n');
        	[BestFm,BestRD]=rtfparam(Fm,RD,RTF,0.5,'n');
        	clear Fm RD RTF;
 
        	%to find spectral envelope and create Gaussian function
        	Tpeak3=find(sum(abs(STRFc))==max(sum(abs(STRFc))));
        	Fpeak3=find(sum(abs(STRFc'))==max(sum(abs(STRFc'))));
 
        	%fitting spectral profile at Tpeak1
		if  strcmp('svd',Method)
			[beta,SRF3]=srfmodel(xaxis,S(3,3)*U(:,3),abs(BestRD(1)));
		else
	        	[beta,SRF3]=srfmodel(xaxis,STRFc(:,Tpeak3),abs(BestRD(1)));
		end;
        	x0(3)=beta(1);
        	w(3)=beta(2);
        	sf0(3)=beta(3);
        	spectrop(3)=beta(4);
        	k(3)=beta(5);
        	clear beta;
 
        	%fitting temporal profile
		if  strcmp('svd',Method)
			[beta,TRF3]=trfmodel(taxis,S(3,3)*V(:,3)',abs(BestFm(1)));
		else
		       	[beta,TRF3]=trfmodel(taxis,STRFc(Fpeak3,:),abs(BestFm(1)));
		end;
        	t0(3)=beta(1);
        	c(3)=beta(2);
        	tf0(3)=beta(3);
        	q(3)=beta(4);
        	belta(3)=beta(6);
        	clear beta;
		if  strcmp('svd',Method) | STRFc(Fpeak3,Tpeak3)>0
        		STRFcm=SRF3'*TRF3;
        		STRFcm=STRFcm/strfstd(STRFcm,STRF0,PP,Fst)*Ec;
		else
        		STRFcm=-SRF3'*TRF3;
        		STRFcm=STRFcm/strfstd(STRFcm,STRF0,PP,Fst)*Ec;
		end;      
  	end;
end;

STRFm=STRFam+STRFbm+STRFcm;

%Energy Error Metric
j=find(STRF~=0);
Errs(1)=sum((STRFm(j)-STRF(j)).^2)/sum(STRF(j).^2);
i=find(STRF~=0 & STRFm~=0);
Errs(2)=sum((STRFm(i)-STRF(i)).^2)/sum(STRF(j).^2);  
SI=strfcorrcoef(STRF,STRFm);
Tpeak=find(sum(abs(STRF))==max(sum(abs(STRF))));
Fpeak=find(sum(abs(STRF'))==max(sum(abs(STRF'))));       
a=corrcoef(STRFm(:,Tpeak),STRF(:,Tpeak));
SIs=a(1,2);
a=corrcoef(STRFm(Fpeak,:),STRF(Fpeak,:));
SIt=a(1,2);
SI=strfcorrcoef(STRF,STRFm);
clear a;

if strcmp(display,'y')
        Max=max(max(abs(STRF)));
        figure;
        set(gcf,'Position',[98 28 779 660])
        subplot(4,3,1);
        imagesc(STRF,[-Max Max]), colorbar
        set(gca,'YDir','normal')
        title('Measured STRF');
        subplot(4,3,2);
        imagesc(STRFm,[-Max Max]), colorbar
        set(gca,'YDir','normal')
        title('Fitted STRF');
        subplot(4,3,3);
        imagesc(STRF-STRFm,[-Max Max]), colorbar
        set(gca,'YDir','normal')
        title(['Error=' num2str(Errs(1)) ' Error1=' num2str(Errs(2))]);
        subplot(4,3,4);
        imagesc(STRFa,[-Max Max]), colorbar
        set(gca,'YDir','normal')
        title('The first component(STRFa)');
        subplot(4,3,5);
        imagesc(STRFam,[-Max Max]), colorbar
        set(gca,'YDir','normal')
        title('Fitted STRFa');
        subplot(4,3,6);
        imagesc(STRFa-STRFam,[-Max Max]), colorbar
        set(gca,'YDir','normal')
        title('Error');
        if N>1
                subplot(4,3,7);
        	imagesc(STRFb,[-Max Max]), colorbar
        	set(gca,'YDir','normal')
        	title('The second component(STRFb)');
        	subplot(4,3,8);
        	imagesc(STRFbm,[-Max Max]), colorbar
        	set(gca,'YDir','normal')
        	title('Fitted STRFb');
        	subplot(4,3,9);
        	imagesc(STRFb-STRFbm,[-Max Max]), colorbar
        	set(gca,'YDir','normal')
        	title('Error');
		if N==3
			subplot(4,3,10);
                	imagesc(STRFc,[-Max Max]), colorbar
                	set(gca,'YDir','normal')
                	title('The third component(STRFc)');
                	subplot(4,3,11);
                	imagesc(STRFcm,[-Max Max]), colorbar
                	set(gca,'YDir','normal')
                	title('Fitted STRFc');
                	subplot(4,3,12);
                	imagesc(STRFc-STRFcm,[-Max Max]), colorbar
                	set(gca,'YDir','normal')
                	title('Error');            
		end;
        end;
        figure;
        subplot(321);
        plot(STRFa(:,Tpeak1))
        title('Spectral profile for STRFa');
        hold on
        plot(STRFam(:,Tpeak1),'r')
        subplot(322);
        plot(STRFa(Fpeak1,:))
        title('Temporal profile for STRFa');
        hold on
        plot(STRFam(Fpeak1,:),'r')
        if N>1
                subplot(323);
                plot(STRFb(:,Tpeak2))
                title('Spectral profile for STRFb');
                hold on
                plot(STRFbm(:,Tpeak2),'r')
                subplot(324);
                plot(STRFb(Fpeak2,:))
                title('Temporal profile for STRFb');
                hold on
                plot(STRFbm(Fpeak2,:),'r')
		if N==3
			subplot(325);
                	plot(STRFc(:,Tpeak3))
                	title('Spectral profile for STRFc');
                	hold on
                	plot(STRFcm(:,Tpeak3),'r')
                	subplot(326);
                	plot(STRFc(Fpeak3,:))
                	title('Temporal profile for STRFc');
                	hold on
                	plot(STRFcm(Fpeak3,:),'r')   
		end;
   end;
end;       
                                                   
