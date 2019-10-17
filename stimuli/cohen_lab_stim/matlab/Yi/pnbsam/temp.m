% *********** Significant test ************
% function [SIGMI,SIGEI]=temp(SIGMI,SIGEI,SHUFtrue,SHUFrand,Flag,FMAxis,suindex)
% 
% count=25;
% while count<61
%   if suindex(count,1)==1
%     if ~isempty(SHUFtrue(count,1).MI)
%    Shufreal(1,:)=SHUFtrue(count,:);
%    Shufrand(1,:)=SHUFrand(count,:);
%    [sigMI,sigEI,MI,EI,MIrand,EIrand]=routinesig(Shufreal,Shufrand,Flag,FMAxis);
%    SIGMI(count,:)=sigMI(1,:);
%    SIGEI(count,:)=sigEI(1,:);
%    count=count+1;
%     else
%         count=count+1;
%     end
%   else
%       count=count+1;
%   end
% end  % end of while


% % ********* Significant MI *****************
% function [MIsus]=temp(MIsus,SUSshuf,SIGsus0)
% count=111;
% while count<128
%     if ~isempty(SUSshuf(count,1).r)
% for j=1:18
% MIsus(count,j)=SUSshuf(count,j).r*SIGsus0(count,j);
% end
% count=count+1;
%     else
%         count=count+1;
%     end
% end


%********** shuf for broken raster *****************
% function [SHUF]=temp(SHUF,RAS,FMAxis,suindex)
% 
% count=130;
% while count<143
%   if suindex(count,1)==1
%     if ~isempty(RAS(count,1).Fs)
%        % [RASspet2,N2]=rasterbrk(RAS(count,:),FMAxis,4,1341,1);
%        % [MTF] = mtfcorrgen4brkrasjack(RASspet2,0,FMAxis,10,N2,10);
%        [MTF] = mtfcorrgen4brkrasjack(RAS(count,:),0,FMAxis,10,ones(1,18),100);
%        % [MTF]=mtfcorrgeneratejack(RAS(count,:),0,FMAxis,10);
%        SHUF(count,:)=MTF;
%        count=count+1;
%     else
%         count=count+1;
%     end
%   else
%       count=count+1;
%   end
% end
% % save shufbrk

% ********* Random spike ******************
% function [RASrand]=temp(RASrand,RAS,FMAxis)
% count =142;
% while count<143
%     if ~isempty(RAS(count,1).Fs)
%         [RASwrap]=cirwrapras(RAS(count,:),FMAxis,4);  % for SRN
%         [RASsh]=shuffleras(RASwrap);
%         %[RASsh]=shuffleras(RAS(count,:));
%         RASrand(count,:)=RASsh;
%         count = count+1;
%     else
%         count = count+1;
%     end
% end
% save RASrandsus

% ***************************
% function [SHUF]=temp(SHUF,RAS,FMAxis)

% count=1;
% while count<10
%     if ~isempty(RAS(count,1).Fs)
% [SHUF,count]=stat(SHUF,RAS(count,:),FMAxis,count);
% count = count+1;
%     else
%         count=count+1;
%     end
% end
% save PNBshuf3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [RASshsam]=temp(RASshsam,RASsam)
% count = 21
% while count<94
%     RASspet = RASsam(count,:)
%   [RASsh]=shuffleras(RASspet);
%   RASshsam(count,:)=RASsh;
%   count=count+1;
% end
% save RASshsam

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [SHUF2] = temp(SHUF,SHUF2,FMAxis)
% count = 127;
% while count<128
%     clear shuf;
%     shuf(1,:) = SHUF(count,:);
%     [shuf] = modelpnbshuf(shuf,FMAxis,10);
%     SHUF2(count,:) = shuf;
%     count = count + 1;
% end
%     
% **************** rtMTF *******************
function [rtMTF]=temp(RASTER,rtMTF,FMAxis)
count = 100;
while count<128
    RASspet = RASTER(count,:);
    [MTF]= mtfrtgenerate(RASspet,FMAxis,0,'duration',0.5,4,10);
    rtMTF.RATE(count,1:length(FMAxis)) = MTF.Rate;
    rtMTF.NORM(count,1:length(FMAxis)) = MTF.Spetnorm; 
    rtMTF.VS(count,1:length(FMAxis)) = MTF.VS;
    rtMTF.VSsig(count,1:length(FMAxis)) = MTF.VSsig;
    count = count+1;
