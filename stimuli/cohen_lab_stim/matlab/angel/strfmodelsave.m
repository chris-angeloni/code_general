%function strfmodelsave(infilename,outfilename,option,display);
%
%Function
%                to fit STRF1 and STRF2 and save the results into outfilename
%Definition
%             1   contralateral
%             2   ipsilateral
%Input
%        option    'STRFs'  fit significant STRF
%                  'STRF'   fit STRF
%
%  ANQI QIU 
%  11/12/2001

function strfmodelsave(infilename,outfilename,option,display);

if nargin<4
   display='y';
end

f=['load ' infilename];
eval(f);
%Finding STRF for Dual Sound Presentation
if ~exist('STRF1')
	STRF1=(STRF1A+STRF1B)/2;
	STRF2=(STRF2A+STRF2B)/2;
end

%to fit the STRF1
[STRFs,Tresh]=wstrfstat(STRF1,0.001,No1,Wo1,PP,MdB,ModType,Sound,SModType);
if strcmp(option,'STRFs')
   STRF=STRF1s;
   STRFs=STRF1s;
else
   STRF=STRF1;
   STRFs=STRF1s;
end
[STRF1m,STRF1am,STRF1bm,x10,w1,sf10,spectrop1,t10,c1,tf10,q1,k1,belta1,Tpeak1,Fpeak1,SI1s,SI1t,SI1,Err1s,alpha_d1]=strfmodel_ic(STRF,STRFs,taxis,faxis,PP,Tresh,display);

%to fit the STRF2
[STRFs,Tresh]=wstrfstat(STRF2,0.001,No2,Wo2,PP,MdB,ModType,Sound,SModType);
if strcmp(option,'STRFs')
   STRF=STRF2s;
   STRFs=STRF2s;
else
   STRF=STRF2;
   STRFs=STRF2s;
end
[STRF2m,STRF2am,STRF2bm,x20,w2,sf20,spectrop2,t20,c2,tf20,q2,k2,belta2,Tpeak2,Fpeak2,SI2s,SI2t,SI2,Err2s,alpha_d2]=strfmodel_ic(STRF,STRFs,taxis,faxis,PP,Tresh,display);

%to save the result
f=['save ' outfilename ' STRF1m STRF1am STRF1bm x10 w1 sf10 spectrop1 t10 c1 tf10 q1 k1 belta1 Tpeak1 Fpeak1 SI1s SI1t SI1 Err1s alpha_d1 STRF2m STRF2am STRF2bm x20 w2 sf20 spectrop2 t20 c2 tf20 q2 k2 belta2 Tpeak2 Fpeak2 SI2s SI2t SI2 Err2s alpha_d2'];
eval(f);
