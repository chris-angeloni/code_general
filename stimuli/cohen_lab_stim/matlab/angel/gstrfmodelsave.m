%function gstrfmodelsave(infile,outfile,TreshType,option,display,svdfile);
%
%Function
%                Fits STRF1 and STRF2 with a spectro-temporal Gabor and save the 
%		 results into outfile
%
%INPUT VARIABLES
%	infile		: Input File Name
%	outfile		: Output File Name
%	TreshType	: Threshold for determining significant STRF singular values 
%			 'svd' or 'nsvd'
%	option		: Determine model from 'STRFs' or 'STRF'
%			  Optional Parameter: Default=='STRFs'
%	display		: Optional Parameter: 'y' or 'n' 
%			  Default=='y'
%	svdfile	: 	: Noise sigular value data. Used to determine significant threshold. 
%			  Default=='rstrfeigen.mat'
%
%EXAMPLE
%   gstrfmodelsave('IC97QJE3t1_f01_ch1_u0_dB','IC97QJE3t1_f01_ch1_u0_dB_Gabor','svd','STRFs','n')
%
%  ANQI QIU 
%  11/12/2001
%  Escabi
%  04/17/03
%
function gstrfmodelsave(infile,outfile,TreshType,option,display,svdfile);

%input Arguments
if nargin<4
    option='STRFs';
end;
if nargin<5
   display='y';
end
if nargin<6
   svdfile='rstrfeigen.mat';
end

%Load STRF File
f=['load ' infile];
eval(f);

%Finding STRF for Dual Sound Presentation
if ~exist('STRF1')
	STRF1=(STRF1A+STRF1B)/2;
	STRF2=(STRF2A+STRF2B)/2;
end

figure
subplot(121)
pcolor(STRF1s),shading flat; colorbar;
subplot(122)
pcolor(STRF2s),shading flat; colorbar;

%fit the STRF1
if strcmp(TreshType,'svd')
	%Loading SVD Noise Data
	f=['load ' svdfile];
	eval(f)
        Tresh1=exp(a(1)*log(Wo1)^2+a(2)*log(Wo1)+a(3));
else
	[STRFs,Tresh1]=wstrfstat(STRF1,0.001,No1,Wo1,PP,MdB,ModType,Sound,SModType);
        Tresh1=Tresh1/3.1;
end;
if strcmp(option,'STRFs')
   STRF=STRF1s;
   STRFs=STRF1s;
else
   STRF=STRF1;
   STRFs=STRF1s;
end

[STRF1m,STRF1am,STRF1bm,STRF1cm,x01,w1,sf01,spectrop1,t01,c1,tf01,q1,k1,belta1,SIs1,SIt1,SI1,Errs1,alpha_d1,N1]=gstrfmodel(STRF,taxis,faxis,PP,Tresh1,TreshType,'nsvd',display);  

%fit the STRF2
if strcmp(TreshType,'svd')
	%Loading SVD Noise Data
	f=['load ' svdfile];
	eval(f)
        Tresh2=exp(a(1)*log(Wo2)^2+a(2)*log(Wo2)+a(3));
else
	[STRFs,Tresh2]=wstrfstat(STRF2,0.001,No2,Wo2,PP,MdB,ModType,Sound,SModType);
        Tresh2=Tresh2/3.1;
end;  

if strcmp(option,'STRFs')
   STRF=STRF2s;
   STRFs=STRF2s;
else
   STRF=STRF2;
   STRFs=STRF2s;
end
 [STRF2m,STRF2am,STRF2bm,STRF2cm,x02,w2,sf02,spectrop2,t02,c2,tf02,q2,k2,belta2,SIs2,SIt2,SI2,Errs2,alpha_d2,N2]=gstrfmodel(STRF,taxis,faxis,PP,Tresh2,TreshType,'nsvd',display);  

%to save the result
f=['save ' outfile ' Tresh1 Tresh2 STRF1m STRF1am STRF1bm STRF1cm x01 w1 sf01 spectrop1 t01 c1 tf01 q1 k1 belta1 SIs1 SIt1 SI1 Errs1 alpha_d1 N1 STRF2m STRF2am STRF2bm STRF2cm x02 w2 sf02 spectrop2 t02 c2 tf02 q2 k2 belta2 SIs2 SIt2 SI2 Errs2 alpha_d2 N2'];
eval(f);
