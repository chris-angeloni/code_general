%function [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin,Fs,ratio,G,E)
%
%		File name:     		Hodgkin_noise
%     Function :				This model is Hodgkin and Huxley's model
%													that can be used to describe the changes
%													of conductance of potassium and sodium
%													during the action potetial and the generation
%													of action potetial.
%		Input		:
%							Iin  		the current array that is injected to cell
%                    Noise           the noise array 
%                    mode            '0'  not use noise, '1' use noise,give noise array
%							Fs			sampling frequency unit 1/ms
%							ratio		ratio of signal to noise
%							G        the array of the maximun of ionic conductances
%										the order is GNa,Gk, Gl
%							E        the array of the resting potetial of Ions.
%										the order is ENa,Ek,El,Er
%
%							Iin, Fs and ratio are required. G and E are optional.
%							Default G=[120e-3,36e-3,0.3e-3], E=[55,-72,-49.4,-60]
%		Output	:
%							t 			the time
%							Vout     the membrane potetial, its unit is mv (array)
%                    Spike    the series of Spike (array)
%                    Vth      the threshold of action potential (matrix t Vth)
%                    Vmax     the pole point of action potential (matrix t Vmax)
%                    rate     the rate of spikes, unit is /ms   (value)
%                             m,n,h  
%                   Gna      sodium conductance                (array)
%                   Gk       potassium conductance  
%     See also Hodgkin.mdl, action_potential, current_rate, current_sine,refractory,ananoise


function [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin,Fs,ratio,G,E)
%to initialize parameters
if (nargin<1)
    Iin=(100e-6)*ones(10000,1);
    Noise=zeros(10000,1);
    mode=0;
    Fs=100000;
    ratio=5;
    G=[120e-3,36e-3,0.3e-3];  %0.3e-3
    E=[55,-72,-49.4,-60];
elseif (nargin<2)
    Noise=zeros(10000,1);
    Iin=(13.6e-6)*ones(10000,1);
    Fs=100000;
    ratio=5;
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
elseif (nargin<3)
    Iin=(13.6e-6)*ones(10000,1);
    Fs=100000;
    ratio=5;
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
elseif (nargin<4)
    Fs=100000;
    ratio=5;
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
elseif (nargin<5)
    ratio=5;
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
elseif (nargin<6)
    G=[120e-3,36e-3,0.3e-3];
    E=[55,-72,-49.4,-60];
else
    E=[55,-72,-49.4,-60];    
end;
Fs=Fs/1000;
Vout=zeros(length(Iin),1);
Ik=zeros(length(Iin),1);
Ina=zeros(length(Iin),1);
Il=zeros(length(Iin),1);
Spike=zeros(length(Iin),1);
n=0.3177*ones(length(Iin),1);
m=0.0529*ones(length(Iin),1);
h=0.5963*ones(length(Iin),1);
dt=1/Fs;
C=1e-6;
Vna=E(1)-E(4);
Vk=E(2)-E(4);
Vl=E(3)-E(4);
Tau=round(1/G(3)*C*1000*Fs);

%to generate noise
if mode==1
   Pnoise=(sum(Noise.*Noise))/length(Noise);
   PIin=(sum(Iin.*Iin))/length(Iin);
   Noise=(sqrt(PIin/Pnoise)/ratio)*Noise;
end; 


for i=1:(length(Iin)-1),
   %to calculate conductance of potassium gk=max(gk)*n^4
   
   alphan=0.01*(-Vout(i)+10)/(exp((-Vout(i)+10)/10)-1);
   betan=0.125*exp(-Vout(i)/80);
   n(i+1)=n(i)+dt*alphan*(1-n(i))-dt*betan*n(i);
   Gk(i)=G(2)*n(i+1)*n(i+1)*n(i+1)*n(i+1);
   
   %to calculate the conductance of sodium gna=max(gna)*m^3*h
   alpham=0.1*(-Vout(i)+25)/(exp((-Vout(i)+25)/10)-1);
   betam=4*exp(-Vout(i)/18);
   m(i+1)=m(i)+dt*alpham*(1-m(i))-dt*betam*m(i);
     
   alphah=0.07*exp(-Vout(i)/20);
   betah=1/(exp((-Vout(i)+30)/10)+1);
   h(i+1)=h(i)+dt*alphah*(1-h(i))-dt*betah*h(i);   
   Gna(i)=G(1)*m(i+1)*m(i+1)*m(i+1)*h(i+1);
   
   
   %to calculate the membrane potetial
   
   Ik(i)=Gk(i)*(Vout(i)-Vk);   %mA
   Ina(i)=Gna(i)*(Vout(i)-Vna);
   Il(i)=G(3)*(Vout(i)-Vl);
   Ii=Ik(i)+Ina(i)+Il(i);
   Vout(i+1)=Vout(i)+dt*(Iin(i)+Noise(i)-Ii*0.001)/C;
end
Ik(length(Iin))=Ik(length(Iin)-1);
Ina(length(Iin))=Ina(length(Iin)-1);
Il(length(Iin))=Il(length(Iin)-1);
Gk(length(Iin))=Gk(length(Iin)-1);
Gna(length(Iin))=Gna(length(Iin)-1);

Vout=Vout+E(4)*ones(length(Iin),1);
t=(1:length(Iin))/Fs;

   %to calculate number of splikes
   i=1;
   while (i+1)<=(length(Iin)),
      if (abs(Ina(i))>abs((Ik(i)+Il(i)))) &(Gna(i+1)>Gna(i))&(Gk(i+1)>Gk(i))
         Spike(i)=1;
         i=i+Tau;
      else
         i=i+1;
      end      
   end;
  
 %to calculate the matrix of threshold  and matrix of Vmax
   j=1;
   for i=1:length(Iin),
     if Spike(i)==1
        Vth(j,1)=i/Fs;
        Vth(j,2)=Vout(i);
        if (i+Tau)<=length(Iin)
           Vmax(j,2)=max(Vout(i:(i+Tau)));
           for k=i:(i+Tau),
             if Vout(k)==Vmax(j,2)
               Vmax(j,1)=k/Fs;
             end;
           end;
        else
           Vmax(j,2)=max(Vout(i:length(Iin)));
            for k=i:length(Iin),
              if Vout(k)==Vmax(j,2)
                 Vmax(j,1)=k/Fs;
              end;
            end;
        end
        j=j+1;
     end;
   end;
  rate=sum(Spike)/(length(Iin)/Fs);



