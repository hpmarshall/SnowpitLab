% plotBrundageDec24pit
% load_pitdata, and choose Brundage20241228_LV.xls
load Brundage20241228.mat
%%
figure(1);clf
subplot(1,8,3:8)
[P,AX,H]=PlotSnowpitProfile5(p,'hdtlgr')
axis(AX{3},[-7 0 0 193])
h=text(-1.5,161,'CT17, ECTN18'); set(h,'FontWeight','bold','FontSize',14)
h=text(-1.5,97,'CT21, ECTP25'); set(h,'FontWeight','bold','FontSize',14)
%%

subplot(1,8,1:2); cla
D=readtable('S19M0495_derivatives.csv')
semilogx(D.force_median_N_,198.25-D.distance_mm_/10,'k','linewidth',2)
set(gca,'FontSize',18,'FontWeight','bold')
xlabel('hardness [N]')
title('SMP profile')
axis([0 5 0 193])
% hold on
% D=readtable('/Users/hpmarshall/DATA_DRIVE/Brundage2025/SMP/S19M0495_derivatives.csv')
% semilogx(D.force_median_N_,194.5-D.distance_mm_/10,'r','linewidth',2)
% D=readtable('/Users/hpmarshall/DATA_DRIVE/Brundage2025/SMP/S19M0496_derivatives.csv')
% semilogx(D.force_median_N_,193.3-D.distance_mm_/10,'g','linewidth',2)
% D=readtable('/Users/hpmarshall/DATA_DRIVE/Brundage2025/SMP/S19M0497_derivatives.csv')
% semilogx(D.force_median_N_,195.5-D.distance_mm_/10,'b','linewidth',2)
% D=readtable('/Users/hpmarshall/DATA_DRIVE/Brundage2025/SMP/S19M0498_derivatives.csv')
% semilogx(D.force_median_N_,196.3-D.distance_mm_/10,'m','linewidth',2)
% D=readtable('/Users/hpmarshall/DATA_DRIVE/Brundage2025/SMP/S19M0499_derivatives.csv')
% semilogx(D.force_median_N_,196.5-D.distance_mm_/10,'y','linewidth',2)
%%
axis([0 5 90 193])
axis(AX{1},[-0.5 5.33 90 193])
axis(AX{2},[50 500 90 193])
axis(AX{3},[-7 0 90 193])





%%
