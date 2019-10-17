function [Rab_m,Rabmodel]=modelpnb(Rab_m,Fm,L,Fsd)

    ondiv = 0.00025./((1./Fm)/L);  % stimulus(2.5ms) on divisions
    if ondiv<1  % for FMAXis(k)<400 Hz in the case L=10
    
    Rabmodel = zeros(1,length(Rab_m));
    Rabmodel(1,(length(Rab_m)+2)/2) = max(Rab_m);
    shift=0;
    while (length(Rab_m)-1)/2 - shift>=0
        Rabmodel(1,(length(Rab_m)+2)/2-shift)=max(Rab_m);
        Rabmodel(1,(length(Rab_m)+2)/2+shift)=max(Rab_m);
        shift=shift+round(Fsd/Fm);
    end
    Rabmodel(1,1) = max(Rab_m);
    
    else  % for FAMsix(k)>400Hz in the case L=10
    
    Rabmodel = zeros(1,length(Rab_m));
    Rabmodel(1,(length(Rab_m)+2)/2) = max(Rab_m);
    Rabmodel(1,(length(Rab_m)+2)/2+1) = min(max(0,ondiv-1),1)*max(Rab_m);
    Rabmodel(1,(length(Rab_m)+2)/2+L-1) = min(max(0,ondiv-2),1)*max(Rab_m);
    Rabmodel(1,(length(Rab_m)+2)/2+2) = min(max(0,ondiv-3),1)*max(Rab_m);
    Rabmodel(1,(length(Rab_m)+2)/2+L-2) = min(max(0,ondiv-4),1)*max(Rab_m);
    LL = round(Fsd/Fm);
    shift=1:LL;
%     while (length(Rab_m)-1)/2 - max(shift)>=0
%         Rabmodel(1,(length(Rab_m)+1)/2-length(shift)-1+shift)=Rabmodel(1,(length(Rab_m)+1)/2-1+shift);
%         Rabmodel(1,(length(Rab_m)+1)/2+length(shift)-1+shift)=Rabmodel(1,(length(Rab_m)+1)/2-1+shift);
%         shift = shift + round(Fsd/FMAxis(FMindex));
%     end
  for step=1:2
        Rabmodel(1,(length(Rab_m)+2)/2+LL*step-1+shift)=Rabmodel(1,(length(Rab_m)+2)/2-1+shift);
        Rabmodel(1,(length(Rab_m)+2)/2-LL*step-1+shift)=Rabmodel(1,(length(Rab_m)+2)/2-1+shift);
   end
    end % end of if ondiv  
    
    Rabmodel(1,1) = max(Rab_m);
    Rabmodel=Rabmodel(1:length(Rab_m));