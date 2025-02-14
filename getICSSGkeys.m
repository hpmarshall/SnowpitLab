% getICSSGkeys
fid=fopen('Char.txt');
n=1;
s=fgetl(fid)
while ischar(s)
    if sum(isspace(s))~=length(s) % if not just a bunch of spaces
        Ix=find(isspace(s)); % get the spaces
        nT=str2double(s(1:(Ix(1)-1)));
        if nT>0
            D(n,1)=nT
            S{n,1}=[s(Ix(1)+1:Ix(2)-1) s(Ix(2)+1:Ix(3)-1)];
            S{n,2}=[s(Ix(3)+1:Ix(4)-1)];
            S{n,3}=s(Ix(4)+1:end);
            n=n+1
        end
    end
    s=fgetl(fid);
end
fclose(fid)
save ICSSGkeys S D

%%
figure(1);clf;subplot(4,4,[1 5 9 13])
plotGrainTypeChart('PP',[0 1 0],S)
subplot(4,4,2);
plotGrainTypeChart('MM',[255 215 0]/255,S)
subplot(4,4,3)
plotGrainTypeChart('DF',[34 139 34]/255,S)
subplot(4,4,4)
plotGrainTypeChart('RG',[255 182 193]/255,S)
subplot(4,4,6)
plotGrainTypeChart('FC',[173 216 230]/255,S)
subplot(4,4,7)
plotGrainTypeChart('SH',[0 0 255]/255,S)
subplot(4,4,[11 15])
plotGrainTypeChart('DH',[255 0 255]/255,S)
subplot(4,4,[10 14])
plotGrainTypeChart('IF',[0 255 255]/255,S)
subplot(4,4,8)
plotGrainTypeChart('MF',[255 0 0]/255,S)
subplot(4,4,[12 16])
hold on
for n=1:10
    plot([0+n/10 0+n/10],[0 1],'LineWidth',3,'Color',[0.7 0.7 0.7]); hold on
end
S3={'Ob','Oc','Od','Oe','Of','Og','Oh'};
S4={'DF','RG','FC','SH','DH','MF'}
for n=2:length(S3)
    y=0.9-0.9/(length(S3))*(n-1);
    text(0.1,y,S4{n-1},'FontSize',18,'FontWeight','bold')
    text(0.6,y,S3{n},'FontSize',24,'FontWeight','bold','FontName','SnowSymbolsIACS')
end
text(0.1,0.9,'MFcr + XX','FontSize',18,'FontWeight','bold')








%% lets make a list
% gtype='PP';
% Ix=strfind(S,gtype); % lets get the new snow ones
% I2=[];
% for n=1:length(Ix)
%     if ~isempty(Ix{n,2})
%         I2=[I2;n];
%     end
% end
% figure(1);clf;
% subplot(1,3,1)
% patch([0 1 1 0 0],[0 0 1 1 0],[0 1 0]); hold on
% title('Precipitation Particles')
% text(0.25,0.9,gtype,'FontSize',18,'FontWeight','bold')
% text(0.5,0.9,S{I2(1),1}(1),'FontSize',30,'FontWeight','bold','FontName','SnowSymbolsIACS')
% for n=2:length(I2)
%     y=0.9-0.9/(length(I2)+2)*n;
%     text(0.25,y,S{I2(n),2},'FontSize',14,'FontWeight','bold')
%     text(0.75,y,S{I2(n),1}(1),'FontSize',24,'FontWeight','bold','FontName','SnowSymbolsIACS')
% end
% axis off
% %
% subplot(1,3,2)
% title('')
% gtype='MM';
% Ix=strfind(S,gtype); % lets get the new snow ones
% I2=[];
% for n=1:length(Ix)
%     if ~isempty(Ix{n,2})
%         I2=[I2;n];
%     end
% end
% patch([0 1 1 0 0],[0 0 0.3 0.3 0],[255 215 0]/255); hold on
% text(0.25,0.25,gtype,'FontSize',18,'FontWeight','bold')
% text(0.5,0.25,S{I2(1),1}(1),'FontSize',30,'FontWeight','bold','FontName','SnowSymbolsIACS')
% for n=2:length(I2)
%     y=0.25-0.25/(length(I2)+2)*n;
%     text(0.25,y,S{I2(n),2},'FontSize',14,'FontWeight','bold')
%     text(0.75,y,S{I2(n),1}(1),'FontSize',24,'FontWeight','bold','FontName','SnowSymbolsIACS')
% end
% axis([0 1 0 1])
% axis off