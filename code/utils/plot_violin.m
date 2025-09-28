function out = plot_violin(data,varargin)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% KS-violin plots with boxplots, 
% connecting lines and dots
%                                                         D. Pascucci, EPFL
% Last update: 06.04.2022
%--------------------------------------------------------------------------
% INPUT
% - data is a matrix of n-by-x with n = subjects, x = number of conditions
% - additional input pairs (e.g., plot_violin(data,'color',[1 0 0]))
%   . see the definitions of each admitted input pair in line 25-41
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
x             = check_set_variables(names,values,'x',1:size(data,2));               % x values 
x_labels      = check_set_variables(names,values,'x_labels',1:size(data,2));        % labels of each x value
rescaling     = check_set_variables(names,values,'rescaling',0.35*range(x(:)));     % rescale the figure (default should be OK)
ksdensamp     = check_set_variables(names,values,'ksdensamp',x(1)*.15);             % for ksdensity scaling
showdots      = check_set_variables(names,values,'showdots',true);                  % true: show single dots
color         = check_set_variables(names,values,'color',.5*ones(size(data,2),3));  % color (nx1 or nx3 if different colors for each x)
bins          = check_set_variables(names,values,'bins',100);                       % bins for distributions (ksdensity)
bandwidth     = check_set_variables(names,values,'bandwidth',0.1*range(data(:)));   % bandwidth, ksdensity
viorefine     = check_set_variables(names,values,'viorefine',true);                 % apply the ksdensity adjusment
violalpha     = check_set_variables(names,values,'violalpha',.5);                   % violin opacity
dotssize      = check_set_variables(names,values,'dotssize',35);                    % size of single dots
dotalpha      = check_set_variables(names,values,'dotalpha',.25);                   % dots opacity 
connline      = check_set_variables(names,values,'connline',1);                     % show lines connecting averages
allline       = check_set_variables(names,values,'allline',false);                  % show lines connecting each dot
linemarksize  = check_set_variables(names,values,'linemarksize',10);                % markersize for lines
linemarkwidth = check_set_variables(names,values,'linemarkwidth',2);                % widht for lines
boxshift      = check_set_variables(names,values,'boxshift',.1);                    % shift the boxplot on x (can be neg or pos or 0)
dotshift      = check_set_variables(names,values,'dotshift',.1);                    % shift the dots (same as above)
facecolor     = check_set_variables(names,values,'facecolor','sameas');
facealpha     = check_set_variables(names,values,'facealpha',[]);
jitfactor     = check_set_variables(names,values,'jitfactor',0.02);                 % jittering factor for the dot x
%==========================================================================
% check if the same color is assigned to multiple columns
if size(color,1)==1 && size(data,2)>1
    color     = repmat(color,[size(data,2) 1]);
end
rescaling     = rescaling*ones(1,size(data,2));
% loop over data columns
ncol          = size(data,2);
pc            = cell(ncol,1);
bx            = cell(ncol,1);
sc            = cell(ncol,1);
xjit          = nan(size(data,1),2);
for k = 1:ncol
    y         = data(:,k);
    xval      = linspace(min(y),max(y),bins);
    if ~isnan(violalpha)
    % ks density
    [f,xi]    = ksdensity(y,xval,'Bandwidth',bandwidth,...
                         'BoundaryCorrection','reflection');
    %----------------------------------------------------------------------
    % refine (adapted from
    % https://github.com/bastibe/Violinplot-Matlab/blob/master/Violin.m)
    density   = f;
    value     = xi;
    if viorefine
        density   = density(value >= min(y) & value <= max(y));
        value     = value(value >= min(y) & value <= max(y));
        value(1)  = min(y);
        value(end)= max(y);
        value     = [value(1)*(1-1E-5), value, value(end)*(1+1E-5)];
        density   = [0, density, 0];
    end
    f         = density;
    xi        = value;
    %----------------------------------------------------------------------
    f         = rescale(f,0,ksdensamp);
    % draw the half-violin
    pc{k}     = patch( x(k)-[f,zeros(1,numel(xi),1),0],[xi,fliplr(xi),xi(1)],'r');
    % style
    pc{k}.FaceAlpha    = violalpha;
    pc{k}.LineStyle    = 'none';
    pc{k}.FaceColor    = color(k,:);
    hold on
    end
    % add the boxplot
    bx{k}     = plot_box(y,'x',x(k)+boxshift,'rescaling',rescaling,'color',color(k,:),'facecolor',facecolor,'facealpha',facealpha);
    % add the single points
    if showdots
        xjit(:,k)      = x(k)+dotshift+jitfactor*rand(size(y));
        sc{k} = scatter(xjit(:,k),y,dotssize,...
                'markerfacecolor',color(k,:),'markeredgecolor',color(k,:), ...
                'markerfacealpha',dotalpha,'markeredgealpha',dotalpha);
    end
end
% add the connecting average line
if numel(connline)==1 && connline==1 % this only uses the first color...
      plot(x,mean(data),'o-','color',color(1,:),'markersize',linemarksize, ...
                    'linewidth',linemarkwidth,'markerfacecolor',[1 1 1]);           
end
if numel(connline)>1
        plot(x,mean(data),'o-','color',connline,'markersize',linemarksize, ...
                    'linewidth',linemarkwidth,'markerfacecolor',[1 1 1]);
end

if allline
    if showdots
        colorlines  = [.7 .7 .7]; % always gray
        pl    = plot(xjit',data','-','color',colorlines); 
    else
        colorlines  = color(1,:); % always use the first
        pl    = plot(x,data,'-');
    end
    arrayfun( @(line) set(pl,'LineWidth',1,'Color',[colorlines .3]), lines );
end

% set x
set(gca,'xtick',x,'xticklabels',x_labels)
% output
out           = struct('pc',pc,'bx',bx,'sc',sc);
end


