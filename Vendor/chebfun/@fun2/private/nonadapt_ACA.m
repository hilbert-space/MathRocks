function [PivotValue,PivotElement,Rows,Cols,ifail] = nonadapt_ACA(A,rank)
% This script does iterative Gaussian elimination with a predetermined
% number of steps.  There is nothing adaptive decided adaptively here. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

% Set up output variables.
[nx,ny]=size(A);
width = min(nx,ny);         % Use to tell us how many pivots we can take.
PivotValue = zeros(1);      % Store an unknown number of Pivot values.
PivotElement = zeros(1,2);  % Store (j,k) entries of pivot location.
ifail = 1;                  % Assume we fail.

% Main algorithm
zrows = 0;                  % count number of zero cols/rows.
% [xx,yy]=cheb2pts(nx,ny,g.map);  % points sampling from.
[ infnorm , ind ]=max( abs ( reshape(A,numel(A),1) ) );
[ row , col ]=myind2sub( size(A) , ind);
% [row,col,infnorm]=rook_pivot(A);
scl = infnorm;

% If the function is the zero function.
if scl == 0
    PivotValue=0;
    Rows = 0; Cols = 0;
    ifail = 0;
end

while ( zrows < rank ) && infnorm > eps
    Rows(zrows+1,:) = A( row , : ) ;
    Cols(:,zrows+1) = A( : , col ) ;    % Extract the columns out
    PivVal = A(row,col);
    A = A - Cols(:,zrows+1)*(Rows(zrows+1,:)./PivVal);    % Rank one update.
    
    % Keep track of progress.
    zrows = zrows + 1;                  % One more row is zero.
    PivotValue(zrows) = PivVal;         % Store pivot value.
    PivotElement(zrows,:)=[row col];    % Store pivot location.
    
    %Next pivot.
    %     [row,col,infnorm]=rook_pivot(A);
    %     [ infnorm , ind ]=max( abs ( reshape(A,numel(A),1) ) );
    [ infnorm , ind ]=max( abs ( A(:) ) );  % slightly faster.
    [ row , col ]=myind2sub( size(A) , ind );
end

while size(Rows,1) < rank
    Rows(size(Rows,1)+1,:) = realmin*ones(1,size(Rows,2));
end

while size(Cols,2) < rank
    Cols(:,size(Cols,2)+1,:) = realmin*ones(size(Cols,1),1);
end

while length(PivotValue) < rank
    PivotValue(length(PivotValue)+1) = realmin;
    PivotElement(length(PivotValue),:)=[0 0];
end

end



function [row col] = myind2sub(siz,ndx)
% My version of ind2sub. In2sub is slow because it has a varargout. Since
% this is at the very inner part of the constructor and slowing things down
% we will make our own. 
% This version is about 1000 times faster than MATLAB ind2sub. 

vi = rem(ndx-1,siz(1)) + 1 ; 
col = (ndx - vi)/siz(1) + 1;
row = (vi-1) + 1;

end