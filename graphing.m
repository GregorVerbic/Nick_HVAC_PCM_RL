%% PCM Curve
Tp = 27.6;
T1 = linspace(0,27.6, 1000);
T2 = linspace(27.6, 35, 400);
C1 = 1200 + 18800*exp((-(Tp-T1)./1.5));
C2 = 1300 + 18700*exp((-4*(Tp-T2).^2));
PCM = [C1,C2];
temp = [T1, T2];
PCM = PCM/1000;
plot(temp, PCM, 'linewidth',2)
hold on
Tp = 24.5;
T1 = linspace(0,24.5, 1000);
T2 = linspace(24.5, 35, 400);
C1 = 1200 + 18800*exp((-(Tp-T1)./1.5));
C2 = 1300 + 18700*exp((-4*(Tp-T2).^2));
PCM = [C1,C2];
temp = [T1, T2];
PCM = PCM/1000;
plot(temp, PCM, '--b', 'linewidth',2)
hold on
ylabel('C (kJ.kg^{-1}.K^{-1})');
xlabel('Temperature ({\circ}C)');
ylim([0 25]);
xlim([15 35]);
set(gcf,'color','white')
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',10)
hold off

%% PCM Curve KWH
Tp = 27.6;
T1 = linspace(0,27.6, 1000);
T2 = linspace(27.6, 35, 400);
C1 = 1200 + 18800*exp((-(Tp-T1)./1.5));
C2 = 1300 + 18700*exp((-4*(Tp-T2).^2));
PCM = [C1,C2];
temp = [T1, T2];
PCM = PCM*2805/3600000;
plot(temp, PCM)
xline(22,'--')
xline(28.5,'--')
ylabel('C (kWh.K^{-1})');
xlabel('Temperature (C{\circ})');
xlim([15 35]);
set(gcf,'color','white')

%% TOU
costTOU = [0.21340 0.21340 0.21340 0.21340 0.21340 0.21340...
        0.21340 0.38588 0.38588 0.37147 0.37147 0.37147...
        0.37147 0.37147 0.37147 0.37147 0.37147 0.38588...
        0.38588 0.38588 0.37147 0.37147 0.21340 0.21340];
A = [0.21340];
B = [0.38588];
C = [0.37147];
costTOU = [repmat(A,1,700), repmat(B,1,200),repmat(C,1,800),repmat(B,1,300),repmat(C,1,200),repmat(A,1,200)];
plot(costTOU, 'linewidth', 2)

ylabel('Tariff ($/kWh)');
xlabel('Time of Day');
xlim([1 2400])
xticks([600, 1200, 1800, 2400]);
xticklabels({'6am','12pm', '6pm', '12am'});
set(gcf,'color','white')
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',10)

%% PCMFIT
Tp = 27.6;
T1 = linspace(0,27.6, 1000);
T2 = linspace(27.6, 35, 400);
C1 = 1200 + 18800*exp((-(Tp-T1)./1.5));
C2 = 1300 + 18700*exp((-4*(Tp-T2).^2));
PCM = [C1,C2];
temp = [T1, T2];
PCM = PCM/1000;
load fitresult
Tpcm_fit = temp;
p1 = fitresult.p1; p2 = fitresult.p2; p3 = fitresult.p3;
p4 = fitresult.p4; p5 = fitresult.p5; p6 = fitresult.p6;
q1 = fitresult.q1; q2 = fitresult.q2; q3 = fitresult.q3;
q4 = fitresult.q4;

c_pcm_fit = (p1*Tpcm_fit.^5 +p2*Tpcm_fit.^4 + p3*Tpcm_fit.^3 + p4*Tpcm_fit.^2 + p5*Tpcm_fit + p6) ./ (Tpcm_fit.^4 + q1*Tpcm_fit.^3 + q2*Tpcm_fit.^2 + q3*Tpcm_fit + q4);