end


% function [CYCh]=temp(CYCh,RAS,Flag,FMAxis)
% 
% count=1;
% while count<128
%     if ~isempty(RAS(count,1).Fs)
%     RASspet = RAS(count,:);
%     if Flag==1 | Flag==0
%     [CYCH] = cychgen(RASspet,1,FMAxis,25,'duration',1,4,10);
%     else Flag==2
%         [CYCH] = cychgen(RASspet,2,FMAxis,25,'cyc',0,1,100);
%     end
%     CYCh{count}=CYCH;
%     count = count+1;
%     else
%         count=count+1;
%     end
% end
        


% function [Rdif]=temp(MTFpnbshuf,MTFsamshuf,FMAxis)
% 
% % Rdif=zeros(93,18);
% % for k=1:93
% %   for FMi=1:18  
% %     if (~isempty(MTFpnbshuf(k,FMi).Rab) & ~isempty(MTFsamshuf(k,FMi).Rab))
% %     index=find(~isnan(MTFpnbshuf(k,FMi).Rab)& ~isnan(MTFsamshuf(k,FMi).Rab));
% %     if ~isempty(index)
% %     R=corrcoef(MTFpnbshuf(k,FMi).Rab(index),MTFsamshuf(k,FMi).Rab(index));
% %     Rdif(k,FMi)=1-(R(2,1));
% %     end
% %     end
% %   end  % end of FMi
% %   subplot(211)
% %   title(['unit' num2str(k)]);
% %   semilogx(FMAxis(1:length([MTFpnbshuf(k,:).r])),[MTFpnbshuf(k,:).r]);
% %   hold on 
% %   semilogx(FMAxis(1:length([MTFsamshuf(k,:).r])),[MTFsamshuf(k,:).r],'r');
% %   axis([1 2000 0 1]);
% %   hold off
% %   subplot(212)
% %   semilogx(FMAxis,Rdif(k,:));
% %   axis([1 2000 0 1]);
% %  
% %   pause
% % end  % end of k
% 
% for FMindex=1:18
%     i=1; j=1;
%     Rab_pnb=[]; Rab_sam=[];
% for n=1:93
%    if ~isempty(MTFpnbshuf(n,FMindex).Rab)& ~isempty(MTFpnbshuf(n,FMindex).DC)
%     Rab_pnb(i,:)=real(sqrt(MTFpnbshuf(n,FMindex).Rab))
%     i=i+1;
%    end  % end of if ~isempty
%  end  % end of n
%  for n=1:93
%    if ~isempty(MTFsamshuf(n,FMindex).Rab)& ~isempty(MTFsamshuf(n,FMindex).DC)
%     Rab_sam(j,:)=real(sqrt(MTFsamshuf(n,FMindex).Rab))
%     j=j+1;
%    end  % end of if ~isempty
%  end  % end of n
% Rab_Mpnb{FMindex}=mean(Rab_pnb,1);
% Rab_Msam{FMindex}=mean(Rab_sam,1);
% Rab_Mpnb{FMindex}=Rab_Mpnb{FMindex}./max(Rab_Mpnb{FMindex});
% Rab_Msam{FMindex}=Rab_Msam{FMindex}./max(Rab_Msam{FMindex});
% 
% R=corrcoef(Rab_Mpnb{FMindex},Rab_Msam{FMindex});
% Rdiff(FMindex)=1-(R(2,1));
% 
% NB=100;
% for l=1:NB
%     jpnb =randsample(size(Rab_pnb,1),size(Rab_pnb,1),'true');
%     Rab_pnbm = mean(Rab_pnb(jpnb,:));
%     jsam =randsample(size(Rab_sam,1),size(Rab_sam,1),'true');
%     Rab_samm = mean(Rab_sam(jsam,:));
%     r = corrcoef(Rab_pnbm,Rab_samm);
%     Difboot(l,FMindex) = 1-r(1,2);
% end
% end  % end of FMindex
% 
% Rdif.SE = std(Difboot,1);
% Rdif.M = Rdiff;



