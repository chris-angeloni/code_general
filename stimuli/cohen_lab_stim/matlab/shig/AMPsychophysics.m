Fmin=20;
Fmax=20000;
DFMax=2000;
DFMin=20;
DT=.250;
T=.5
Fs=44100;


StopProgram=1;

MenueHandle=AMPsychophysicsMenue

%Finding tags and Assigning children
Children=get(MenueHandle,'children');
for k=1:length(Children)
   Tag=get(Children(k),'Tag');
   
   switch Tag
       case 'f1'
           F1h=Children(k);
       case 'f2'
           F2h=Children(k);
       case 'df'
           DFh=Children(k);
       case 'alpha'
           ALPHAh=Children(k);
       case 'beta1'
           BETA1h=Children(k);
       case 'beta2'    
           BETA2h=Children(k);
   end
   
end

while StopProgram
    
    %Getting slider values
    F1=Fmin+get(F1h,'value')*(Fmax-Fmin);
    F2=F1+get(F2h,'value')*(Fmax-F1);
    DF=DFMin+get(DFh,'value')*min((F2-F1),DFMax);
    ALPHA=(get(ALPHAh,'value')-.5)*6;
    BETA1=get(BETA1h,'value');
    BETA2=get(BETA2h,'value');
    
    PARAM=[round(F1/10)/100 round(F2/10)/100 round(DF/10)/100 round(ALPHA*100)/100 round(BETA1*100)/100 round(BETA2*100)/100];
    clc
    disp(PARAM)
    
    %Generating and playing sound
    tic,[X]=amharmonicnoise(F1,F2,DF,ALPHA,BETA1,BETA2,DT,Fs);
    soundsc(X,Fs)

    subplot(211)
    psd(X,1024*4,Fs)
    subplot(212)
    plot(X)
    

    pause(T-toc)    
    drawnow;
    
end
