function ploteigenmodes(guifile,handles,selection,h1,h2)
% Plot the eigenmodes in the GUI

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% selection == 0 corresponds to no selection being made, i.e. plot everything
if nargin < 3, selection = 0; end 
if nargin < 4, h1 = handles.fig_sol; end
if nargin < 5, h2 = handles.fig_norm; end


if ~handles.hasSolution
    return
end

D = handles.latest.solution;
V = handles.latest.solutionT;

% Always create the same number of colours to preserve colours if selection
% is changed.
C = get(0,'DefaultAxesColorOrder');
C = repmat(C,ceil(size(D)/size(C,1)),1);


if selection % Need to trim the data we are plotting if user has made a selection
    D = D(selection);
    if iscell(V) % This will only happen when we're working with systems
        % Need to go through the cells and pick out each column of the
        % quasimatrices
        for cCounter = 1:size(V,2)
            Vtemp = V{cCounter};
            V{cCounter} = Vtemp(:,selection);
        end
    else
        V = V(:,selection);
    end
    C = C(selection,:);
end

if ~isempty(h1)
    % Ensure that we still have the same x and y-limits on the plots. Only
    % do that when we are not plotting all the information
    if selection
        xlim_sol = xlim(h1); ylim_sol = ylim(h1);
    end
    
    axes(h1)
    for k = 1:size(D)
        plot(real(D(k)),imag(D(k)),'.','markersize',25,'color',C(k,:)); hold on
    end
    hold off
    if guifile.options.grid, grid on, end
    title('Eigenvalues'); xlabel('real'); ylabel('imag');
    if any(selection) && nargin < 4
        xlim(h1,xlim_sol); ylim(h1,ylim_sol);
    end
    axis equal
end

if isempty(h2), return, end

isc = iscell(V);
nV = numel(V);

realplot = get(handles.button_realplot,'Value');
W = V;
if realplot
    if ~isc
        V = real(V);
    else
        for k = 1:nV
            V{k} = real(V{k});
        end
    end
    s = 'Real part of eigenmodes';
else
    if ~isc
        V = imag(V);
    else
        for k = 1:nV
            V{k} = imag(V{k});
        end
    end
    s = 'Imaginary part of eigenmodes';
% else
%     V = V.*conj(V);
%     s = 'Absolute value of eigenmodes';
end

axes(h2)
% set(h2,'NextPlot','add')
set(h2,'ColorOrder',C)
if any(selection) && nargin < 4
    xlim_norm = xlim(h2); ylim_norm = ylim(h2);
end
if ~isc
    if nV == 1 && ~isreal(W) && ~isreal(1i*W)
        xx = union(linspace(V.ends(1),V.ends(end),chebfunpref('plot_numpts')),V.ends);
        WW = abs(W(xx));
        plot(V(:,1),'-','linewidth',2,'color',C(1,:)); hold on
        plot(xx,WW,'-',xx,-WW,'-','linewidth',1,'color','k'); hold off
        xLims = V(:,1).domain;
    else
        for k = 1:numel(V)
            plot(V(:,k),'linewidth',2,'color',C(k,:)); hold on
        end
        xLims = V(:,k).domain;
        hold off
    end
    if guifile.options.grid, grid on, end
    ylabel(handles.varnames);
else
    LS = repmat({'-','--',':','-.'},1,ceil(numel(V)/4));
    ylab = [];
    if numel(V{1}) == 1 && ~isreal(W{1}) && ~isreal(1i*W{1})
        V1 = V{1};
        xx = union(linspace(V1.ends(1),V1.ends(end),chebfunpref('plot_numpts')),V1.ends);
        for cCounter = 1:nV
            WW = abs(W{cCounter}(xx));
            plot(real(V{cCounter}),'-','linewidth',2,'linestyle',LS{cCounter}); hold on
            plot(xx,WW,'k',xx,-WW,'k','linestyle',LS{cCounter});
        end
        xLims = V{cCounter}.domain;
        hold off
    else
        for cCounter = 1:nV
            % If we are plotting selected e-funs, we need to pick out the colors
            if any(selection)
                for sCounter = 1:length(selection)
                    plot(real(V{cCounter}(:,sCounter)),'linewidth',2,...
                        'linestyle',LS{cCounter},'Color',C(sCounter,:)); hold on
                end
                xLims = V{cCounter}(:,sCounter).domain;
            else
                plot(real(V{cCounter}),'linewidth',2,'linestyle',LS{cCounter}); hold on
                xLims = V{cCounter}(:,1).domain;
            end
            ylab = [ylab handles.varnames{cCounter} ', ' ];
        end
    end
    hold off
    ylabel(ylab(1:end-2));
end
if any(selection) && nargin < 4
    xlim(xlim_norm);
else
    xlim(xLims);
end
set(h2,'NextPlot','replace')

xlabel(handles.indVarName);

% Set the xlim according to the domain of the function
title(s);


