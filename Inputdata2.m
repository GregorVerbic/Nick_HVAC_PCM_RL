clc
Rin=0.000042059;    %Internal thermal resistance of wall (K/W)
Rout=0.004163879;   %External thermal resistance of wall (K/W)
Ceq=10327274.1;   %Thermal Capacitance of wall in (J/K)
Uw=4.62;         %U value of window in (W/m2K)
aw=7.8;         % Area of windows in m2
Ud=2.61;         %U value of door in (W/m2K)
ad=2.1;         %Area of door in m2
volc=0.3;       %Rate of air flow in (m3/h)
ma=158.76;      %mass of air in kg
ca=1005.4;      %Specific heat of air in (J/kgK)
pcm_mass = 2805;
Rdw = 1/(4.62*7.8 + 2.61*2.1); %Resistance of doors and windows
load trainingdata.mat; %Load PV, temp and load data
load fitresult2; %Loading PCM curve

