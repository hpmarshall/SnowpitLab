function [P,AX,H]=PlotSnowpitProfile5(p,type)
% plot a snowpit profile from SnowPitLAB
% INPUT:  p = structure array with snowpit data entered in SnowPitLAB
%        type = ['hdtgrn'] string used to determine what to plot:
%               h = hardness profile
%               d = density profile
%               t = temperature profile
%               g = grain type
%               r = grain size
%               l = labeled layers
%               n = notes for layer - in adjacent spreadsheet
%        fh = figure handle, if length(fh)==1
%           = axes handles if length(fh)==2
% OUTPUT:       P = updated structure array with snow pit data
%              AX = handles to 3 axes (hardness,density,temperature)
%               H  = handles to each plot object

%

% first check to see if we are including a spreadsheet
if ismember('n',type)
    figure; clf
    subplot(3,1,1:2)
end
hn=1;
maxy=0; maxx{1}=[];
% get the layer data
if isfield(p,'layer')
    layer=p.layer; % get the layer data
else
    layer=default_layer;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HARDNESS
hs=-0.5; % hardness starting point
if ismember('h',type) % if hardness plot
    AX{1}=gca;
    nl=length(layer.top);
    for n=1:nl
        hold on
        x=[hs,layer.hardness(n),layer.hardness(n),hs,hs];
        y=[layer.top(n),layer.top(n),layer.bot(n),layer.bot(n),layer.top(n)];
        H{n}=fill(x,y,[0.7 0.7 0.7]);
        hold on
        S3=hardnessIndex(layer.hardness(n))
        mid=mean([layer.top(n) layer.bot(n)]);
        text(0,mid,S3,'FontSize',14,'FontWeight','bold')
    end
    maxy=max([maxy max(layer.bot)]);
    maxx{1}=max(layer.hardness);
    hn=n+1;
else
    AX{1}=[];
end
grid on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dyax=0; % offset for 2 LH axes
%%% DENSITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember('d',type)  % if density plot
    if length(AX{1})>0
        axpos{1}=get(AX{1},'Position');
        axpos{2}=axpos{1};
        axpos{2}(2)=axpos{1}(2)+dyax; % move density axis up by dyax
        axpos{2}(4)=axpos{1}(4)-dyax; % make the tops coincide (shorten this one)
        AX{2} = axes('Position',axpos{2},...
            'XAxisLocation','bottom',...
            'YAxisLocation','left',...
            'Color','none',...
            'XColor','b','YColor','k');
    else
        AX{2}=gca;
        axpos{2}=get(AX{2},'Position');
    end
    hold on
    if isfield(p,'dprof')
        dprof=p.dprof; % get the density data
    else
        dprof=default_dprof;
    end
    mrho=mean(dprof.rho,2);
    rr=abs(diff(dprof.rho,1,2));
    %[mrho,rr]=cal_mean_str(dprof.rho); % calculate mean value of each entry
    mdepth=mean([dprof.top(:) dprof.bot(:)],2); % mean depth
    L=dprof.bot(:)-mdepth; % lower bound for error
    U=mdepth-dprof.top(:); % upper error bound
    axes(AX{2}); cla
    H{hn}=errorbar(mrho,mdepth,L,U,'bo-');% plot density
    hold on
    H{hn+1}=herrorbar(mrho,mdepth,rr/2,'bo-');% plot density range 
    set(H{hn},'LineWidth',3)
    set(H{hn+1},'LineWidth',3)
    maxy=max([maxy max(dprof.bot)]);
    maxx{2}=max(mrho+rr/2);
    hn=hn+2;
    set(gca,'FontSize',18,'FontWeight','bold')
else
    AX{2}=[];
