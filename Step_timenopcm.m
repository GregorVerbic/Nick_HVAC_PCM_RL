 function [NextObs,Reward,IsDone,LoggedSignals] = Step_timenopcm(Action,LoggedSignals)
%% Define the environment constants. - Done with input data but can change
Inputdata;
set_point = 23;
%%%%%%%%%%%%%%%% 
lambda = 0.67; %Change this parameter to adjust reward function balance
%%%%%%%%%%%%%%%%
costTOU = [0.21340 0.21340 0.21340 0.21340 0.21340 0.21340...
        0.21340 0.38588 0.38588 0.37147 0.37147 0.37147...
        0.37147 0.37147 0.37147 0.37147 0.37147 0.38588...
        0.38588 0.38588 0.37147 0.37147 0.21340 0.21340];
%%%%%%%%%%%%%%%% 
feedIn = 0.09; %Change to 0 for no feed-in tariff
%%%%%%%%%%%%%%%% 
load trainingdata.mat;

%% Get state vector from the logged signals.
State = LoggedSignals.State;
t_in = State(1);
time_in = State(2);

%% load data
persistent jj
persistent kk
persistent Te

if (isempty(jj) || jj == 24)
    jj=0;
end

if (isempty(kk))
    kk = 0;
end
if (jj == 0)
    kk = kk + 1;
end

jj = jj + 1;

%% Temperature Calculation
Tout = Temperature(jj,kk);
PV = Solar(jj,kk);
day_load = Load(jj,kk);

if jj == 1
    Te = Tout;
end

%Calculate new internal temperature due to action
[te,Tin_new] = ode45(@(t,T) myode_Te(t,T,Tout,Rin,Rout,Ceq,ma,ca,Rdw,...
    pcm_mass,Action),[0,3600],[Te, t_in]); %T0 initial condition
Te = Tin_new(end, 1);
T_in_new = Tin_new(end, 2);

%% Transform state to observation.
  LoggedSignals.State(1) = T_in_new;
  LoggedSignals.State(2) = time_in + 1;
  NextObs = LoggedSignals.State;

%% Calculate Reward Components
tempDiff = abs(set_point - T_in_new);
if tempDiff < 1
    tempPunish = -0.25*tempDiff;
else
    tempPunish = -1*tempDiff;
end

%% Get reward.
power = 1*Action + day_load - PV; %Can remove PV for non-PV environment
if power < 0
    cost = feedIn;
else
    %%%%%%%%%%%%%%%% 
    cost = costTOU(jj); %Can change to cost = flat tariff
    %%%%%%%%%%%%%%%% 
end

Reward =  lambda*tempPunish - (1 - lambda)*power*cost;

IsDone = 0;

 end
function dTdt = myode_Te(t,T,Tout,Rin,Rout,Ceq,ma,ca,Rdw,pcm_mass,cooling)
Cpcm = pcm_mass*1300;
dTedt = (1/(Ceq+Cpcm))*((T(2) - T(1))/Rin + (Tout-T(1))/Rout);
dTindt = (1/(ma*ca))*((Tout - T(2))/Rdw + (T(1)-T(2))/Rin + ma*ca*(Tout-T(2))*0.3/3600 - (3000*cooling)); 
dTdt = [dTedt; dTindt];
end