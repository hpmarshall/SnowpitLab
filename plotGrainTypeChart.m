function plotGrainTypeChart(gtype,C,S)
% gtype=basic grain type
% C = color to plot on top of
% S = string array from loading IACS data

Ix=strfind(S,gtype); % lets get the new snow ones
I2=[];
for n=1:length(Ix)
    if ~isempty(Ix{n,2})
        I2=[I2;n];
    end
end
if strcmp(gtype,'MF')
    I2=I2(1:end-1); % remove last MFcr
end
patch([0 1 1 0 0],[0 0 1 1 0],C); hold on
text(0.1,0.9,gtype,'FontSize',18,'FontWeight','bold')
text(0.5,0.9,S{I2(1),1}(1),'FontSize',30,'FontWeight','bold','FontName','SnowSymbolsIACS')
for n=2:length(I2)
    y=0.9-0.9/(length(I2)+1)*n;
    text(0.1,y,S{I2(n),2},'FontSize',14,'FontWeight','bold')
    text(0.6,y,S{I2(n),1}(1),'FontSize',24,'FontWeight','bold','FontName','SnowSymbolsIACS')
end
axis([0 1 0 1])
axis off