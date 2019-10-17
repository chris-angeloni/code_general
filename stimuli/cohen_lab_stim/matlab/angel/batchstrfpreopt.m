%function batchstrfpreopt(namestruct,Nsigrange,Taurange,SNRrange,Options,L);
%
%Function
%            search the best parameters for the neuron
%            resimulate the response and FSI for MR and RN sounds
%Input:
%        namestruct      the struct with the field 'name'
%                        namestruct=struct('name',filename)
%        Nsigrange       the range of the intracellular threshold,for example [3 18]
%        Taurange        the range of the time constant, for example [1 10]
%        SNRrange        the range of the signal to noise ratio, for exmple [-10 20] dB
%        Options         the array that tell you whether STRF1 and STRF2 have receptive fields
%                        0       STRF1 and STRF2
%                        1       STRF1
%                        2       STRF2
%        L               the number of blocks
%Output
%       save data into filename_o.mat
%
% Copyright ANQI QIU
% 03/14/2002



function batchstrfpreopt(namestruct,Nsigrange,Taurange,SNRrange,Options,L);


M=size(namestruct,2);
for n=1:M,
   if ~strcmp(namestruct(n).name,'null');
      filename=namestruct(n).name;
      f=['load ' filename];
      eval(f);
      clear STRF1 STRF2 STRF1s STRF2s Wo1 Wo2 No1 No2 ModType SModType SPLN MdB PP;
      if strcmp(Sound,'MR');
         sprfile='movingripple.spr';
      else
         sprfile='ripplenoise.spr';
      end
      Nsigrange1=uniform(Nsigrange(1),Nsigrange(2),round(Nsigrange(2)-Nsigrange(1)),round((Nsigrange(2)-Nsigrange(1))/2));
      Taurange1=uniform(Taurange(1),Taurange(2),round(Taurange(2)-Taurange(1)),round((Taurange(2)-Taurange(1))));
      SNRrange1=uniform(SNRrange(1),SNRrange(2),round((SNRrange(2)-SNRrange(1))/5),6);
      SNRrange1=10.^(SNRrange1/20);                 
      % to find the best parameters for these neurons
      [Nsig,Tau,SNR,Err,Errsqrt,Errwo]=strfpreopt(sprfile,filename,Nsigrange1,Taurange1,SNRrange1,L,Options(n));
      i=find(filename=='.');
      f=['save ' filename(1:i-1) '_o.mat' ' Nsig Tau SNR Err Errsqrt Errwo Nsigrange1 Taurange1 SNRrange1'];
      eval(f);
   end
end


      