end
%%%%%%%% TEMPERATURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('t',type)
    if length(AX{2})>0 % if density, make same
        axpos{3}=axpos{2};
        AX{3} = axes('Position',axpos{3},...
            'XAxisLocation','top',...
            'YAxisLocation','right',...
            'Color','none',...
            'XColor','r','YColor','r');
    else
        if length(AX{1})>0  % if hardness but no density
            axpos{1}=get(AX{1},'Position');
            axpos{3}=axpos{1};
            AX{3} = axes('Position',axpos{3},...
                'XAxisLocation','top',...
                'YAxisLocation','right',...
                'Color','none',...
                'XColor','r','YColor','r');
        else
            AX{3}=gca; % if neither density nor hardness
        end
    end
    hold on
    if isfield(p,'Tprof')
        Tprof=p.Tprof; % get the temperature data
    else
        Tprof=default_Tprof;
    end
    %[mT,Tr]=cal_mean_str(Tprof.temp); % same for T
    mT=Tprof.temp; Tr=0;
    axes(AX{3}); cla
    H{hn}=plot(mT,Tprof.depth,'ro-'); hold on
    %H{hn+1}=herrorbar(mT,Tprof.depth,Tr/2,'ro-'); 
    set(H{hn},'LineWidth',3)
    %set(H{hn+1},'LineWidth',3)
    maxy=max([maxy max(Tprof.depth)]);
    maxx{3}=max(-(mT-Tr))*1.3;
    hn=hn+2;
    set(gca,'FontSize',18,'FontWeight','bold')
else
    AX{3}=[];
end

%%%%%%% NOW THAT ITS PLOTTED, LETS FIX AXES, AXIS, AND LINE UP DEPTHS
%%% first figure out which of 3 plots were made
% lets first find limits of plot:
if maxy<10
    dy=1;
elseif (maxy>=10 && maxy<50)
    dy=5;
elseif (maxy>=50 && maxy<100)
    dy=10;
elseif maxy>=100
    dy=20;
