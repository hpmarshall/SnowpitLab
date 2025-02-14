function varargout = LoadSnowPIT(varargin)

% Load manual snow pit data from a standard Excel template into matlab.
% The format will be in the SnowpitLAB_v18 format for ease of plotting
% This code will load either the old or new International Classification
% for Seasonal Snow on the Ground, which can be found in the SWAG manual
% The spread sheet uses standard information that is found in the most
% rescent SWAG manual.

% 20110423 Scott Havens
% LoadSnowPIT is up and running.  All known major bugs have been fixed.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 20110510 Updated Scott Havens
% Fixed:
%   1. The GUI will skip empty worksheets, but not worksheets that have
%      information on them.
%   2. If only one hardness column is filled out, it will not affect
%      loading in the data.
%   3. Checks density and temperature, if density was not filled out 
%      correctly, it will not be able to plot and will display an error 
%      message.
%
% 20130311 Scott Havens
%       - More robust determination of the number of temperature layers.
%       This can now handle the last temperature value to be the end of
%       file.
%       - .xlsx format now produces a NaN value for an empty sheet.  This
%       is now supported and will be ignored.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%LOADSNOWPIT M-file for LoadSnowPIT.fig
%      LOADSNOWPIT, by itself, creates a new LOADSNOWPIT or raises the existing
%      singleton*.
%
%      H = LOADSNOWPIT returns the handle to a new LOADSNOWPIT or the handle to
%      the existing singleton*.
%
%      LOADSNOWPIT('Property','Value',...) creates a new LOADSNOWPIT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to LoadSnowPIT_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LOADSNOWPIT('CALLBACK') and LOADSNOWPIT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LOADSNOWPIT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LoadSnowPIT

% Last Modified by GUIDE v2.5 29-Apr-2011 13:02:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @LoadSnowPIT_OpeningFcn, ...
    'gui_OutputFcn',  @LoadSnowPIT_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LoadSnowPIT is made visible.
function LoadSnowPIT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for LoadSnowPIT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LoadSnowPIT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LoadSnowPIT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in BrowseFiles.
function BrowseFiles_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% First determine which platform MATLAB is running on.  Unfortunately,
% MATLAB xlsread/xlsfinfo doesn't run on a mac.  Just saving people time
%
% xlsread/xlsfinfo also isn't supper compatiable with LINUX/UNIX for newer
% verions of Excel.  Saving in Excel 5.0/95 will import the data.

if isunix || ismac
    mtxt = sprintf('You are on a LINUX/UNIX machince.  To import Excel data, convert file to Excel 5.0/95.\n\nIs the file in Excel 5.0/95?');
    
    % Construct a questdlg with two options
    choice = questdlg(mtxt, ...
        'Load Pit Data Warning', ...
        'Sure is','Not Yet','Try Anyway','Sure is');
    
    % Handle response
    if strcmp('Not Yet',choice)
        errordlg('Save file in Excel 5.0/95 and try again')
        return
        
    end
end

% Excel pit file path
if ispc
    [FileName,PathName] = uigetfile({'*.xlsx';'*.xls'},'Select Excel File with Snow Pit Data');
    
elseif isunix || ismac
    [FileName,PathName] = uigetfile({'*.xls';'*.xlsx'},'Select Excel File with Snow Pit Data');
    
end

if isequal(FileName,0)
    error('User selected Cancel, file has not been converted.')
end

handles.PathName = fullfile(PathName, FileName); %full path name

set(handles.display_FileName,'String',...
    sprintf('File Seclected:\n%s',FileName)); %display file name

% Update handles structure
guidata(hObject,handles)

% --- Executes on button press in LoadData.
function LoadData_Callback(hObject, eventdata, handles)
% hObject    handle to LoadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check the Excel file and get the sheet names
[typ, sheets] = xlsfinfo(handles.PathName);

