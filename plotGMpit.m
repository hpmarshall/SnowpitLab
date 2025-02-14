% plotGMpit
load SnowPitDataGM20240327_NS23b.mat
p.layer.graintype2=p.layer.graintype1; % hack
subplot(1,8,1:4)
PlotSnowpitProfile5(p,'hdtlgr')
subplot(1,8,5:6)
z=145-[0 37.5 37.5 60];
vs=[331.6 331.6 703 703];
plot(vs,z,'r','linewidth',3)
set(gca,'FontSize',18,'FontWeight','bold')
axis([100 900 0 145])
title('Seismic survey')
xlabel('V_s [m/s]')
%% now add shear wave velocity from density data
rho=p.dprof.rho;
vsrho=0.0005909*rho.^2+2.216*rho-216.4;
mvs=mean(vsrho,2);
rr=abs(diff(vsrho,1,2));
mdepth=mean([p.dprof.top(:) p.dprof.bot(:)],2); % mean depth
L=p.dprof.bot(:)-mdepth; % lower bound for error
U=mdepth-p.dprof.top(:); % upper error bound
subplot(1,8,5:6); hold on
h1=errorbar(mvs,mdepth,L,U,'bo-','linewidth',2);% plot density
h2=herrorbar(mvs,mdepth,rr/2,'bo-');% plot density range
set(h2,'linewidth',2)
plot(vs,z,'r','linewidth',5)

subplot(1,8,7:8)
D=readtable('S19M0310_pitns23.csv')
plot(D.force_median,145-D.distance/10,'k','linewidth',2)
set(gca,'FontSize',18,'FontWeight','bold')
xlabel('hardness [N]')
title('SMP profile')
axis([0 20 0 145])





%%
