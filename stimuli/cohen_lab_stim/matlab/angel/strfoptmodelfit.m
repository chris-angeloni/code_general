%function Errs=strfoptmodelfit(beta,Y,sprfile,STRF1,STRF2,PP,Vtresh,Vrest,Fs,Fsd,Trig,MdB,ModType,SModType,Sound,Options,Wo1,Wo2); 
%
% Function
%                        Optimization of Nsig, Tau, Tref and SNR
% Input
%           beta         array of initial parameters, [Nsig SNR Tau Tref]
%           Y            injected current
%           sprfile      sound filename
%           STRF1        contralateral STRF
%           STRF2        ipsilateral STRF
%           PP           Sound pressure level
%           Vtresh       threshold
%           Vrest        rest potential
%           Fs           sample frequency of Y
%           Fsd          sample frequency of spike train
%           Trig         spike trigger
%           MdB          modulation depth
%           ModType      modulation type (dB or Lin)
%           SModType     sound modulation type (dB or Lin)
%           Sound        'MR' or 'RN'
%           Options      binaural or monaural neuron
%           Wo1          spike rate for STRF1
%           Wo2          spike rate for STRF2
%
% ANQI QIU
% 5/27/2002
%

function Errs=strfoptmodelfit(beta,Y,sprfile,STRF1,STRF2,PP,Vtresh,Vrest,Fs,Fsd,Trig,MdB,ModType,SModType,Sound,Options,Wo1,Wo2);


%injected current
R=100E6;
Y1(2:length(Y))=diff(Y)*Fs*beta(3)/R+Y(2:length(Y))/R;
Y1(1)=Y(1)*(beta(3)*Fs+1)/R;
%integratefire neuron  
[X,Vm,R,C,sigma_m,sigma_i]=integratefire(Y1,beta(3),beta(4),Vtresh,Vrest,beta(1),beta(2),Fs,0);
[spet]=impulse2spet(X,Fs,Fsd);
[taxis,faxis,STRF1o,STRF2o,PP,Wo1o,Wo2o,No1o,No2o,SPLN]=rtwstrfdb(sprfile,0,0.1,spet,Trig,Fsd,60,MdB,ModType,Sound,100,'float');
clear spet X Vm R C sigma_m sigma_i taxis faxis SPLN;
switch Options
	case 0
		%[STRF1s,Tresh]=wstrfstat(STRF1o,0.001,No1o,Wo1o,PP,MdB,ModType,Sound,SModType);
		%[STRF2s,Tresh]=wstrfstat(STRF2o,0.001,No2o,Wo2o,PP,MdB,ModType,Sound,SModType);
                %i=find(STRF1~=0 | STRF1s~=0);
                %j=find(STRF2~=0 | STRF2s~=0);
                %Errs=sqrt(((Wo1o-xdata(1))^2/xdata(1)^2+(Wo2o-xdata(2))^2/xdata(2)^2+sum(sum((STRF1s(i)-STRF1(i)).^2))/sum(STRF1(i).^2)+sum(sum((STRF2s(j)-STRF2(j)).^2))/sum(STRF2(j).^2))/4)
		Errs=abs((Wo1o+Wo2o-Wo1-Wo2)/(Wo1+Wo2));
	case 1
      		%[STRF1s,Tresh]=wstrfstat(STRF1o,0.001,No1o,Wo1o,PP,MdB,ModType,Sound,SModType);
		%i=find(STRF1~=0 | STRF1s~=0);
 		%Errs=sqrt(((Wo1o-xdata(1))^2/xdata(1)^2+sum(sum((STRF1s(i)-STRF1(i)).^2))/sum(STRF1(i).^2))/2);             
		Errs=abs((Wo1o-Wo1)/Wo1);
	case 2
      		%[STRF2s,Tresh]=wstrfstat(STRF2o,0.001,No2o,Wo2o,PP,MdB,ModType,Sound,SModType);
		%i=find(STRF2~=0 | STRF2s~=0);
   		%Errs=sqrt(((Wo2o-xdata(1))^2/xdata(1)^2+sum(sum((STRF2s(i)-STRF2(i)).^2))/sum(STRF2(i).^2))/2);             
		Errs=abs((Wo2o-Wo2)/Wo2);
end;   
   


