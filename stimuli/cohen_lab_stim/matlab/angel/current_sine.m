%function current_sine(fun);
%  Function              analysis of spectral response of Hodgkin model 
%  Input
%               fun      0  :   stimulus current is sin(2*pi*F*t)
%                        1  :   stimulus current is I0+sin(2*pi*F*t)
%  note: it takes long time to run this program
% 
%  see also  Hodgkin.mdl, action_potential, current_rate, refractory, ananoise

-

function current_sine(fun);
%to initialize parameter
Fs=100;
mode=0;
Noise=zeros(10000,1);   


if fun==0
	for i=1:10,
%to initialize amplitude of sine
        if i==1
           A(i)=1e-6;
         else
           A(i)=5*(i-1)*1e-6;
         end
         for j=1:10,
	         F0(j)=10^(1+0.5*(j-1));  
            Iin=A(i)*sin(2*pi*F0(j)/1000*(1:10000)/Fs);
            [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin);
            rate0(i,j)=rate;
            clear('t','Vout','Spike','Vth','Vmax','rate','Gk','Gna','m','n','h','Iin');
         end;
      end;
      
mesh(F0,A,rate0);
save data/A.mat A;
save data/rate_sine.mat rate0;
save data/freq_sine.mat F0;
end;

if fun==1
   k=1;
   while(k<=6)
      switch k
      case 1,
         I0=2e-6*ones(1,10000);
      case 2,
         I0=10e-6*ones(1,10000);
      case 3,
         I0=30e-6*ones(1,10000);
      case 4, 
         I0=50e-6*ones(1,10000);
      case 5,
         I0=70e-6*ones(1,10000);
      case 6,
         I0=90e-6*ones(1,10000);
      end;
      for i=1:10,
%to initialize amplitude of sine
         if i==1
           A(i)=1e-6;
         else
           A(i)=5*(i-1)*1e-6;
         end
         for j=1:10,
	         F0(j)=10^(1+0.5*(j-1));  
            Iin=A(i)*sin(2*pi*F0(j)/1000*(1:10000)/Fs);
            Iin=Iin+I0;
            [t,Vout,Spike,Vth,Vmax,rate,Gk,Gna,m,n,h]=Hodgkin1(mode,Noise,Iin);
            rate0(k,i,j)=rate;
            clear('t','Vout','Spike','Vth','Vmax','rate','Gk','Gna','m','n','h','Iin');
         end;
      end;
      k=k+1;
   end;   
   save data/I0.mat I0;
   save data/A_sine.mat A;
   save data/F0_sine.mat F0;
   save data/ratesine.mat rate0;
end;



         
         