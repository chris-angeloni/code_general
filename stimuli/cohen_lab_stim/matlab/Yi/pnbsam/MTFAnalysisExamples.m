function [Rpnb,Rsam,Rt,Rr]=MTFAnalysisExamples(PNB,SAM,FMAxis)

n=size(PNB,1);  % number of examples

%Normalizing MTFs according using MAX
for k=1:n
   PNBNorm(k,:)=[PNB(k,:).NORM]/max([PNB(k,:).NORM]); 
   PNBRate(k,:)=[PNB(k,:).RATE]/max([PNB(k,:).RATE]); 
   SAMNorm(k,:)=[SAM(k,:).NORM]/max([SAM(k,:).NORM]); 
   SAMRate(k,:)=[SAM(k,:).RATE]/max([SAM(k,:).RATE]);
end


%Plotting all examples - This gives you a feeling for how the VS and
%Normalized MTFs compare. Note that they are very similar for PNB but not
%for SAM. I think this has to do with the rise time component. Basically
%with PNB we can see the true integration of the neuron while for SAM the
%rise time adds an additional response component that distorts the MTF
%
%One thing you will notice in these plots that is very interesting is that
%the cutoff point or the BMF for the SAM is generally higher than for PNB. 
%Im fairly certain this is because of the SAM onset shape. This is hard to
%see in the rate data because PNB has much higher rates. However, when we
%normalize it the result appears to come out. In the next section below I
%will divide the PNB Norm MTF with SAM Norm MTF. Note that the ratio is
%always offset to high mod frequencies. We need to look at the ONSET data
%to see if these trends match the ONSET response component somehow.
%
for k=1:n
    
    subplot(221)
    % semilogx(FMAxis,PNBNorm(k,:))
    semilogx(FMAxis,PNBRate(k,:));
    hold on
    semilogx(FMAxis,[PNB(k,:).VS],'r');
    hold off
    index=find(~isnan([PNB(k,:).VS]));
    R=corrcoef(PNBRate(k,index),[PNB(k,index).VS]);
    title(['correlatoin coefficient (PNB) = ' num2str(R(1,2))])
    
    subplot(222)
    % semilogx(FMAxis,SAMNorm(k,:));
    semilogx(FMAxis,SAMRate(k,:));
    hold on
    semilogx(FMAxis,[SAM(k,:).VS],'r');
    hold off
    index=find(~isnan([SAM(k,:).VS]));
    R=corrcoef(SAMRate(k,index),[SAM(k,index).VS]);
    title(['correlatoin coefficient (SAM) = ' num2str(R(1,2))]);
    % pause
    
end

%Plot showing the ratio    SAMNorm/PNBNorm. Note that the enhancement is
%almost always at higher frequencies than the PNB MTF cutoff or right
%around the PNB cutoff. I think this is the result we are looking for
%because it demonstrates that there is a very systematic relationship
%betweeen the SAM and PNB MTF. Basically for SAM there appears to be
%enhancement at high frequencies and I think this is simply because of the
%onset shape. 
Ratio_sp = zeros(18,n);
for k=1:n
    
    subplot(221)
    semilogx(FMAxis,PNBNorm(k,:))
    hold on
    % Ratio=PNBNorm(k,:)./SAMNorm(k,:);
    Ratio=SAMNorm(k,:)./PNBNorm(k,:);
    Ratio=Ratio/max(Ratio);                     %Im normalizing the RATIO by MAX so that it becomes easy to compare`
    Ratio_sp(:,k)=[Ratio];
    semilogx(FMAxis,Ratio,'r')
    hold off
    
    %pause(1)
end

%This plot demonstrates that PNB Normalized MTF is highly correlated with
%the VS for PNB while the same is not true for SAM
%
%I am computing the correlation coefficient between VS and the Normalized MTF
%
%There are two thingrs that are affecting the correaltion coefficient
%values. First the NANs in the VS. Not sure why they are there. Is it my VS code. 
%We should try to see how to fix this. Second, the peak in the VS MTF which
%shows up bcause of refractoriness is also reducing the correlation. Ill
%have to think a bit more about this component to see if there is something we can do about it. 
%
 for k=1:n
   
    index=find(~isnan([PNB(k,:).VS]));
    R=corrcoef(PNBRate(k,index),[PNB(k,index).VS]);
    Rpnb(k)=R(2,1);
    Rn=corrcoef(PNBNorm(k,index),[PNB(k,index).VS]);
    Rpnbn(k)=Rn(2,1);
    
    index=find(~isnan([SAM(k,:).VS]));
    R=corrcoef(SAMRate(k,index),[SAM(k,index).VS]);
    Rsam(k)=R(2,1);
    
    index = find(~isnan([PNB(k,:).VS]) & ~isnan([SAM(k,:).VS]));
    R=corrcoef([PNB(k,index).VS],[SAM(k,index).VS]);
    Rt(k) = R(2,1);
    
    R=corrcoef(PNBRate(k,index),SAMRate(k,index));
    Rr(k) = R(2,1);
end


%Correlation coefficient between VS and Normalized MTF for SAM and PNB, not
%that the correlation is significantly higher for PNB
figure
hist([Rpnb' Rsam']);
% hist([Rpnbn']);
axis([-1 1 0 50]);
title(['CC between rMTF and tMTF']);

%Im now showing the correlation data as a scatter plot
figure
plot(Rpnb,Rsam,'ro');
xlabel('PNB'); ylabel('SAM');
hold on
plot([-1 1],[0 0],'k')
plot([0 0],[-1 1],'k')
axis([-1 1 -1 1 ])
title(['CC between rMTF and tMTF']);

figure
hist([Rt' Rr']);
axis([-1 1 0 50]);
title(['CC between PNB and SAM']);
figure
plot(Rt,Rr,'ro');
xlabel('tMTF'); ylabel('rMTF');
hold on
plot([-1 1],[0 0],'k')
plot([0 0],[-1 1],'k')
axis([-1 1 -1 1 ])
title(['CC between PNB and SAM']);

figure
subplot(221)
semilogx(FMAxis,20*log10(PNBRate'),'k')
subplot(222)
semilogx(FMAxis,20*log10(SAMRate'),'k')
axis([1 10000 -30 0])

subplot(223)
semilogx(FMAxis,20*log10(PNBNorm'),'k')
subplot(224)
semilogx(FMAxis,20*log10(SAMNorm'),'k')




 %I think the bottom line from the results is basically what Ive been
 %thinking. The normalized PNB MTF and / or VS allows you to see the integration which the neuron
 %performs. The high similarity between PNB VS and PNB Norm MTF suggests
 %this is the case. For SAM there is enhancement at high frequencies as
 %would be expected because of the onset shape. 
 
 
 
 
 