% loop through each sheet and load data
for n = 1:length(sheets)
    
    % load pit data in sheet
    [num, txt, raw] = xlsread(handles.PathName,sheets{n});
    
    if ~isempty(raw) && size(raw,1)>1
        % set up site characteristics from beginning of file
        p(n).Obs = raw{3,2}; % observer names
        
        %get date
        dt = raw{1,2}; % date, convert to [YYYY MM DD]
        
        if isempty(dt) %make sure there is a date
            error('No date set for pit')
        elseif isnumeric(dt) %convert to a string for regexp
            dt = int2str(dt);
        end
        
        if ~isempty(regexp(dt,'\d{2}.\d{2}.\d{4}','match')) % [MM/DD/YYYY]
            date_vec = datestr(dt);
            
        elseif ~isempty(regexp(dt,'\d{8}','match')) %[YYYYMMDD]
            date_vec = [str2double(dt(1:4)) str2double(dt(5:6)) str2double(dt(7:8))];
            
        else
            error('Date is not in correct format.  Either [YYYYMMDD] or [MM/DD/YYYY].')
        end
        
        % get time
        tm = raw{2,2}; % time, convert to [HH MM SS]
        
        if isempty(tm) %make sure there is a time
            error('No time set for pit')
        elseif isnumeric(tm) %convert to a string for regexp
            tm = int2str(tm);
        end
        
        if ~isempty(regexp(tm,'\d{4}','match')) % [HHMM]
            tm_vec = [str2double(tm(1:2)) str2double(tm(3:4)) 0];
            
        elseif ~isempty(regexp(tm,'\d{3}','match')) % [HMM]
            tm_vec = [str2double(tm(1)) str2double(tm(2:3)) 0 ];
            
        elseif ~isempty(regexp(tm,'\d{2}.\d{2}','match')) % [HH:MM]
            tm_vec = [str2double(tm(1:2)) str2double(tm(4:5)) 0];
            
        elseif ~isempty(regexp(tm,'\d{1}.\d{2}','match')) % [H:MM]
            tm_vec = [str2double(tm(1)) str2double(tm(3:4)) 0];
            
        else
            error('Time not in correct format in spreadsheet.  Either [HHMM] or [HH:MM].')
            
        end
        
        % order in structure array
        p(n).Date = datestr([date_vec tm_vec]);
        p(n).Loc = raw{4,2}; % site name
        p(n).Pit = raw{5,2}; % pit number
        p(n).Aspect = raw{6,2};
        p(n).Elevation = raw{7,2};
        p(n).SlopeAngle = raw{8,2};
        p(n).Precipitation = raw{9,2};
        p(n).SkyCover = raw{10,2};
        p(n).AirTemp = raw{11,2};
        p(n).Wind = raw{12,2};
        p(n).UTME = raw{13,2};
        p(n).UTMN = raw{14,2};
        p(n).notes = raw{15,2};
        
        % now load the layer data into p.layer
        x = strmatch('LAYERS',txt); %location of the header
        [I, J] = ind2sub(size(txt),x);
        
        % determine how many layers there are
        stop_flag = 0;
        nlay = 1;
        while stop_flag == 0
            if ~isnan(raw{I+2+nlay,1})
                nlay = nlay + 1;
            else
                stop_flag = 1;
            end
        end
        
        % get the layer data in the snowpitLAB format
        for r = 1:nlay
            
            p(n).layer.top(r) = raw{I+1+r,1};
            p(n).layer.bot(r) = raw{I+1+r,2};
            p(n).layer.grainsize1(r) = raw{I+1+r,8};
            p(n).layer.grainsize2(r) = raw{I+1+r,9};
            p(n).layer.grainsize3(r) = raw{I+1+r,10};
            p(n).layer.graintype1{1,r} = raw{I+1+r,5};
            p(n).layer.graintype2{1,r} = raw{I+1+r,6};
            p(n).layer.graintype3{1,r} = raw{I+1+r,7};
            p(n).layer.moisture(r) = raw{I+1+r,11};
            p(n).layer.hardness(r) = nanmean([raw{I+1+r,3} raw{I+1+r,4}]); %mean hardness
            p(n).layer.notes{1,r} = raw{I+1+r,12};
            
        end
        
        % load the density data
        x = strmatch('DENSITY',txt); %location of the header
        [I, J] = ind2sub(size(txt),x);
        
        % determine how many layers there are
        stop_flag = 0;
        nlay = 1;
        while stop_flag == 0
            if ~isnan(raw{I+3+nlay,1})
                nlay = nlay + 1;
            else
                stop_flag = 1;
            end
        end
        
        % get the density data
        warn = [];
        if nlay > 1
            for r = 1:nlay
                p(n).dprof.top(1,r) = raw{I+2+r,1};
                p(n).dprof.bot(1,r) = raw{I+2+r,2};
                p(n).dprof.rho(r,:) = [raw{I+2+r,5} raw{I+2+r,6}];
                
                if sum(isnan(p(n).dprof.rho(r,:))) == 2 % no values for both
                    warn = cat(1,warn,...
                        {sprintf('Layer: %g - %g',p(n).dprof.top(1,r),p(n).dprof.bot(1,r))});
                end
            end
        end
        
        if ~isempty(warn) %save the warnings
            handles.DensityWarning = warn;
        else
            handles.DensityWarning = [];
        end
        
        % load the temperature data
        x = strmatch('TEMPERATURE',txt); %location of the header
        [I, J] = ind2sub(size(txt),x);
        
        % determine how many layers there are
        stop_flag = 0;
        nlay = 0;
        while stop_flag == 0
            if size(raw,1) >= I+2+nlay       % not at the end of the file
                if ~isnan(raw{I+2+nlay,1})
                    nlay = nlay + 1;
                else
                    stop_flag = 1;
                end
            else
                stop_flag = 1;
            end
        end
        
        % get the temperature data
        warn = [];
        if nlay > 0
            for r = 1:nlay
                p(n).Tprof.depth(1,r) = raw{I+1+r,1};
                p(n).Tprof.temp(1,r) = raw{I+1+r,2};
                
                % no values for temperature or location
                if isnan(p(n).Tprof.temp(1,r)) && isnan(p(n).Tprof.depth(1,r))
                    warn = 1;
                end
            end
            
            if mean(mean(isnan([p(n).Tprof.depth; p(n).Tprof.temp])))
                % all bad points
                p(n).Tprof = [];
            end
        end
        
        if nlay == 0 | warn % no temperature data
           handles.TemperatureWarning = 'Bad or no temperature data';
        else
            handles.TemperatureWarning = [];
        end
        
        % make any fields with NaN values blank
        fnames = fieldnames(p(n));
        for f = 1:length(fnames)
            if ~isstruct(p(n).(fnames{f}))
                if isnan(p(n).(fnames{f}))
                    p(n).(fnames{f}) = [];
                end
            end
        end
    end
