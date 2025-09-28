function out = plot_box(data,varargin)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Simple boxplots
%                                                         D. Pascucci, EPFL
% Last update: 06.04.2022
%--------------------------------------------------------------------------
% INPUT
% - data is a matrix of n-by-x with n = subjects, x = number of conditions
% - additional input pairs (e.g., plot_box(data,'color',[1 0 0]))
%   . see the definitions of each admitted input pair in line 24-29
%--------------------------------------------------------------------------
% OUTPUT
% - out: bar properties
%==========================================================================
if nargin==1
    varargin  = {'',''};
end
if isstruct(varargin{1})
    varargin  = namedargs2cell(varargin{:});
end
names         = varargin(1:2:end);
values        = varargin(2:2:end);
% assign fields or defaults
x             = check_set_variables(names,values,'x',1:size(data,2));
rescaling     = check_set_variables(names,values,'rescaling',ones(1,size(data,2)));
dotsout       = check_set_variables(names,values,'dotsout',nan);
sizedot       = check_set_variables(names,values,'sizedot',nan);
color         = check_set_variables(names,values,'color',[.5 .5 .5]);
facecolor     = check_set_variables(names,values,'facecolor',[1 1 1]);
facealpha     = check_set_variables(names,values,'facealpha',.1);
rectlinew     = check_set_variables(names,values,'rectlinew',2);
allline       = check_set_variables(names,values,'allline',false);
%==========================================================================
% prepare and plot the boxplots
if numel(rescaling)==1
    rescaling = rescaling.*ones(1,size(data,2));
end
width         = rescaling*.5;
half          = width/2;
h             = cell(size(data,2),1);
hl            = h;
hl2           = h;
n             = size(data,1);
X             = x;
jitter        = cell(size(data,2),1);
if size(color,1)==1
    color     = repmat(color,[numel(h) 1]);
end
% loop over data columns
for j = 1:size(data,2) 
    % quantile stat
    q           = quantile(data(:,j), [0.25 0.75 0.5]);
    % interquantile range
    iqr         = q(2) - q(1);
    Ys          = sort(data(:,j));
    % boxplot whiskers
    whiskers(1) = min(Ys(Ys > (q(1) - (1.5 * iqr))));
    whiskers(2) = max(Ys(Ys < (q(2) + (1.5 * iqr))));
    V           = [q whiskers];
    % box location
    box_pos     = [X(j)-half(j) V(1) width(j) V(2)-V(1)];
    % plot whiskers
    hl{j}       = line([X(j) X(j)],whiskers);
    hl{j}.Color = [0 0 0];
    % draw the box
    h{j}        = rectangle('Position', box_pos);hold on
    if ~isnan(sizedot)
        jitter{j} = dotsout*width(j)+X(j)+ (width(j)*.1)*randn(n,1);
        sc      = scatter(jitter{j},data(:,j),sizedot,color(j,:),...
            'MarkerFacecolor',color(j,:),'MarkerFaceAlpha',.2,'MarkerEdgeAlpha',1);
    else
        sc      = nan;
        hold on
    end
    % draw the median
    hl2{j}           = line([-half(j) half(j)]+X(j),[median(data(:,j)) median(data(:,j)) ]);
    hl2{j}.Color     = [0 0 0];
    % additional style changes (for whiskers and median)
    if strcmp(facecolor,'sameas')
        h{j}.FaceColor   = [color(j,:) facealpha];
    elseif strcmp(facecolor,'sameas_noalpha')
        h{j}.FaceColor   = color(j,:);
    else
        h{j}.FaceColor   = facecolor;
    end
    h{j}.EdgeColor   = color(j,:);
    h{j}.LineWidth   = rectlinew;
    hl{j}.Color      = color(j,:);
    hl{j}.LineWidth  = 2;
    hl2{j}.Color     = color(j,:);
    hl2{j}.LineWidth = 2;
end
% output
out           = struct('h',h{j},'sc',sc,'hl',hl,'hl2',hl2,'jitter',jitter);

if allline
    xjit        = reshape(cell2mat(jitter),size(data));
    colorlines  = [.7 .7 .7]; % always gray
    pl          = plot(xjit',data','-','color',colorlines);     
    arrayfun( @(line) set(pl,'LineWidth',1,'Color',[colorlines .3]), lines );
end

end