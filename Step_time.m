 function [NextObs,Reward,IsDone,LoggedSignals] = Step_time(Action,LoggedSignals)
%% Define the environment constants. - Done with input data but can change
%%%%%%%%%%%%%%%% 
Inputdata; %Change to Inputdata2 to use the lower critical temperature PCM
%%%%%%%%%%%%%%%% 
set_point = 23; %Remains the same
%%%%%%%%%%%%%%%% 
lambda = 0.67; %Change this parameter to adjust reward function balance
%%%%%%%%%%%%%%%%
costTOU = [0.21340 0.21340 0.21340 0.21340 0.21340 0.21340...
        0.21340 0.38588 0.38588 0.37147 0.37147 0.37147...
        0.37147 0.37147 0.37147 0.37147 0.37147 0.38588...
        0.38588 0.38588 0.37147 0.37147 0.21340 0.21340];
costFlat = 0.30;
%%%%%%%%%%%%%%%% 
feedIn = 0.09; %Change to 0 for no feed-in tariff, default 0.09
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
    p1,p2,p3,p4,p5,p6,q1,q2,q3,q4,pcm_mass,Action),[0,3600],[Te, t_in]); %T0 initial condition
Te = Tin_new(end, 1);
T_in_new = Tin_new(end, 2);

%% Transform state to observatio_n.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Change here for PV related agents, no PV removes the "- PV" component, Incr PV multiplies this component.
power = 1*Action + day_load - PV; %Can remove PV for non-PV environment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if power < 0
    cost = feedIn;
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Change here for difference electricity cost
    cost = costTOU(jj);
    %cost = costFlat;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
end

Reward =  lambda*tempPunish - (1 - lambda)*power*cost;

IsDone = 0;

 end
function dTdt = myode_Te(t,T,Tout,Rin,Rout,Ceq,ma,ca,Rdw,p1,p2,p3,p4,p5,p6,q1,q2,q3,q4,pcm_mass,cooling)
Cpcm = pcm_mass*(p1*T(2)^5 + p2*T(2)^4 + p3*T(2)^3 + p4*T(2)^2 + p5*T(2) + p6) / (T(2)^4 + q1*T(2)^3 + q2*T(2)^2 + q3*T(2) + q4);
dTedt = (1/(Ceq+Cpcm))*((T(2) - T(1))/Rin + (Tout-T(1))/Rout);
dTindt = (1/(ma*ca))*((Tout - T(2))/Rdw + (T(1)-T(2))/Rin + ma*ca*(Tout-T(2))*0.3/3600 - (3000*cooling)); 
dTdt = [dTedt; dTindt];
end