%
%function [ValidationData]=circularcorrmodelerror(R1,R2,sig)
%
%   FILE NAME       : CIRCULAR CORR MODEL ERROR
%   DESCRIPTION     : Computes the corrected and uncorrected model error
%                     for the circular correlation fits. See Yi & Escabi
%                     2013. The error is normalized as a percentage of the
%                     total correaltion function power.
%
%	R1              : Correlation function for 1st 1/2 the data
%   R2              : Correaltion function for 2nd 1/2 of the data
%   Sig             : Result from significance test (1 or 0) on the
%                     correlation function
%
%RETURNED VALUES
%
%   ValidationData  : Data structure containing the validation results
%
%                     .e            : Uncorrected Model Error (L2 norm)
%                     .e2           : Uncorrected Model Error (L1 norm)
%                     .e_corrected  : Corrected Model Error (L2 norm)
%                     .N            : Fractional Error Power (L2 norm)
%                     .H            : Result from Two-sample
%                                     Kolmogorov-Smirnov goodness-of-fit
%                                     hypothesis test. Defualt alpha=0.05.
%                     .p            : p value for Kolmogorov-Smirnov  test
%                     .flag         : 1 (otherwise 0) if results are
%                                     significant
%
% (C) Monty A. Escabi, Modified 11/12/13
%
function [ValidationData]=circularcorrmodelerror(R1,R2,sig)

if sig==1 & length(R1.Rab)==length(R2.Rab) & length(R2.gaussfun)==length(R2.Rab)
    %Extracting Model, Shuffled Corr, and Noise
    Rm=R2.gaussfun;    % model corr
    Rab1=R1.Rab/sum(R1.Rab)*sum(R2.Rab);       % shuffled corr trial 1
    Rab2=R2.Rab;       % shuffled corr trial 2
    n=Rab2-Rab1;       % measured error

    
    %Data for several error and noise metrics
   
    %e_corrected=abs(var(Rab1-Rm))-var(n)/(abs(var(Rab1)-var(n)));
    e=sum((Rab1-Rm).^2)/sum(Rab1.^2)*100;
    %e=var(Rab1-Rm)/var(Rab1);
    
    e2=sum(abs(Rab1-Rm))/sum(abs(Rab1))*100;
    N=sum(n.^2)/sum(Rab1.^2)*100;
    e_corrected=abs(sum((Rab1-Rm).^2)-sum(n.^2)/2)/(abs(sum(Rab1.^2)-sum(n.^2)/2))*100;
    
    
    %         %Plotting for test purpose    
    %         plot(R1)
    %         hold on
    %         plot(R2,'k')
    %         hold on
    %         plot(Data1(FMi).gaussfun,'r')
    %         hold off
    %         title(['Error= ' num2str(e(i,FMi)*100,3) ' % ; Corrected Error= ' num2str(e_corrected(i,FMi)*100,3)],'fontsize',20)
    %         pause
    %         
    % chisqrtest ********
    %Xref=randn(1,1024*16);
    %Xref=((Rab1-Rab2)-mean(Rab1-Rab2))/sqrt(2)+mean(Rab1-Rab2);
    Xref=n;
%    E_hat=Rab1-Rm + fliplr(Rab1-Rm);
    E_hat=Rab1-Rm;
    %E_hat=(Rab1-Rm)+fliplr(Rab1-Rm)-mean(Rab1-Rm);
    
%    Xref=Xref/std(Xref);
 %   E_hat=E_hat/std(E_hat);
    %E_hat=(E_hat-mean(E_hat))/std(E_hat);
    
%    plot(E_hat)
%    plot(Rab2)
%    hold on
    %plot(Rab1,'g')
%    plot(Rm,'r')
%    hold off
%    pause(1)
    %[H,p,X2,V]=chisqrtest(Xref,E_hat,0.05,-4,4);

    [H,p]=kstest2(Xref,E_hat,0.05);
    %[H,p]=lillietest(E_hat);
    %[H,p]=kstest(E_hat);
    ValidationData.e=e;
    ValidationData.e2=e2;
    ValidationData.e_corrected=e_corrected;
    ValidationData.N=N;
    ValidationData.H=H;
    ValidationData.p=p;
    ValidationData.flag=1;
else
    ValidationData.e=[];
    ValidationData.e2=[];
    ValidationData.e_corrected=[];
    ValidationData.N=[];
    ValidationData.H=[];
    ValidationData.p=[];
    ValidationData.flag=0;
end