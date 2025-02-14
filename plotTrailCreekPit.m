figure('units','normalized','outerposition',[0 0 1 1])
subplot(1,7,1:3)
M=imread('NIRphoto3.tif');
imshow(M)
title('Near-Infrared (NIR) photography, 1000nm, Canon G9')
xlabel('Dust layer at C), many thin MF crusts in F)')
%%
subplot(1,7,4:6)
load TrailCreek022714pit.mat
PlotSnowpitProfile5(p,'hdtlgr')


%%

subplot(1,7,7)
%

y=[p.layer.top(:);p.layer.bot(:)];
x=[p.layer.moisture(:);p.layer.moisture(:)];
[Yx,Ix]=sort(y);
x=x(Ix);y=y(Ix);
plot(x,y,'k','LineWidth',4)
axis([1 5 0 77])
set(gca,'XTick',[1 2 3 4 5])
set(gca,'XTickLabel',{'D','M','W','V','S'})
title('LWC')
%%
%print('-dpng','-r300','TCS022714')