end

% load pitsample.mat
handles.p = p;

% for pulldown, needs to be strings.  Determine if it's a string or not and
% correct
for n = 1:length(p)
    
    if ischar(p(n).Loc)
        str = p(n).Loc;
    else
        str = num2str(p(n).Loc);
    end
    
    if ischar(p(n).Pit)
        str = [str ' - ' p(n).Pit];
    else
        str = [str ' - ' num2str(p(n).Pit)];
    end
    
    handles.PitNames{n} = str;
end

% load names into the profile pop down menu
SelectPit_CreateFcn(handles.SelectPit, eventdata, handles);

handles.PitIndex = 1; %value of pop up pick, this is the same as the index in loaded data

% if the buttons have already been checked, do not change.  If this the
% first run, initialize PlotType
if ~isfield(handles,'PlotType')
    handles.PlotType = [];
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in SelectPit.
function SelectPit_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectPit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectPit

handles.PitIndex = get(hObject,'Value'); %value of pop up pick, this is the same as the index in loaded data

% if the buttons have already been checked, do not change.  If this the
% first run, initialize PlotType
if ~isfield(handles,'PlotType')
    handles.PlotType = [];
end

% Update handles structure
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function SelectPit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectPit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% load the profile names after the data is loaded
if isfield(handles,'PitNames');
    set(hObject,'String',handles.PitNames);
end

% --- Executes on button press in PlotPit.
function PlotPit_Callback(hObject, eventdata, handles)
% hObject    handle to PlotPit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the user selected values
p = handles.p(handles.PitIndex);
type = handles.PlotType;

% if no check boxes selected
if isempty(type)
    % Construct a questdlg with one options
    errordlg('Need to select plot options.','Plot Options');
end

% cla(handles.Axes_Pit);
if isfield(handles,'AX')
    AX = handles.AX;
else
    AX = [0 0 0];
end

%set AX(1) at start
if AX(1) == 0
    AX(1) = handles.Axes_Pit;
end

% get the layer data
if isfield(p,'layer')
    layer = p.layer; % get the layer data
else
    display('No layer information included in data')
end

% set axes properties
dyax=0.1; % offset for 2 LH axes

cla(AX(1),'reset')
cla(AX(2),'reset')
cla(AX(3),'reset')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set a few parameters first
hs = -0.5; % hardness starting point
maxy = layer.top(1); %starting point for top

% HARDNESS
if ismember('h',type) % if hardness plot
    
    axes(AX(1))
    for n = 1:length(layer.top)
        
        hold on
        % create boundaries for hardness profile boxes
        x = [hs,layer.hardness(n),layer.hardness(n),hs,hs];
        y = [layer.top(n),layer.top(n),layer.bot(n),layer.bot(n),layer.top(n)];
        Hhard{n} = fill(x,y,[0.7 0.7 0.7],'Parent',AX(1));
        
    end
    maxy = max(layer.top); %get the max height of the plot
    maxx{1} = max(layer.hardness); %get the max width of the plot
    
end

