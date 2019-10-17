%function [Nsig,Tau,SNR,Err,Errsqrt,Errwo]=strfpreopt(sprfile,filename,Nsigrange,Taurange,SNRrange,L,Options);
%
%Function
%               search the best Nsig, Tau and SNR in the global space
%Input:
%          sprfile             sound file 'movingripple.spr' for MR
%                                         'ripplenosie.spr' for RN
%          filename            the file has the data as files 'dB.mat'
%          Nsigrange           the range of Nsig (2:20) for integrate fire neuron
%          Taurange            the range of Tau  (2:10)
%          SNRrange            the range of SNR [0.3162 0.5623 1.0000 1.7783 3.1623 5.6234]
%          L                   the number of blocks
%          Options             constant
%                              0      to consider STRF1 and STRF2
%                              1      just to consider STRF1
%                              2      just to consider STRF2
%Output:
%         Nsig                 the best Nsig for the neuron in filename
%         Tau                  the best Tau for the neuron in the filename
%         SNR                  the best SNR 
%         Err                  the minimal error 
%         Errsqrt              the matrix of Error for this global search
%         Errwo                the matrix of error of spike rate
%
%  Copyright ANQI QIU
%  03/14/2002


function [Nsig,Tau,SNR,Err,Errsqrt,Errwo]=strfpreopt(sprfile,filename,Nsigrange,Taurange,SNRrange,L,Options);

% load file
f=['load ' filename];
eval(f);

%to compute intracellular current
N=size(STRF1s,2);
STRF1=STRF1s(:,1:4:N);
STRF2=STRF2s(:,1:4:N);
taxis=taxis(1:4:400);
clear STRF1s STRF2s
if strcmp(Sound,'MR')
   k=1:1706;
   L1=1706;
else
   k=1:1500;
   L1=1500;
end;
[T,Y,Y1,Y2]=strfsprpre(sprfile,taxis,faxis,STRF1,STRF2,MdB,L1);
clear Y1 Y2;

R=100E6;

%parameters for integrate file neuron
Tref=1;
Vtresh=-50;
Vrest=-65;
Fs=44100/44;
Fsd=24000;
%to generate Trig
Trig=round(((k-1)*728+1)/Fs*Fsd);
clear k taxis faxis;
i=1;
j=1;
k=1;
No1o=100;
Errsqrt=10*ones(length(Nsigrange),length(Taurange),length(SNRrange));
Errwo=10*ones(length(Nsigrange),length(Taurange),length(SNRrange));
% loop for each Nsig, Tau, SNR
while (i-1<length(Nsigrange)) & (No1o>10)
    while (j-1<length(Taurange)) & (No1o>10)
       while (k-1<length(SNRrange)) & (No1o>10)
         %integrate fire neuron
         Y1(2:length(Y))=diff(Y)*Fs*Taurange(j)/R+Y(2:length(Y))/R;
         Y1(1)=Y(1)*(Taurange(j)*Fs+1)/R;
         [X,Vm,R,C,sigma_m,sigma_i,sigma_n,sigma_tot]=integratefire(Y1,Taurange(j),Tref,Vtresh,Vrest,Nsigrange(i),SNRrange(k),Fs,0);
         %to convert X to spike train
         [spet]=impulse2spet(X,Fs,Fsd);
         clear X Vm R C sigma_m sigma_i sigma_n sigma_tot;
         %generate STRF1o and STRF2o
         [taxis,faxis,STRF1o,STRF2o,PP,Wo1o,Wo2o,No1o,No2o,SPLN]=rtwstrfdb(sprfile,0,0.1,spet,Trig,Fsd,60,MdB,ModType,Sound,50,'float');
         clear spet;
         switch Options
         case 0,
            [STRF1os,Tresh]=wstrfstat(STRF1o,0.001,No1o,Wo1o,PP,MdB,ModType,Sound,SModType);
            [STRF2os,Tresh]=wstrfstat(STRF2o,0.001,No2o,Wo2o,PP,MdB,ModType,Sound,SModType);
            [R1,std1o,std1]=strfcorrcoef(STRF1os,STRF1);
            [R2,std2o,std2]=strfcorrcoef(STRF2os,STRF2);
            Errsqrt(i,j,k)=sqrt(((Wo1o-Wo1)^2/Wo1^2+(1-R1).^2+(std1o-std1)^2/std1^2+(Wo2o-Wo2)^2/Wo2^2+(1-R2)^2+(std2o-std2).^2/std2^2)/6);
            Errwo(i,j,k)=sqrt(((Wo2o-Wo2)^2/Wo1^2+(Wo2o-Wo2)^2/Wo2^2)/2);
            clear taxis faxis STRF1o STRF2o PP Wo1o Wo2o No2o SPLN STRF1os STRF2os Tresh R1 std1o std1 std2o std2 R2; 
         case 1,
            [STRF1os,Tresh]=wstrfstat(STRF1o,0.001,No1o,Wo1o,PP,MdB,ModType,Sound,SModType);
            [R1,std1o,std1]=strfcorrcoef(STRF1os,STRF1);
            Errsqrt(i,j,k)=sqrt(((Wo1o-Wo1)^2/Wo1^2+(1-R1).^2+(std1o-std1)^2/std1^2)/3);
            Errwo(i,j,k)=sqrt((Wo1o-Wo1)^2/Wo1^2);
            clear taxis faxis STRF1o STRF2o PP Wo1o Wo2o No2o SPLN STRF1os Tresh R1 std1o std1;
         case 2,
            [STRF2os,Tresh]=wstrfstat(STRF2o,0.001,No2o,Wo2o,PP,MdB,ModType,Sound,SModType);
            [R2,std2o,std2]=strfcorrcoef(STRF2os,STRF2);
            Errsqrt(i,j,k)=sqrt(((Wo2o-Wo2)^2/Wo2^2+(1-R2)^2+(std2o-std2).^2/std2^2)/3);
            Errwo(i,j,k)=sqrt((Wo2o-Wo2)^2/Wo2^2);
            clear taxis faxis STRF1o STRF2o PP Wo1o Wo2o No2o SPLN STRF2os Tresh std2o std2 R2;
         end;
         clc;
         disp(['The number of loops is ' num2str((i-1)*length(Taurange)*length(SNRrange)+(j-1)*length(SNRrange)+k) ' of ' num2str(length(Nsigrange)*length(Taurange)*length(SNRrange))]);
         k=k+1;
      end
      j=j+1;
      k=1;    
   end
   i=i+1;
   j=1;
end
clear k i j;
%to find minimal error
[Err,k]=min(min(min(Errsqrt)));
[i,j]=find(Errsqrt(:,:,k)==min(min(Errsqrt(:,:,k))));
Nsig=Nsigrange(i);
Tau=Taurange(j);
SNR=SNRrange(k);




           

