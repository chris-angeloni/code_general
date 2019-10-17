function [Rpnbmodel]=modelpnbshuf(pnbshuf,Fm,L)

% DESCRIPTION   : Model pnbshuf with impulse
Fsd=Fm*L;
ondiv = 0.00025./((1./Fm)/L);  % stimulus(2.5ms) on divisions
    if ondiv<1  % for FMAXis(k)<400 Hz in the case L=10
    
    Rpnbmodel = zeros(1,length(pnbshuf));
    Rpnbmodel(1,(length(pnbshuf)+2)/2) = max(real(sqrt(pnbshuf)));
    shift=0;
    while length(pnbshuf)/2 - shift>=0
        Rpnbmodel(1,(length(pnbshuf)+2)/2-shift)=max(real(sqrt(pnbshuf)));
        Rpnbmodel(1,(length(pnbshuf)+2)/2+shift)=max(real(sqrt(pnbshuf)));
        shift=shift+round(Fsd/Fm);
    end
    
    else  % for FAMsix(k)>400Hz in the case L=10
    
    Rpnbmodel = zeros(1,length(pnbshuf));
    Rpnbmodel(1,(length(pnbshuf)+2)/2) = max(real(sqrt(pnbshuf)));
    Rpnbmodel(1,(length(pnbshuf)+2)/2+1) = min(max(0,ondiv-1),1)*max(real(sqrt(pnbshuf)));
    Rpnbmodel(1,(length(pnbshuf)+2)/2+L-1) = min(max(0,ondiv-2),1)*max(real(sqrt(pnbshuf)));
    Rpnbmodel(1,(length(pnbshuf)+2)/2+2) = min(max(0,ondiv-3),1)*max(real(sqrt(pnbshuf)));
    Rpnbmodel(1,(length(pnbshuf)+2)/2+L-2) = min(max(0,ondiv-4),1)*max(real(sqrt(pnbshuf)));
    LL = round(Fsd/Fm);
    shift=1:LL;
%     while (length(pnbshuf)+2)/2 - max(shift)>=0
%         Rpnbmodel(1,(length(pnbshuf)+2)/2-max(shift)-1+shift)=Rpnbmodel(1,(length(pnbshuf)+2)/2-1+shift);
%         Rpnbmodel(1,(length(pnbshuf)+2)/2+max(shift)-1+shift)=Rpnbmodel(1,(length(pnbshuf)+2)/2-1+shift);
%         shift = shift + round(Fsd/FMAxis(k));
%     end
   for step=1:2
        Rpnbmodel(1,(length(pnbshuf)+2)/2+LL*step-1+shift)=Rpnbmodel(1,(length(pnbshuf)+2)/2-1+shift);
        Rpnbmodel(1,(length(pnbshuf)+2)/2-LL*step-1+shift)=Rpnbmodel(1,(length(pnbshuf)+2)/2-1+shift);
   end


    end % end of if ondiv    
    Rpnbmodel = Rpnbmodel(1:length(pnbshuf));
    