%%% DENSITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember('d',type)  % if density plot
    
    % check to see if density is loaded
    if isfield(p,'dprof')
        if isempty(p.dprof)
            errordlg('No density data loaded','Density Error')
            return
        end
    else
        errordlg('No density data loaded','Density Error')
        return
    end
    
    %something is wrong with the density
    if ~isempty(handles.DensityWarning) 
        str = sprintf('\t%s\n',handles.DensityWarning{:});
        str = sprintf('Error: The following layers do not have a density associated with them:\n\n%s',str);
        errordlg(str,'Density Error')
        return
    end
    
    % have to recreate the position
    if AX(1) ~= 0 % already hardness
        axpos{1} = get(AX(1),'Position'); %hardness axis position
    else % no hardness
        axpos{1} = get(handles.Axes_Pit,'Position'); %hardness axis position
    end
    
    axpos{2} = axpos{1};
    axpos{2}(2) = axpos{1}(2)+dyax; % move density axis up by dyax
    axpos{2}(4) = axpos{1}(4)-dyax; % make the tops coincide (shorten this one)
    
    % if first density run create axis
    if AX(2) == 0
        AX(2) = axes('Position',axpos{2},'Tag','density');
        
        % already density axis, reset properties
    else % AX(2) ~= 0
        set(AX(2),'Position',axpos{2},'Tag','density','Visible','on')
    end
    %     hold on
    if isfield(p,'dprof')
        dprof=p.dprof; % get the density data
    else
        display('No density data included')
    end
    
    % calculate density stats
    mean_rho = nanmean(dprof.rho,2); % calculate mean value of each entry
    rL = mean_rho - nanmin(dprof.rho,[],2);
    rR = nanmax(dprof.rho,[],2) - mean_rho;
    mean_depth = nanmean([dprof.top(:) dprof.bot(:)],2); % mean depth
    dU = dprof.top(:) - mean_depth; % lower bound for error
    dL = mean_depth - dprof.bot(:); % upper error bound
    
    % plot densities and error bounds
    axes(AX(2))
    Hden{1} = errorbar(mean_rho,mean_depth,dL,dU,'bo-','Parent',AX(2));% plot mean density
    hold on
    Hden{2} = herrorbar_axis(mean_rho,mean_depth,rL,rR,'bo-',AX(2));% plot density range
    %     end
    set(Hden{1},'LineWidth',1)
    set(Hden{2}(1),'LineWidth',1)
    set(Hden{2}(2),'LineWidth',1)
    set(AX(2),'XColor','b','Color','none',...
        'YAxisLocation','left') %update figure properties
    
    maxy = max([maxy max(dprof.top)]); %top of plot max
    maxx{2} = max(mean_rho+rR); %right of plot max
    
end
%%%%%%%% TEMPERATURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('t',type)
    
    %something is wrong with the temperature
    if ~isempty(handles.TemperatureWarning) 
        errordlg(handles.TemperatureWarning,'Temperature Error')
        return
    end
    
    % have to recreate the position
    if AX(1) ~= 0 % already hardness
        axpos{1} = get(AX(1),'Position'); %hardness axis position
    else % no hardness
        axpos{1} = get(handles.Axes_Pit,'Position'); %hardness axis position
    end
    
    axpos{3} = axpos{1};
    axpos{3}(2) = axpos{1}(2)+dyax; % move density axis up by dyax
    axpos{3}(4) = axpos{1}(4)-dyax; % make the tops coincide (shorten this one)
    
    if AX(3) == 0 % no  temperature
        
        AX(3) = axes('Position',axpos{3},...
            'YAxisLocation','left','YColor','k',...
            'Tag','Temperature');
        
        % There is already temperature
    else % AX(3) ~= 0
        set(AX(3),'Position',axpos{3},'Tag','Temperature','Visible','on');%,...
        
    end
    
    if isfield(p,'Tprof')
        Tprof=p.Tprof; % get the temperature data
    else
        display('No temperature data')
    end
    
    axes(AX(3))
    Htemp = plot(AX(3),Tprof.temp,Tprof.depth,'ro-');
    set(Htemp,'LineWidth',1)
    set(AX(3),'XColor','r','Color','none',...
        'XAxisLocation','top') %update figure properties
    
    maxy = max([maxy max(Tprof.depth)]);
    maxx{3} = max(-(Tprof.temp));
    
end

%%%%%%% NOW THAT ITS PLOTTED, LETS FIX AXES, AXIS, AND LINE UP DEPTHS
%%% first figure out which of 3 plots were made
% lets first find limits of plot:

for n = 1:3
    switch n
        case 1
            if ismember('h',type)
                axes(AX(n));
                set(AX(1),'FontSize',12,'Fontweight','bold')
                if ismember('hd',type)
                    axpos{1} = get(AX(1),'Position'); %hardness axis position
                    axpos{2} = get(AX(2),'Position');
                    axis([hs 5.33 -maxy*(axpos{1}(4)/axpos{2}(4)-1) maxy]);
                elseif ismember('ht',type)
                    axpos{1} = get(AX(1),'Position'); %hardness axis position
                    axpos{3} = get(AX(3),'Position');
                    axis([hs 5.33 -maxy*(axpos{1}(4)/axpos{3}(4)-1) maxy]);
                else
                    axis([hs 5.33 0 maxy])
                end
                set(AX(1),'XTick',[1 2 3 4 5],...
                    'XTickLabel',[{'F'},{'4-f'},{'1-f'},{'P'},{'K'}])
                xlabel('Hand Hardness','FontSize',11,'Fontweight','bold')
            end
        case 2
            if ismember('d',type)
                set(AX(2),'FontSize',12,'Fontweight','bold')
                axes(AX(n));
                axis([0 maxx{2}+20 0 maxy])
                xlabel('Density [kg/m^3]','FontSize',11,'Fontweight','bold')
            elseif ~ismember('d',type) && AX(2)~=0
                set(AX(2),'Color','none','Visible','off')
            end
        case 3
            if ismember('t',type)
                set(AX(3),'FontSize',12,'Fontweight','bold')
                axes(AX(n));
                axis([-maxx{3}-0.5 0 0 maxy])
                xlabel('Temperature [deg C]','FontSize',11,'Fontweight','bold')
            elseif ~ismember('t',type) && AX(3)~=0
                set(AX(3),'Color','none','Visible','off')
            end
    end
