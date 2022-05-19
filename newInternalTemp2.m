%% Calculates the next internal temperature with PCM2
function new_Tin = newInternalTemp2(outsideTemp, insideTemp, action, iteration)
Rin=0.000042059;    %Internal thermal resistance of wall (K/W)
Rout=0.004163879;   %External thermal resistance of wall (K/W)
Ceq=10327274.1;   %Thermal Capacitance of wall in (J/K)
Uw=4.62;         %U value of window in (W/m2K)
aw=7.8;         % Area of windows in m2
Ud=2.61;         %U value of door in (W/m2K)
ad=2.1;         %Area of door in m2
ma=158.76;      %mass of air in kg
ca=1005.4;      %Specific heat of air in (J/kgK)
pcm_mass = 2805;
Rdw = 1/(4.62*7.8 + 2.61*2.1);
p1 = 242.1571;
p2 = -23135.6136134693;
p3 = 854939.255599280;
p4 = -15469023.9791043;
p5 = 139925016.943822;
p6 = -500878630.099816;
q1 = -62.2789213076584;
q2 = 1123.86818921053;
q3 = -3759.04186195121;
q4 = -22947.7513032294;
persistent Te
if iteration == 1
    Te = outsideTemp;
end
[te,Tin_new] = ode45(@(t,T) myode_Te(t,T,outsideTemp,Rin,Rout,Ceq,ma,ca,Rdw,...
    p1,p2,p3,p4,p5,p6,q1,q2,q3,q4,pcm_mass,action),[0,3600],[Te, insideTemp]); %T0 initial condition
Te = Tin_new(end, 1);

new_Tin = Tin_new(end,2);
end
function dTdt = myode_Te(t,T,Tout,Rin,Rout,Ceq,ma,ca,Rdw,p1,p2,p3,p4,p5,p6,q1,q2,q3,q4,pcm_mass,cooling)
Cpcm = pcm_mass*(p1*T(2)^5 + p2*T(2)^4 + p3*T(2)^3 + p4*T(2)^2 + p5*T(2) + p6) / (T(2)^4 + q1*T(2)^3 + q2*T(2)^2 + q3*T(2) + q4);
dTedt = (1/(Ceq+Cpcm))*((T(2) - T(1))/Rin + (Tout-T(1))/Rout);
dTindt = (1/(ma*ca))*((Tout - T(2))/Rdw + (T(1)-T(2))/Rin + ma*ca*(Tout-T(2))*0.3/3600 - (3000*cooling)); 
dTdt = [dTedt; dTindt];
end