end
for n=1:3
    if length(AX{n})>0
        set(AX{n},'YDir','normal')
        set(AX{n},'YTick',(0:dy:maxy))
        set(AX{n},'YTickLabel',num2str((0:dy:maxy)'))
        set(AX{n},'FontSize',18)
        switch n
            case 1
                axes(AX{n}); axis([hs 5.33 0 maxy])
                set(AX{1},'XTick',[1 2 3 4 5])
                set(AX{1},'XTickLabel',{' ',' ',' ',' ',' '}); %[{'F'},{'4-f'},{'1-f'},{'P'},{'K'}])
                %xlabel('hand hardness','FontSize',11)
                ylabel('depth [cm]')
            case 2
                axes(AX{n}); axis([50 500 0 maxy])
                set(AX{2},'XTick',(50:50:550))
                set(AX{2},'XTickLabel',num2str((50:50:550)'))
                xlabel('density [kg/m^3]','FontSize',18)
                ylabel('depth [cm]')
            case 3
                axes(AX{n}); axis([-20 0.25 0 maxy])
                set(AX{3},'XTick',(-10:2:0))
                set(AX{3},'XTickLabel',num2str((-10:2:0)'))
                set(AX{3},'YTickLabel','')
                ylabel(' ')
                xlabel('temperature [deg C]','FontSize',18)
                ylabel('depth [cm]')
        end
    end
end   
if ismember('hd',type) % if both density and temperature, adjust hardness scale
    axes(AX{1})
    axis([hs 5.33 0 maxy*axpos{1}(4)/axpos{2}(4)])
    ylabel('')
    axes(AX{2})
    if ismember('t',type)
        axes(AX{3})
    end
end

%%%%%%% GRAIN SIZE
if ismember('r',type)
    for n=1:length(layer.top)
        if n>1
            mid_old=mid;
        else
            mid_old=200;
        end
        mid=mean([layer.top(n) layer.bot(n)]);
        if mid_old-mid<2 % if layers are too close
            mid=mid-2
        end
        axes(AX{1})
        ht=text(0.5,mid,[num2str(layer.grainsize1(n)) '-' num2str(layer.grainsize2(n))]);
        set(ht,'FontSize',14,'FontWeight','bold')
    end
end
%%%%%% GRAIN TYPE
load ICSSGkeys
if ismember('g',type)
    for n=1:length(layer.top)
        if n>1
            mid_old=mid;
        else
            mid_old=200;
        end
        mid=mean([layer.top(n) layer.bot(n)]);
        if mid_old-mid<2 % if layers are too close
            mid=mid-2
        end
        axes(AX{1})
        Ix=find(~cellfun(@isempty,strfind(S(:,2),layer.graintype1{n})));
        if length(Ix)>1
            Ix=Ix(1)
        end
        %[cl,sc]=get_snowsymbol_keys(layer.graintype1{n});
        ht2=text(1.5,mid,layer.graintype1{n},'FontSize',14,'FontWeight','bold');
%        text(3,mid,S{Ix,1}(1),'FontSize',30,'FontWeight','bold','FontName','SnowSymbolsIACS')
        C2=getGrainTypeColor(S{Ix,2});
        set(H{n},'FaceColor',C2)
        if ~strcmp(layer.graintype1{n},layer.graintype2{n})
            Ix2=find(~cellfun(@isempty,strfind(S(:,2),layer.graintype2{n})));
        %    text(3.5,mid,[S{Ix2,1}(1) 'h'],'FontSize',30,'FontWeight','bold','FontName','SnowSymbolsIACS')
            ht2=text(2,mid,layer.graintype2{n},'FontSize',14,'FontWeight','bold');
        end
        if ischar(layer.graintype3{n})
            Ix3=find(~cellfun(@isempty,strfind(S(:,2),layer.graintype3{n})));
         %   text(4.5,mid,S{Ix3,1}(1),'FontSize',30,'FontWeight','bold','FontName','SnowSymbolsIACS')
            ht2=text(2.65,mid,layer.graintype3{n},'FontSize',14,'FontWeight','bold');
        end
    end
end
%%%%% LAYER LABEL
str='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
if ismember('l',type)
    for n=1:length(layer.top)
        if n>1
            mid_old=mid;
        else
            mid_old=200;
        end
        mid=mean([layer.top(n) layer.bot(n)]);
        if mid_old-mid<2 % if layers are too close
            mid=mid-2
        end
        axes(AX{1})
        ht=text(-0.5,mid,[str(n) ')']);
        set(ht,'FontSize',16,'FontWeight','bold','Color','w')
    end
end



% put axes in order
for n=1:3
    if length(AX{n})>0
        axes(AX{n})
    end
end
% 
% if ismember('n',type)
%     % set up the spreadsheet
%     progid = 'SGRID.SgCtrl.1';
%     FONTS='Font';
%     NCOL='LastCol';
%     NROW='LastRow';
%     LABEL=0;
%     %%%
%     htemp=subplot(3,1,3);
%     set(htemp,'Units','pixels')
%     gposition=get(htemp,'Position');
%     delete(htemp);
%     grid = actxcontrol(progid, gposition);
%     set(grid,'Row',0,'Col',0,'Text','Layer');
%     set(grid,'Row',1,'Col',0,'Text',' ');
%     set(grid,'Row',0,'Col',1,'Text','Grain size');
%     set(grid,'Row',1,'Col',1,'Text','[mm]');
%     set(grid,'Row',0,'Col',2,'Text','Grain Type');
%     set(grid,'Row',1,'Col',2,'Text','[Int]');
%     set(grid,'Row',0,'Col',3,'Text','Notes');
%     set(grid,'NColumns',4)
%     % now fill in the values
%     % fill in the spreadsheet with current values
%     for n=1:length(layer.top)
%         set(grid,'Row',n+1,'Col',0,'Text',str(n));
%         set(grid,'Row',n+1,'Col',1,'Text',num2str(layer.grainsize(n)));
%         set(grid,'Row',n+1,'Col',2,'Text',layer.graintype{n});
%         set(grid,'Row',n+1,'Col',3,'Text',layer.notes{n});
%     end
% end
% 


P=p;
%     AX{1}=gca;
%     set(AX{1},'YDir','reverse','XColor','b','YColor','k')
%     AX{2} = axes('Position',get(AX{1},'Position'),...
%            'XAxisLocation','top',...
%            'YAxisLocation','right',...
%            'Color','none',...
%            'XColor','r','YColor','k');
% else
%     % clear the two axes
%     AX{1}=fh(1);
%     AX{2}=fh(2);
%     axes(AX{1}); cla
%     axes(AX{2}); cla
% end



% % first lets plot density
% if ismember('dt',type)
%     dprof=p.dprof; Tprof=p.Tprof;
%     [mrho,rr]=cal_mean_str(dprof.rho); % calculate mean value of each entry
%     [mT,Tr]=cal_mean_str(Tprof.temp); % same for T
%     mdepth=mean([dprof.top(:) dprof.bot(:)],2); % mean depth
%     L=dprof.bot(:)-mdepth; % lower bound for error
%     U=mdepth-dprof.top(:); % upper error bound
%     %axes(gca); clf; % clear the current axes
%     axes(AX{1});
%     % plot density first
%     H{1}=errorbar(mrho,mdepth,L,U,'bo-');% plot density
%     hold on
%     H{2}=herrorbar(mrho,mdepth,rr/2,'bo-');% plot density range
%     TH(1)=xlabel('Density [kg/m^3]'); TH(2)=ylabel('Depth [cm]');
%     set(AX{1},'YDir','reverse','XColor','b')
%     % now lets plot temp on different axis
%     axes(AX{2});
%     hold on   
%     H{3}=plot(mT,Tprof.depth); hold on
%     H{4}=herrorbar(mT,Tprof.depth,Tr/2,'ro-');
%     TH(3)=xlabel('Temperature [deg C]'); TH(4)=ylabel('Depth [cm]');
%     set(AX{2},'YDir','reverse')
%     % lets fix the y-scales so they match
%     miny=min([(mdepth-U(:));Tprof.depth(:)]); maxy=max([(mdepth+L(:));Tprof.depth(:)]);
%     AX=cell2mat(AX(:)); % convert cell array to number
%     H=cell2mat(H(:));
%     set(AX,'YLim',[miny maxy])
%     if maxy<10
%         dy=1;
%     elseif (maxy>=10 & maxy<50)
%         dy=5;
%     elseif (maxy>=50 & maxy<100)
%         dy=10;
%     elseif maxy>=100
%         dy=20;
%     end
%     set(AX,'YTick',[0:dy:maxy]);
%     set(AX,'YTickLabel',num2str([0:dy:maxy]'))
%     set(AX,'FontSize',12,'FontWeight','bold')
%     set(H,'LineWidth',3)
%     set(AX(2),'XAxisLocation','top')
%     %set(H(1:3),'Color','b');
%     %set(H(3:6),'Color','r')
%     set(TH,'FontSize',11)
%     
%     %% lets save the calculated values
%     dprof.mrho=mrho;dprof.mdepth=mdepth';dprof.L=L';dprof.U=U';
%     dprof.rr=rr;
%     Tprof.mT=mT; Tprof.Tr=Tr;
%     P.dprof=dprof; P.Tprof=Tprof;
% elseif ismember('d',type) % plot only density
%     % get rid of temperature axes
%     axes(AX{2}); cla
%     set(AX{2},'XTickLabel',[],'YTickLabel',[],'XColor','k')
%     xlabel('');
%     dprof=p.dprof; 
%     [mrho,rr]=cal_mean_str(dprof.rho); % calculate mean value of each entry
%     mdepth=mean([dprof.top(:) dprof.bot(:)],2); % mean depth
%     L=dprof.bot(:)-mdepth; % lower bound for error
%     U=mdepth-dprof.top(:); % upper error bound
%     axes(AX{1});
%     H{1}=errorbar(mrho,mdepth,L,U,'bo-');% plot density
%     hold on
%     H{2}=herrorbar(mrho,mdepth,rr/2,'bo-');% plot density range
%     TH(1)=xlabel('Density [kg/m^3]'); TH(2)=ylabel('Depth [cm]');
%     set(AX{1},'YDir','reverse','XColor','b')
%     miny=min(mdepth-U(:)); maxy=max(mdepth+L(:))
%     AX=cell2mat(AX(:)); % convert cell array to number
%     set(AX,'YLim',[miny maxy])
%     if maxy<10
%         dy=1;
%     elseif (maxy>=10 & maxy<50)
%         dy=5;
%     elseif (maxy>=50 & maxy<100)
%         dy=10;
%     elseif maxy>=100
%         dy=20;
%     end
%     set(AX,'YTick',[0:dy:maxy]);
%     set(AX,'YTickLabel',num2str([0:dy:maxy]'))
%     set(AX,'FontSize',12,'FontWeight','bold')
%     set(cell2mat(H(:)),'LineWidth',3)
%     set(TH,'FontSize',11)
%     P.dprof=dprof;
% elseif ismember('t',type) % plot only temperature
%     Tprof=p.Tprof;
%     [mT,Tr]=cal_mean_str(Tprof.temp); % same for T
%     % get rid of density axes
%     axes(AX{1}); cla
%     set(AX{1},'XTickLabel',[],'YTickLabel',[],'XColor','k')
%     xlabel('');
%     % now lets plot temp 
%     axes(AX{2});
%     hold on   
%     H{1}=plot(mT,Tprof.depth); hold on
%     H{2}=herrorbar(mT,Tprof.depth,Tr/2,'ro-');
%     TH(1)=xlabel('Temperature [deg C]'); TH(2)=ylabel('Depth [cm]');
%     set(AX{2},'YDir','reverse')
%     miny=min(Tprof.depth); maxy=max(Tprof.depth)
%     AX=cell2mat(AX(:)); % convert cell array to number
%     set(AX,'YLim',[miny maxy])
%     if maxy<10
%         dy=1;
%     elseif (maxy>=10 & maxy<50)
%         dy=5;
%     elseif (maxy>=50 & maxy<100)
%         dy=10;
%     elseif maxy>=100
%         dy=20;
%     end
%     set(AX,'YTick',[0:dy:maxy]);
%     set(AX,'YTickLabel',num2str([0:dy:maxy]'))
%     set(AX,'FontSize',12,'FontWeight','bold')
%     set(cell2mat(H(:)),'LineWidth',3)
%     set(TH,'FontSize',11)
%     P.Tprof=Tprof;
% end    
%     
%  
function S=hardnessIndex(I2)
if I2==1
        S='F';
elseif (I2>1 & I2<2)
        S='F+';
elseif I2==2
        S='4F';
elseif (I2>2 & I2<3)
        S='4F+';
elseif (I2==3)
        S='1F';
elseif (I2>3 & I2<4)
        S='1F+';
elseif (I2==4)
        S='P';
elseif (I2>4 & I2<5)
        S='P+';
elseif I2==5
    S='K';
else
    disp('warning, hardness index not 1-5!')
end
S

function C=getGrainTypeColor(S)
S2=S(1:2);
switch S2
    case 'PP'
        C=[0 1 0];
    case 'MM'
        C=[255 215 0]/255;
    case 'DF'
        C=[34 139 34]/255;
    case 'RG'
        C=[255 182 193]/255;
    case 'FC'
        C=[173 216 230]/255;
    case 'DH'
        C=[255 0 255]/255;
    case 'IF'
        C=[0 255 255]/255;
    case 'MF'
        C=[255 0 0]/255;
end
