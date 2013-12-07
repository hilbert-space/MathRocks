function g = nonadaptive_ctor(g , op , ends , vectorize, varargin )
% CTOR  chebfun2 constructor
%
% This constructor is the same as the adaptive one, except the rank of the
% resulting fun2 is fixed. We adapt on (m,n), the polynomial degree of the
% fun2, but not on the rank k. 

% Copyright 2013 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

rank = varargin{1};
pref2 = chebfun2pref;
% Extract out properties from structures.
tol=pref2.eps;
maxdegree = pref2.maxslice;
maxrank = pref2.maxrank; 

if rank > maxrank
    error('FUN2:NONADAPTIVE_CTOR','Prescribed rank larger than max rank preference.');
end


hscale = max(max(abs(ends)),1); % don't ask for more than 16 digits.
tol = tol * hscale;
rk = floor(rank*4);

spotcheck = 1;
while spotcheck
    imunhappy = 1;  % If unhappy, selected pivots were not good enough.
    while imunhappy && rk < maxrank
        rk = 2^(floor(log2(rk))+1)+1;  % discretise on powers of 2, clustering is important.
        [xx,yy]=chebpts2(rk,rk,ends);
        vals = evaluate(op,xx,yy,vectorize);             % Matrix of values at cheb2 pts.
        scl = max(abs(vals(:))); %scl = max(1,scl);
        if isinf(scl)
            error('FUN2:CTOR','Function returned INF when evaluated');
        end
        if any(any(isnan(vals)))
            error('FUN2:CTOR','Function returned NaN when evaluated');
        end
        [PivotValue,PivotPos,Rows,Cols] = nonadapt_ACA(vals,rank);
        strike = 0;
    
        if size(Cols,1)>1 && size(Rows,2)>1
            % See if the slices are resolved.
            newCols = mysimplify(Cols,hscale,scl,tol);
            if length(newCols) < length(Cols),ResolvedCols=1;else ResolvedCols=0;end
            %             lenc = length(Cols); lenc = 2.^(log2(lenc-1) - 1)+1;   % truncate columns if we went too far.
            %             while length(newCols) <= lenc
            %                 lenc = 2.^(log2(lenc-1) - 1)+1;
            %                 Cols = Cols(1:2:end,:);
            %             end
            lenc = 2.^ceil(log2(size(newCols,1))) + 1;
            %             lenc = size(newCols,1);
            Cols = wrap(Cols,lenc);
            newRows = mysimplify(Rows.',hscale,scl,tol).';
            if length(newRows) < length(Rows),ResolvedRows=1;else ResolvedRows=0;end
            %             lenr = length(Rows); lenr = 2.^(log2(lenr-1) - 1)+1;    % truncate rows if we went too far.
            %             while length(newRows) <= lenr
            %                 lenr = 2.^(log2(lenr-1) - 1)+1;
            %                 Rows = Rows(:,1:2:end);
            %             end
            lenr = 2.^ceil(log2(size(newRows,2))) + 1;
            %             lenr = size(newRows,1);
            Rows = wrap(Rows.',lenr).';
            ResolvedSlices = ResolvedRows & ResolvedCols;
            if strike >= 3, ResolvedSlices =1; end   %If the function is 0+noise then pass along as resolved.
        end
        
        if length(PivotValue)==1 && PivotValue==0
            PivPos=[0 0]; ResolvedSlices=1;
        else
            % find nans if any: 
            kk = find(abs(PivotPos(:,1))==0,1,'first');
            if ~isempty(kk)
                for jj = kk:size(PivotPos,1)
                    PivotPos(jj,:) = PivotPos(kk-1,:);
                end
            end
            PivPos = [xx(1,PivotPos(:,2)); yy(PivotPos(:,1),1).'].'; PP=PivotPos;
        end
        
        
        
        n=rk; m=rk;
        % If unresolved then perform ACA on selected slices.
        while ~ResolvedSlices
            if ~ResolvedCols
                n=2^(floor(log2(n))+1)+1;
                [xx yy] = meshgrid(PivPos(:,1),chebpts(n,ends(3:4)));
                Cols = evaluate(op,xx,yy,vectorize);
                oddn = 1:2:n; PP(:,1) = oddn(PP(:,1)); % find location of pivots on new grid.
            else
                [xx yy] = meshgrid(PivPos(:,1),chebpts(n,ends(3:4)));
                Cols = evaluate(op,xx,yy,vectorize);
            end
            if ~ResolvedRows
                m =2^(floor(log2(m))+1)+1;
                [xx yy] = meshgrid(chebpts(m,ends(1:2)),PivPos(:,2));
                Rows = evaluate(op,xx,yy,vectorize);
                oddm = 1:2:m; PP(:,2) = oddm(PP(:,2)); % find location of pivots on new grid.
            else
                [xx yy] = meshgrid(chebpts(m,ends(1:2)),PivPos(:,2));
                Rows = evaluate(op,xx,yy,vectorize);
            end
            
            nn = numel(PivotValue);
            % ACA on selected Pivots.
            for kk=1:nn-1
                selx = PP(kk+1:nn,1); sely = PP(kk+1:nn,2);
                Cols(:,kk+1:end) = Cols(:,kk+1:end) - Cols(:,kk)*(Rows(kk,sely)./PivotValue(kk));
                Rows(kk+1:end,:) = Rows(kk+1:end,:) - Cols(selx,kk)*(Rows(kk,:)./PivotValue(kk));
            end
            
            % Are the columns and rows resolved now?
            if ~ResolvedCols
                newCols = mysimplify(Cols,hscale,scl,tol);
                if length(newCols) < length(Cols)
                    ResolvedCols=1;
                end
            end
            if ~ResolvedRows
                newRows = mysimplify(Rows.',hscale,scl,tol).';
                if length(newRows) < length(Rows)
                    ResolvedRows=1;
                end
            end
            ResolvedSlices = ResolvedRows & ResolvedCols;
            if max(m,n) >= maxdegree  % max number of degrees allows.
                error('FUN2:CTOR','Unresolved with maximum Chebfun length: %u.',maxdegree);
            end
            
            
            
        end
        if ResolvedSlices, imunhappy = 0; end % Pivots locations are probably ok.
        
        
        % check the first three pivots are at least okay. Though a rank
        % 1 function doesn't need this check (almost any nonzero pivot location
        % will do).
        if ( length( PivotValue ) > 1 )
            for jj = 1:min(3,length(PivotValue))
                if max(max(abs(Cols(:,jj))),max(abs(Rows(jj,:)))) - abs(PivotValue(jj)) > hscale*scl*1e-2;
                    imunhappy = 1; break
                end
            end
        end
    end
    % Simplify now to any length.
    %         if norm(Cols)~=0   % in case we were given the zero function.
    %           Cols = mysimplify(Cols,hscale,scl,tol);
    %         end
    %         if norm(Rows)~=0
    %           Rows = mysimplify(Rows.',hscale,scl,tol).';
    %         end
    %           Cols = wrap(Cols,size(nCols,1));
    %           Rows = wrap(Rows.',size(nRows,2)).';
    
    % Now slices and columns are resolved make chebfuns.
    if pref2.mode
        Rows = transpose(chebfun(Rows.',ends(1:2))); Cols = chebfun(Cols,ends(3:4));
    end
    
    % Construct a FUN2
    g.U = PivotValue;
    g.PivPos = PivPos; % Store pivot positions for plotting.
    % rank is number of pivots unless its the zero function.
    if length(PivotValue) == 1 && PivotValue(1) == 0
        g.rank = 0;
    else
        g.rank = length(PivotValue);
    end
    
    % The scale may be wrong so we should update with the sampled column and rows as well.
    g.scl = max([max(abs(Cols(:,1))),max(abs(Rows(1,:))),abs(PivotValue(1))]);
    g.C = Cols;
    g.R = Rows;  % store as rows and not columns.
    
%     % evaluate at an arbitary point in the domain, to exclude Chebyshev
%     % function etc.
%     r = 0.029220277562146; s = 0.237283579771521;
%     r = (ends(2)+ends(1))/2 + r*(ends(2)-ends(1));
%     s = (ends(4)+ends(3))/2 + s*(ends(4)-ends(3));
%     if (abs(op(r,s) - feval(g,r,s)) <= 1e5*scl*pref2.eps)
%         spotcheck=0;
%     end
spotcheck = 0 ; 
end
end



function C = wrap(C,n)
% Aliase back for accuracy.

%if n < 9, n = 9; end  % no need to go down too low.

% Wrap, don't just truncate.
if n < size(C,1)
    C = chebfft(C);
    nn = 2*n - 2;
    for j=n+1:size(C,1)
        k = abs( mod( j+n-3 , nn ) - n + 2 ) + 1;
        C(k,:) = C(k,:) + C(j,:);
    end
    C = C(end-n+1:end,:);
    C = chebifft(C);
end
end

function vals = evaluate(op,xx,yy,flag)
if flag
    vals = zeros(size(yy,1),size(xx,2));
    for jj = 1:size(yy,1)
        for kk = 1:size(xx,2)
            vals(jj,kk) = op(xx(1,kk),yy(jj,1));
        end
    end
else
    vals = op(xx,yy);              % Matrix of values at cheb2 pts.
end
end