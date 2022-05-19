%% Script used to print agent responses
% Will have to change some parameters based on the type of agent
load('trainingdata.mat');
numDays = 5;
offset = 27;
tout = Temperature(:,1+offset:numDays+offset); %Offset to find a good sample
tout = reshape(tout,[],1);
ld = Load(:,1+offset:numDays+offset);
ld = reshape(ld,[],1);
PV = Solar(:,1+offset:numDays+offset); 
PV = reshape(PV,[],1);
%%%
%PV = PV*4.5; %For increased PV agent
%%%
tin = tout(1);
TIN = [];
ACTION = [];
costTOU = [0.21340 0.21340 0.21340 0.21340 0.21340 0.21340...
        0.21340 0.38588 0.38588 0.37147 0.37147 0.37147...
        0.37147 0.37147 0.37147 0.37147 0.37147 0.38588...
        0.38588 0.38588 0.37147 0.37147 0.21340 0.21340];
%%%
feedIn = 0.09; %Change for no feed-in tariff
%%%
costFlat = 0.30;
usage = 0;
USAGE = [];
cost = 0;
PVgen = 0;
PVsold = 0;
for k = 1:(24*numDays)
    time = mod(k,24);
    if time == 0
        time = 24;
    end
    TIN = [TIN; tin];
    %%%
    action = evaluatePolicy_flat_0_67([tin;time]); %This is the policy of the agent
    %%%
    if action > 1 %Capping action between 0 and 1
        action = 1;
     elseif action < 0
             action = 0;
    end
    ACTION = [ACTION; action];
    %%%
    tin = newInternalTemp(tout(k), tin, action,k); %Use newInternalTemp2 for PCM2
    %%%
    hourUse = action + ld(k) - PV(k); %Take away PV for no-PV system
    PVgen = PVgen + PV(k);
    %%%
    price = costTOU(time);
    %price = costFlat;
    %%%
    if hourUse < 0
        price = feedIn;
        PVsold = PVsold + abs(hourUse);
    end
    usage = usage + hourUse;
    USAGE = [USAGE; action + ld(k)];
    cost = cost + hourUse*price;
end

% Graphing
yyaxis left
plot(TIN, 'linewidth', 2)
hold on
plot(tout, 'linewidth', 2)
yline(23, 'g--', 'linewidth', 2) %Set point
ylabel('Temperature ({\circ}C)')
yyaxis right
ylim([0,1])
stairs(ACTION,'-r', 'linewidth', 2)
ylabel('AC Response');
xlabel('Time of Day');
xticks([12:24:120]);
xticklabels({'12pm', '12pm','12pm', '12pm', '12pm'});
% xticks([6:6:120]);
% xticklabels({'6am', '12pm', '6pm', '12am', '6am', '12pm', '6pm', '12am', '6am', '12pm', '6pm', '12am',...
%     '6am', '12pm', '6pm', '12am', '6am', '12pm', '6pm', '12am'});
set(gcf,'color','white')
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',24)


disp(['Average Daily Energy Usage (KWh): ', num2str(usage/numDays)]);
disp(['Average Daily Energy Cost ($): ', num2str(cost/numDays)]);
disp(['Average Deviation from Set-point (Degrees): ', num2str(mean(abs(23 - TIN)))]);
disp(['Average PV Self-Consumption (%): ', num2str((1 - (PVsold/PVgen))*100)]);
set(gcf,'color','white')
