function varargout = chebpolyplot(F,varargin)
%CHEBPOLYPLOT Display the chebpolyplot of the column and row slices.
%
% CHEBPOLYPLOT(F) plots the Chebyshev coefficients of the one-dimensional
% slices that form F on a semilogy scale. It returns two figures one for
% the row slices and one for the column slices.  By default only the first
% six row and column slices are plotted.
%
% CHEBPOLYPLOT(F,S) allows further plotting options, such as linestyle, 
% linecolor, etc. If S contains a string 'LOGLOG', the coefficients will 
% be displayed on a log-log scale.
%
% See also CHEBPOLYPLOT2, CHEBPOLY2.

% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

mode = chebfun2pref('mode'); rect = F.corners;
Cols = F.fun2.C; Rows = F.fun2.R; 

whichSlices = 1:min(6,length(F));      % which slices to plot (max of 6).

% doWeHoldOn = ishold; 

%%
% There are two figures.  One plots the chebpolyplot of the column slices
% and the other the chebpolyplot of the row slices. 

 
if ( mode )
    ColumnSlices = Cols(:,whichSlices);
else
    ColumnSlices = chebfun(Cols(:,whichSlices),rect(3:4));
end

figure % first figure plots column slices.
h1=chebpolyplot(ColumnSlices);  % chebpolyplot of column slices.
title('Coefficients of column slices','FontSize',16)


if ( mode )
    RowSlices = Rows(whichSlices,:);
else
    RowSlices = chebfun(Rows(whichSlices,:).',rect(1:2)).';
end

figure  % second figure plots row slices.
h2=chebpolyplot(RowSlices); % chebpolyplot of row slices.
title('Coefficients of row slices','FontSize',16)

% if ( ~doWeHoldOn ) 
%     hold off  % hold off if we can. 
% end  

%% 
% Return plot handles when appropriate.
if ( nargout == 1 )
    varargout = {h1};
elseif ( nargout ==2 )
    varargout = {h1, h2};
end