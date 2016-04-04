function [h, x_data, y_data] = SN_plotCascade(varargin)
% SN_PLOTCASCADE provides cascading plot of regularly spaced profiles
%
% SN_PLOTCASCADE(X,Y) plots cascading profiles with even spaces between
%   profiles. The function assumes that data in the same column is from
%   one profile and N columns correspond to N profiles. By default, the
%   function removes the mean from each profile for a nice plot
%
% SN_PLOTCASCADE(...,'Time',T) plots cascading profiles with the spacing
%   betweeng them being adjusted so that the X axis indicates the time at
%   which the profiles measured. T has to have the same dimension of X and
%   Y.
% 
% SN_PLOTCASCADE(...,'Scale',MYSCALE) plots cascading profiles with the
%   spacing between them being scaled according to the scalar MYSCALE.
%
% SN_PLOTCASCADE(...,'KeepMean') keeps the mean while plotting the
%   profiles.
% 
% SN_PLOTCASCADE(AX,...) plots cascading profiles onto the specified AX
% axes instead of the current axes
%
% Created   San Nguyen (stn004@ucsd.edu)
% Date      2011.07.16 (San Nguyen)
% Updated   2012.03.07 (San Nguyen)
% Updated   2015.07.07 (San Nguyen) updated to improve scaling
%


[ax, args, nargs] = axescheck(varargin{:});

argsNameToCheck = {'Time','Scale','KeepMean','PointsToPlot','noplot'};
xdata = args{1};
ydata = args{2};
time = [];
plotoptions=args(3:end);
scale = 1;
rmean = true;
isplotoptions = false(size(plotoptions));
pt2plot = true(size(xdata));
doplot = true;


% check for input options
index = 3;
n_items = nargs-2;
while (n_items > 0)
    argsMatch = strcmpi(args{index},argsNameToCheck);
    i = find(argsMatch);
    
    if isempty(i)
        isplotoptions(index-2) = true;
        index = index +1;
        n_items = n_items-1;
        continue;
    end

    switch i
        case 1 %time
            if index == (nargs)
                error('MATLAB:plotCascade:missingArgs','Missing input arguments');
            end
            time = args{index+1};
            index = index +2;
            n_items = n_items-2;
        case 2 %scale
            if index == (nargs)
                error('MATLAB:plotCascade:missingArgs','Missing input arguments');
            end
            scale = args{index+1};
            index = index +2;
            n_items = n_items-2;
        case 3 %keep mean
            rmean = false;
            index = index +1;
            n_items = n_items-1;
        case 4 %pt2plot
            if index == (nargs)
                error('MATLAB:plotCascade:missingArgs','Missing input arguments');
            end
            pt2plot = args{index+1};
            index = index +2;
            n_items = n_items-2;
            if length(pt2plot) ~= length(xdata)
                error('MATLAB:plotCascade:wrongSize','Points to plot must be the same size as X and Y data');
            end
        case 5 %noplot
            doplot = false;
            index = index +1;
            n_items = n_items-1;
    end
end

%define the scale using approximate 10% spacing
if isempty(time)
    if isempty(scale)
        xrange = range(xdata(:));
%         scale = 0.05*xrange;
    end
else
    xrange = range(xdata(:));
%     xrange = nanmedian(range(xdata,1));
    tspace = median(diff(time(1,:)));
%     scale = scale/xrange*tspace;
end


% adjust the offsets for each profile for plotting
% if time is specified, then we have to adjust according to time
% if ~isempty(time)
%     if rmean % if remove mean
%         xdata = (xdata-ones(size(xdata,1),1)*nanmean(xdata,1))...
%             *scale+time;
%     else % else just do the time adjust
%         xdata = (xdata)...
%             *scale+time;
%     end
% else % or else it's just a simple offset
%     if rmean
%         xdata = (xdata-ones(size(xdata,1),1)*nanmean(xdata,1));
%     end
%     xdata = xdata + scale*ones(size(xdata,1),1)*(1:size(xdata,2));
% end
if isvector(time)
    time = repmat(time(:)',[size(xdata,1) 1]);
end
if ~isempty(time)
    if rmean % if remove mean
        xdata = (xdata-ones(size(xdata))*nanmean(xdata(~isinf(xdata(:)))))...
            *scale+time;
    else % else just do the time adjust
        xdata = (xdata)...
            *scale+time;
    end
else % or else it's just a simple offset
    if rmean
        xdata = (xdata-ones(size(xdata))*nanmean(xdata(:)));
    end
    xdata = xdata + scale*ones(size(xdata,1),1)*(1:size(xdata,2));
end

if isempty(ax) && doplot
    ax = gca;
end
xdata(~pt2plot) = NaN;
% plotting...
if nargout == 1 || nargout == 3
    try
        if doplot
            h = plot(ax,xdata,ydata,plotoptions{isplotoptions});
        else
            h = [];
        end
    catch err
        err.throw;
    end
end

if nargout == 3
    x_data = xdata;
    y_data = ydata;
elseif nargout == 2;
    h = xdata;
    x_data = ydata;
end

if nargout < 1 || nargout == 2
    try
        if doplot
            plot(ax,xdata,ydata,plotoptions{isplotoptions});
        end
    catch err
        err.throw;
    end
end
return