%function refractory
%   Function    analysis of refractory period
%   
%   see also  Hodgkin.mdl, Hodgkin1, action_potential, current_rate, current_sine, ananoise



function refractory;
figure(1);
     subplot(2,2,1);
     Iin=(2*1e-6)*ones(5000,1);
     Noise=zeros(5000,1);
     mode=0;
     [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin); 
     plot(t,Vout);
     hold on;
     if rate~=0
        plot(Vth(:,1),Vth(:,2),'ro');
        hold on;
        plot(Vmax(:,1),Vmax(:,2),'r*');
     end;
     xlabel('T  (msec)');
     ylabel('Membrane Potential (mV)');
     title('A');
     clear;

     subplot(2,2,2);
     Iin=(5*1e-6)*ones(5000,1);
     Noise=zeros(5000,1);
     mode=0;
     [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin); 
     plot(t,Vout);
     hold on;
     if rate~=0
        plot(Vth(:,1),Vth(:,2),'ro');
        hold on;
        plot(Vmax(:,1),Vmax(:,2),'r*');
     end;
     xlabel('T  (msec)');
     ylabel('Membrane Potential (mV)');
     title('B');     
     clear;

     subplot(2,2,3);
     Iin=(13.6*1e-6)*ones(5000,1);
     Noise=zeros(5000,1);
     mode=0;
     [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin); 
     plot(t,Vout);
     hold on;
     if rate~=0
        plot(Vth(:,1),Vth(:,2),'ro');
        hold on;
        plot(Vmax(:,1),Vmax(:,2),'r*');
     end;
     xlabel('T  (msec)');
     ylabel('Membrane Potential (mV)');
     title('C');     
     clear;
     
     subplot(2,2,4);
     Iin=(100*1e-6)*ones(5000,1);
     Noise=zeros(5000,1);
     mode=0;
     [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin); 
     plot(t,Vout);
     hold on;
     if rate~=0
        plot(Vth(:,1),Vth(:,2),'ro');
        hold on;
        plot(Vmax(:,1),Vmax(:,2),'r*');
     end;
     xlabel('T  (msec)');
     ylabel('Membrane Potential (mV)');
     title('D');
     clear;