plot(temp, PCM, 'linewidth', 2)
hold on
plot(Tpcm_fit,c_pcm_fit/1000,'--', 'linewidth', 2)
ylabel({'C (kJ.kg^{-1}.K^{-1})'});
xlabel({'Temperature ({\circ}C)'});
legend({'PCM Curve', 'Fitted Curve'})

ylim([0 25]);
xlim([15 35]);
set(gcf,'color','white')
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',10)

%% Training Results
load trainingstats_7_10_2

reward = trainingStats.EpisodeReward;

plot(reward)
hold on
plot(movmean(reward,[0,30]), 'LineWidth',2)
xlabel('Episode')
ylabel('Reward')
legend('Episode Reward', 'Average Reward')
set(gcf,'color','white')
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',24)

%% Testing Data Temp
load('summer_temp.mat');
numDays = 5;
tout = day_data(:,1+27:numDays+27);
tout = reshape(tout,[],1);

plot(tout, 'linewidth', 2)
ylabel('Temperature (^{\circ}C)');
xlim([1 120])
xticks([12:24:120]);
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',30)
set(gcf,'color','white')
set(gca,'Xticklabel',[])

%% Testing Data PV
load('PV_output.mat');
numDays = 5;
PV = B{1}(:,1:numDays); 
PV = reshape(PV,[],1);
plot(PV,'linewidth', 2)
ylabel('Power (KW)')
xlim([1 120])
xticks([12:24:120]);
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',30)
set(gcf,'color','white')
set(gca,'Xticklabel',[])

%% Testing Data Load
load('load_data.mat');
numDays = 5;
ld = A{1}(:,1:numDays);
ld = reshape(ld,[],1);
plot(ld,'linewidth', 2)
ylabel('Power (KW)')
xlabel('Time of Day');
xlim([1 120])
xticks([12:24:120]);
xticklabels({'12pm', '12pm','12pm', '12pm', '12pm'});
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',30)
set(gcf,'color','white')

%% Training Temperature
load summer_temp.mat;
days = day_data(:, 1:31);
days = reshape(days,[],1);
plot(days,'linewidth',2)
ylabel('Temperature ({\circ}C)')
xlabel('Day');

xticks([108, 228, 348, 468, 588, 708]);
xticklabels({'5','10', '15','20','25','30'});
xlim([0,744])
set(gcf,'color','white')
set(gca,...
'Units','normalized',...
'FontUnits','points',...
'FontWeight','normal',...
'FontSize',26)

%% PCM2 with Fit
Tp = 24.5;
T1 = linspace(0,24.5, 1000);
T2 = linspace(24.5, 35, 400);
C1 = 1200 + 18800*exp((-(Tp-T1)./1.5));
C2 = 1300 + 18700*exp((-4*(Tp-T2).^2));
PCM = [C1,C2];
temp = [T1, T2];
PCM = PCM/1000;
load fitresult2
Tpcm_fit = temp;
p1 = fitresult.p1; p2 = fitresult.p2; p3 = fitresult.p3;
p4 = fitresult.p4; p5 = fitresult.p5; p6 = fitresult.p6;
q1 = fitresult.q1; q2 = fitresult.q2; q3 = fitresult.q3;
q4 = fitresult.q4;

c_pcm_fit = (p1*Tpcm_fit.^5 +p2*Tpcm_fit.^4 + p3*Tpcm_fit.^3 + p4*Tpcm_fit.^2 + p5*Tpcm_fit + p6) ./ (Tpcm_fit.^4 + q1*Tpcm_fit.^3 + q2*Tpcm_fit.^2 + q3*Tpcm_fit + q4);

plot(temp, PCM)
hold on
plot(Tpcm_fit,c_pcm_fit/1000)
ylabel('C (kJ.kg^{-1}.K^{-1})');
xlabel('Temperature (C{\circ})');
ylim([0 25]);
xlim([15 30]);
legend('PCM Curve', 'Fitted Curve')
set(gcf,'color','white')