end

ylabel('Depth [cm]','Fontsize',12,'Fontweight','bold')

%remove the hardness depths
if ismember('hd',type) | ~ismember('h',type) | ismember('ht',type)
    set(AX(1),'YTick',[],'YTickLabel',[]);
    if ~ismember('h',type) %if no hardness remove labels
        set(AX(1),'XTick',[],'XTickLabel',[]);
    end
end

%set axis for grain type, size, and label
if AX(1) ~= 0
    ax = AX(1); %if hardness, set as current axis
else
    ax = handles.Axes_Pit;
end

if sum(ismember('rg',type))
    for n = 1:length(layer.top)
        mid = mean([layer.top(n) layer.bot(n)]);
        
        if ismember('r',type)
            size = [nanmin([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])...
                nanmax([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])];
            
            if isnan(size) %no grainsize given
                t = '      ';
            else
                t = [num2str(size(1)) ' - ' num2str(size(2))];
            end
            
        else
            t = [];
        end
        
        if ismember('g',type)
            
            if ~isnan(layer.graintype1{n})
                t = [t ' ' layer.graintype1{n}];
            end
            if ~isnan(layer.graintype2{n})
                t = [t ' ' layer.graintype2{n}];
            end
            if ~isnan(layer.graintype3{n})
                t = [t ' (' layer.graintype3{n} ')'];
            end
        end
        
        %         axes(ax)
        ht = text(-0.25,mid,t,'Parent',ax);
        set(ht,'FontSize',11,'FontWeight','bold')
    end
end

%%%%% LAYER LABEL
str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
if ismember('l',type)
    %     axes(ax)
    for n = 1:length(layer.top)
        mid = mean([layer.top(n) layer.bot(n)]);
        ht = text(-0.4,mid,[str(n) ')'],'Parent',ax);
        set(ht,'FontSize',11,'FontWeight','bold','Color','w')
    end
end

% put axes in order
% for n = 1:3
%     if AX(n)
%         axes(AX(n))
%     end
% end

handles.AX = AX;
hold off

% Update handles structure
guidata(hObject,handles);

% --- Executes on button press in Density.
function Density_Callback(hObject, eventdata, handles)
% hObject    handle to Density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Density

if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take appropriate action
    handles.PlotType = [handles.PlotType 'd'];
    
else
    % Checkbox is not checked-take appropriate action
    loc = ismember(handles.PlotType,'d');
    handles.PlotType(loc) = []; %remove plot style
end

% Update handles structure
guidata(hObject,handles);

% --- Executes on button press in Hardness.
function Hardness_Callback(hObject, eventdata, handles)
% hObject    handle to Hardness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Hardness
if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take appropriate action
    handles.PlotType = [handles.PlotType 'h'];
    
else
    % Checkbox is not checked-take appropriate action
    loc = ismember(handles.PlotType,'h');
    handles.PlotType(loc) = []; %remove plot style
end

% Update handles structure
guidata(hObject,handles);

