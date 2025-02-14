function load_pitdata

% 20110315 Scott Havens
%
% Load manual snow pit data from a standard Excel template into matlab.
% The format will be in the SnowpitLAB_v18 format for ease of plotting
% This code will load either the old or new International Classification
% for Seasonal Snow on the Ground, which can be found in the SWAG manual
% The spread sheet uses standard information that is found in the most
% rescent SWAG manual.
%
% This will only load in one Excel file at a time.  If you are running on
% LINUX/UNIX make sure that the Excel spread sheet is in a readable format.
% Saving as Excel 5.0/95 usually works.
%
% 20130311 Scott Havens
%       - More robust determination of the number of temperature layers.
%       This can now handle the last temperature value to be the end of
%       file.
%       - .xlsx format now produces a NaN value for an empty sheet.  This
%       is now supported and will be ignored.
%
% Loads pit data into the following format:
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
%       moisture: [0 0 1 1 1 1 2]
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First determine which platform MATLAB is running on.  Unfortunately,
% MATLAB xlsread/xlsfinfo doesn't run on a mac.  Just saving people time
%
% xlsread/xlsfinfo also isn't supper compatiable with LINUX/UNIX for newer
% verions of Excel.  Saving in Excel 5.0/95 will import the data.

% if ismac
%     mtxt = sprintf('You are on a MAC, therefore you cannot import from Excel.  Take it up with Microsoft.\n\nTry anyway?');
%
%     % Construct a questdlg with two options
%     choice = questdlg(mtxt, ...
%         'Load Pit Data Warning', ...
%         'Try Anyway','Exit','Exit');
%     % Handle response
%     switch choice
%         case 'Try Anyway'
%             disp('Going for it!!')
%
%         case 'Exit'
%             error('Better luck next time.')
%     end
% end

if isunix || ismac
    mtxt = sprintf('You are on a LINUX/UNIX machince.  To import Excel data, convert file to Excel 5.0/95.\n\nIs the file in Excel 5.0/95?');
    
    % Construct a questdlg with two options
    choice = questdlg(mtxt, ...
        'Load Pit Data Warning', ...
        'Sure is','Not Yet','Try Anyway','Sure is');
    % Handle response
    switch choice
        case 'Sure is'
            disp('Way to go!')
            
        case 'Not Yet'
            error('Save file in Excel 5.0/95 and try again')
            
        case 'Try Anyway'
            disp('Going for it!!')
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI that will get path and file name of the user selected file

% Excel pit file path
if ispc
    [FileName,PathName] = uigetfile({'*.xlsx';'*.xls'},'Select Excel File with Snow Pit Data');
    
elseif isunix || ismac
    [FileName,PathName] = uigetfile({'*.xls';'*.xlsx'},'Select Excel File with Snow Pit Data');
    
end

if isequal(FileName,0)
    error('User selected Cancel, file has not been converted.')
else
    disp(['User selected', fullfile(PathName, FileName)])
end

fpath = fullfile(PathName, FileName); %full path name


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check the Excel file and get the sheet names
[typ, sheets] = xlsfinfo(fpath);

% loop through each sheet and load data
for n = 1:length(sheets)
    
    % load pit data in sheet
    [num, txt, raw] = xlsread(fpath,sheets{n});
    
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
        
        % check to see if density is loaded
        if isfield(p,'dprof')
            if isempty(p.dprof)
                display('No density data loaded')
            end
        else
            display('No density data loaded')
        end
        
        if ~isempty(warn) % show the warnings
            str = sprintf('\t%s\n',warn{:});
            str = sprintf('Error: The following layers do not have a density associated with them:\n\n%s',str);
            warndlg(str,'Density Warning')
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
            display('Bad or no temperature data')
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

uisave('p','SnowPitData.mat')


