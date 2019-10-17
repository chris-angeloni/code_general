%fuction action_potential
%    Function        show membrane potential,
%                    conductances of potassium and sodium
%                    Rate constants (m,n,h)
%                    during action potential
%    Input           
%            Iin     stimulus current (array)
%
%    see also  Hodgkin.mdl, Hodgkin1, refractory, current_rate, current_sine, ananoise




function action_potential(Iin);
mode=0;
Noise=zeros(10000,1);
[t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin);
figure(1);
hold on;
subplot(3,1,1);
plot(t(12*100:30*100)-12,Vout(12*100:30*100),'b');
hold on;
plot(Vth(2,1)-12,Vth(2,2),'ro');
hold on;
plot(Vmax(2,1)-12,Vmax(2,2),'r*');
ylabel('Membrane Potential (mV)');


subplot(3,1,2);
hold on;
plot(t(12*100:30*100)-12,Gk(12*100:30*100),'g');
hold on;
plot(t(12*100:30*100)-12,Gna(12*100:30*100),'r');
ylabel('Conductance (S)');


subplot(3,1,3);
hold on;
plot(t(12*100:30*100)-12,m(12*100:30*100),'r');
plot(t(12*100:30*100)-12,n(12*100:30*100),'g');
plot(t(12*100:30*100)-12,h(12*100:30*100),'b');
xlabel('T   (msec)');
ylabel('Rate Constant (1/msec)');