% --- Executes on button press in Temperature.
function Temperature_Callback(hObject, eventdata, handles)
% hObject    handle to Temperature (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Temperature
if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take appropriate action
    handles.PlotType = [handles.PlotType 't'];
    
else
    % Checkbox is not checked-take appropriate action
    loc = ismember(handles.PlotType,'t');
    handles.PlotType(loc) = []; %remove plot style
end

% Update handles structure
guidata(hObject,handles);

% --- Executes on button press in GrainSize.
function GrainSize_Callback(hObject, eventdata, handles)
% hObject    handle to GrainSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GrainSize
if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take appropriate action
    handles.PlotType = [handles.PlotType 'r'];
    
else
    % Checkbox is not checked-take appropriate action
    loc = ismember(handles.PlotType,'r');
    handles.PlotType(loc) = []; %remove plot style
end

% Update handles structure
guidata(hObject,handles);

% --- Executes on button press in GrainType.
function GrainType_Callback(hObject, eventdata, handles)
% hObject    handle to GrainType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GrainType
if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take appropriate action
    handles.PlotType = [handles.PlotType 'g'];
    
else
    % Checkbox is not checked-take appropriate action
    loc = ismember(handles.PlotType,'g');
    handles.PlotType(loc) = []; %remove plot style
end

% Update handles structure
guidata(hObject,handles);

% --- Executes on button press in LayerLabel.
function LayerLabel_Callback(hObject, eventdata, handles)
% hObject    handle to LayerLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LayerLabel
if (get(hObject,'Value') == get(hObject,'Max'))
    % Checkbox is checked-take appropriate action
    handles.PlotType = [handles.PlotType 'l'];
    
else
    % Checkbox is not checked-take appropriate action
    loc = ismember(handles.PlotType,'l');
    handles.PlotType(loc) = []; %remove plot style
end

% Update handles structure
guidata(hObject,handles);


% --- Executes on button press in SavePitData.
function SavePitData_Callback(hObject, eventdata, handles)
% hObject    handle to SavePitData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

p = handles.p;
uisave('p','SnowPitData.mat')

% --- Executes on button press in SaveImage.
function SaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% have user select a location and extension
[filename, ext, user_canceled] = imputfile;

%if user cancels save command, nothing happens
if user_canceled
    return
end

h = figure;
PlotSnowpitProfile4(handles.p(handles.PitIndex),handles.PlotType);
set(h,'PaperUnits','inches','PaperPosition',[0 0 8 6])

saveas(h,filename,ext)

close(h)

function hh = herrorbar_axis(x, y, l, u, symbol,axis_handle)

% 20110421 Scott Havens: Update with axis_handle to plot on a specific axis

%HERRORBAR Horizontal Error bar plot.
%   HERRORBAR(X,Y,L,R) plots the graph of vector X vs. vector Y with
%   horizontal error bars specified by the vectors L and R. L and R contain the
%   left and right error ranges for each point in X. Each error bar
%   is L(i) + R(i) long and is drawn a distance of L(i) to the right and R(i)
%   to the right the points in (X,Y). The vectors X,Y,L and R must all be
%   the same length. If X,Y,L and R are matrices then each column
%   produces a separate line.
%
%   HERRORBAR(X,Y,E) or HERRORBAR(Y,E) plots X with error bars [X-E X+E].
%   HERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'. See PLOT for possibilities.
%
%   H = HERRORBAR(...) returns a vector of line handles.
%
%   Example:
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      herrorbar(x,y,e)
%   draws symmetric horizontal error bars of unit standard deviation.
%
%   This code is based on ERRORBAR provided in MATLAB.
%
%   See also ERRORBAR

%   Jos van der Geest
%   email: jos@jasen.nl
%
%   File history:
%   August 2006 (Jos): I have taken back ownership. I like to thank Greg Aloe from
%   The MathWorks who originally introduced this piece of code to the
%   Matlab File Exchange.
%   September 2003 (Greg Aloe): This code was originally provided by Jos
%   from the newsgroup comp.soft-sys.matlab:
%   http://newsreader.mathworks.com/WebX?50@118.fdnxaJz9btF^1@.eea3ff9
%   After unsuccessfully attempting to contact the orignal author, I
%   decided to take ownership so that others could benefit from finding it
%   on the MATLAB Central File Exchange.

if min(size(x))==1,
    npt = length(x);
    x = x(:);
    y = y(:);
    if nargin > 2,
        if ~isstr(l),
            l = l(:);
        end
        if nargin > 3
            if ~isstr(u)
                u = u(:);
            end
        end
    end
else
    [npt,n] = size(x);
end

if nargin == 3
    if ~isstr(l)
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [m,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);;
    end
end

if nargin == 4
    if isstr(u),
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end

if nargin == 2
    l = y;
    u = y;
    y = x;
    [m,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);;
    symbol = '-';
end

u = abs(u);
l = abs(l);

if isstr(x) | isstr(y) | isstr(u) | isstr(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~isequal(size(x),size(l)) | ~isequal(size(x),size(u)),
    error('The sizes of X, Y, L and U must be the same.');
end

tee = (max(y(:))-min(y(:)))/100; % make tee .02 x-distance for error bars
% changed from errorbar.m
xl = x - l;
xr = x + u;
ytop = y + tee;
ybot = y - tee;
n = size(y,2);
% end change

% Plot graph and bars
hold_state = ishold;
cax = newplot;
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
% changed from errorbar.m
xb = zeros(npt*9,n);
xb(1:9:end,:) = xl;
xb(2:9:end,:) = xl;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xl;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xr;
xb(8:9:end,:) = xr;
xb(9:9:end,:) = NaN;

yb = zeros(npt*9,n);
yb(1:9:end,:) = ytop;
yb(2:9:end,:) = ybot;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = y;
yb(5:9:end,:) = y;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ytop;
yb(8:9:end,:) = ybot;
yb(9:9:end,:) = NaN;
% end change


[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot(axis_handle,xb,yb,esymbol); hold on
h = [h;plot(axis_handle,x,y,symbol)];

if ~hold_state, hold off; end

if nargout>0, hh = h; end


function PlotSnowpitProfile4(p,type)

% plot a snowpit profile from SnowPitLAB
% INPUT:
%       snowpit profile data from SnowPitTemplate.xlsx format
% p =
%               Obs: 'Kelly, Scott'
%              Date: '01-Mar-2011 10:00:00'
%               Loc: 'Grand Mesa'
%               Pit: 13
%            Aspect: NW
%         Elevation: 10500
%        SlopeAngle: 20
%     Precipitation: 'S-1'
%          SkyCover: 'OVC'
%           AirTemp: -3
%              Wind: 'L SW'
%              UTME: 751106
%              UTMN: 4323521
%             notes: 'So much fun!'
%             layer: [1x1 struct]
%             dprof: [1x1 struct]
%             Tprof: [1x1 struct]
%
% p.layer =
%            top: [131 127 126 114 81 19 10]
%            bot: [127 126 114 81 19 10 0]
%     grainsize1: [1 1 1 2 1 1 5]
%     grainsize2: [1 1 1 3 1 1 4]
%     grainsize3: [1 1 1 2 1 1 4]
%     graintype1: {1x7 cell}
%     graintype2: {1x7 cell}
%     graintype3: {1x7 cell}
%       hardness: [1 1 1 2.5000 1 1 4.5000]
%          notes: {1x7 cell}
%
% p.dprof =
%       top: [131 121 111 101 91 81 71 61 51 41 31 21 11]
%       bot: [121 111 101 91 81 71 61 51 41 31 21 11 1]
%       rho: [13x2 double]
%
% p.Tprof =
%       depth: [1x14 double]
%       temp: [-1 -3 -4 -4 -4 -3 -3 -2 -2 -2 -1 -1 0 0]
%
%        type = ['hdtgrn'] string used to determine what to plot:
%               h = hardness profile
%               d = density profile
%               t = temperature profile
%               g = grain type
%               r = grain size
%               l = labeled layers
%
% OUTPUT:       P = updated structure array with snow pit data
%              AX = handles to 3 axes (hardness,density,temperature)
%               H  = handles to each plot object

% 20110419 SCH update to plot from data entered in SnowPitTemplate.xlsx
% format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the layer data
if isfield(p,'layer')
    layer = p.layer; % get the layer data
else
    display('No layer information included in data')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set a few parameters first
hs = -0.5; % hardness starting point
dyax=0.1; % offset for 2 LH axes
maxy = layer.top(1); %starting point for top

% HARDNESS
if ismember('h',type) % if hardness plot
    AX(1) = gca;
    
    for n = 1:length(layer.top)
        
        hold on
        % create boundaries for hardness profile boxes
        x = [hs,layer.hardness(n),layer.hardness(n),hs,hs];
        y = [layer.top(n),layer.top(n),layer.bot(n),layer.bot(n),layer.top(n)];
        H{n} = fill(x,y,[0.7 0.7 0.7]);
        
    end
    %     end
    maxy = max(layer.top); %get the max height of the plot
    maxx{1} = max(layer.hardness); %get the max width of the plot
    hn = n+1;
    
else
    AX(1) = 0;
    hn = 1;
end

%%% DENSITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember('d',type)  % if density plot
    
    if AX ~= 0 %already hardness plot
        axpos{1} = get(AX(1),'Position'); %hardness axis position
        axpos{2} = axpos{1};
        axpos{2}(2) = axpos{1}(2)+dyax; % move density axis up by dyax
        axpos{2}(4) = axpos{1}(4)-dyax; % make the tops coincide (shorten this one)
        AX(2) = axes('Position',axpos{2},...
            'XAxisLocation','bottom',...
            'YAxisLocation','left',...
            'Color','none',...
            'XColor','b','YColor','k');
    else
        %     if isempty(AX) %no hardness plot
        AX(2) = gca;
        axpos{2} = get(AX(2),'Position');
    end
    hold on
    if isfield(p,'dprof')
        dprof=p.dprof; % get the density data
    else
        display('No density data included')
    end
    
    % calculate density stats
    mean_rho = mean(dprof.rho,2); % calculate mean value of each entry
    rL = mean_rho - min(dprof.rho,[],2);
    rR = max(dprof.rho,[],2) - mean_rho;
    mean_depth = mean([dprof.top(:) dprof.bot(:)],2); % mean depth
    dU = dprof.top(:) - mean_depth; % lower bound for error
    dL = mean_depth - dprof.bot(:); % upper error bound
    
    % plot densities and error bounds
    axes(AX(2))
    H{hn} = errorbar(mean_rho,mean_depth,dL,dU,'bo-');% plot mean density
    hold on
    H{hn+1} = herrorbar(mean_rho,mean_depth,rL,rR,'bo-');% plot density range
    %     end
    set(H{hn},'LineWidth',1)
    set(H{hn+1},'LineWidth',1)
    
    maxy = max([maxy max(dprof.top)]); %top of plot max
    maxx{2} = max(mean_rho+rR); %right of plot max
    hn = hn+2;
    %     set(AX(2),'Color','none')
else
    AX(2) = 0;
    hn = 1;
end
%%%%%%%% TEMPERATURE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ismember('t',type)
    if AX(2) ~= 0 % if density, copy axis
        axpos{3} = axpos{2};
        AX(3) = axes('Position',axpos{3},...
            'XAxisLocation','top',...
            'YAxisLocation','left',...
            'Color','none',...
            'XColor','r','YColor','k');
    else
        if AX(1) ~= 0  % if hardness but no density
            axpos{1} = get(AX(1),'Position');
            axpos{3} = axpos{1};
            AX(3) = axes('Position',axpos{3},...
                'XAxisLocation','top',...
                'YAxisLocation','left',...
                'Color','none',...
                'XColor','r','YColor','k');
        else
            AX(3) = gca; % if neither density nor hardness
        end
    end
    
    hold on
    if isfield(p,'Tprof')
        Tprof=p.Tprof; % get the temperature data
    else
        display('No temperature data')
    end
    
    axes(AX(3))
    H{hn} = plot(Tprof.temp,Tprof.depth,'ro-');
    %     end
    set(H{hn},'LineWidth',1)
    maxy = max([maxy max(Tprof.depth)]);
    maxx{3} = max(-(Tprof.temp));
    hn = hn+1;
else
    AX(3) = 0;
end

%%%%%%% NOW THAT ITS PLOTTED, LETS FIX AXES, AXIS, AND LINE UP DEPTHS
%%% first figure out which of 3 plots were made
% lets first find limits of plot:

for n=1:3
    if AX(n)
        set(AX(n),'FontSize',12,'Fontweight','bold')
        switch n
            case 1
                axes(AX(n));
                if ismember('hd',type)
                    axis([hs 5.33 -maxy*(axpos{1}(4)/axpos{2}(4)-1) maxy]);
                else
                    axis([hs 5.33 0 maxy])
                end
                set(AX(1),'XTick',[1 2 3 4 5],...
                    'XTickLabel',[{'F'},{'4-f'},{'1-f'},{'P'},{'K'}])
                xlabel('Hand Hardness','FontSize',11,'Fontweight','bold')
                
            case 2
                axes(AX(n));
                axis([0 maxx{2}+20 0 maxy])
                xlabel('Density [kg/m^3]','FontSize',11,'Fontweight','bold')
                
            case 3
                axes(AX(n));
                axis([-maxx{3}-0.5 0 0 maxy])
                xlabel('Temperature [deg C]','FontSize',11,'Fontweight','bold')
                
        end
    end
end
ylabel('Depth [cm]','Fontsize',12,'Fontweight','bold')

if ismember('hd',type) %remove the hardness depths
    set(AX(1),'YTick',[],'YTickLabel',[]);
end

%set axis for grain type, size, and label
if AX(1) ~= 0
    ax = AX(1); %if hardness, set as current axis
elseif AX(2) ~= 0
    ax = AX(2);
elseif AX(3) ~= 0
    ax = AX(3);
else
    ax = gca;
end

if sum(ismember('rg',type))
    for n = 1:length(layer.top)
        mid = mean([layer.top(n) layer.bot(n)]);
        
        if ismember('r',type)
            size = [min([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])...
                max([layer.grainsize1(n) layer.grainsize2(n) layer.grainsize3(n)])];
            
            if isnan(size) %no grainsize given
                t = '      ';
            else
                t = [num2str(size(1)) ' - ' num2str(size(2))];
            end
            
        else
            t = [];
        end
        
        if ismember('g',type)
            
            if ~isnan(layer.graintype1{n})
                t = [t ' ' layer.graintype1{n}];
            end
            if ~isnan(layer.graintype2{n})
                t = [t ' ' layer.graintype2{n}];
            end
            if ~isnan(layer.graintype3{n})
                t = [t ' (' layer.graintype3{n} ')'];
            end
        end
        
        axes(ax)
        ht = text(-0.25,mid,t);
        set(ht,'FontSize',9,'FontWeight','bold')
    end
end

%%%%% LAYER LABEL
str='ABCDEFGHIJKLMNOPQRSTUVWXYZ';
if ismember('l',type)
    axes(ax)
    for n = 1:length(layer.top)
        mid = mean([layer.top(n) layer.bot(n)]);
        ht = text(-0.4,mid,[str(n) ')']);
        set(ht,'FontSize',11,'FontWeight','bold','Color','w')
    end
end

% put axes in order
for n=1:3
    if AX(n)
        axes(AX(n))
    end
end













